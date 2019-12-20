# frozen_string_literal: true

Puppet::Type.type(:harbor_project).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor projects'

  def self.instances
    api_instance = do_login

    projects = api_instance.projects_get

    projects.map do |project|
      new(
        ensure: :present,
        name: project.name,
        public: project.metadata.public,
        members: get_project_members(api_instance, project),
        provider: :swagger,
      )
    end
  end

  def self.get_project_members(api_instance, project)
    members = api_instance.projects_project_id_members_get(project.project_id)
    member_arry = []
    members.each do |member|
      member_arry << member.entity_name
    end
    member_arry.sort!.delete('admin')
    member_arry
  end

  def self.prefetch(resources)
    instances.each do |int|
      if (resource = resources[int.name])
        resource.provider = int
      end
    end
  end

  def self.do_login
    require 'yaml'
    require 'harbor_swagger_client'
    my_config = YAML.load_file('/etc/puppetlabs/swagger.yaml')

    SwaggerClient.configure do |config|
      config.username = my_config['username']
      config.password = my_config['password']
      config.scheme = my_config['scheme']
      config.verify_ssl = my_config['verify_ssl']
      config.verify_ssl_host = my_config['verify_ssl_host']
    end

    api_instance = SwaggerClient::ProductsApi.new
    api_instance
  end

  def do_login
    require 'yaml'
    require 'harbor_swagger_client'
    my_config = YAML.load_file('/etc/puppetlabs/swagger.yaml')

    SwaggerClient.configure do |config|
      config.username = my_config['username']
      config.password = my_config['password']
      config.scheme = my_config['scheme']
      config.verify_ssl = my_config['verify_ssl']
      config.verify_ssl_host = my_config['verify_ssl_host']
    end

    api_instance = SwaggerClient::ProductsApi.new
    api_instance
  end

  def exists?
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    begin
      result = api_instance.projects_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->projects_get: #{e}"
    end

    if result.nil?
      false
    else
      true
    end
  end

  def create
    api_instance = do_login

    np = SwaggerClient::ProjectReq.new(project_name: resource[:name], metadata: { public: resource[:public] })

    begin
      api_instance.projects_post(np)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->projects_post: #{e}"
    end

    return nil if resource[:members].nil?

    id = get_project_id_by_name(resource[:name])
    members = resource[:members]
    add_members_to_project(id, members)
  end

  def members
    api_instance = do_login
    id = get_project_id_by_name(resource[:name])
    members = api_instance.projects_project_id_members_get(id)
    member_arry = []
    members.each do |member|
      member_arry << member.entity_name
    end
    member_arry.sort!.delete('admin')
    member_arry
  end

  def members=(_value)
    do_login
    id = get_project_id_by_name(resource[:name])
    current_members = get_current_project_members(id)
    members = resource[:members]
    if current_members != nil?
      members_to_delete = current_members - members
      members_to_add = members - current_members
    end
    remove_members_from_project(id, members_to_delete) unless members_to_delete.empty?
    add_members_to_project(id, members) unless members_to_add.empty?
  end

  def get_project_id_by_name(project_name)
    api_instance = do_login

    opts = {
      name: project_name,
    }

    project = api_instance.projects_get(opts)
    project[0].project_id
  end

  def get_current_project_members(id)
    api_instance = do_login
    members = api_instance.projects_project_id_members_get(id)
    member_arry = []
    members.each do |member|
      member_arry << member.entity_name
    end
    member_arry.sort!.delete('admin')
    member_arry
  end

  def add_members_to_project(id, members)
    api_instance = do_login

    members.sort!
    members.each do |member|
      opts = { project_member: { role_id: 2, member_user: { "username": member.to_s } } } # role_id 2 == 'Developer'
      begin
        api_instance.projects_project_id_members_post(id, opts)
      rescue SwaggerClient::ApiError
        # EWWWWWW dirty hack to avoid 'Conflict' response from API
      end
    end
  end

  def remove_members_from_project(id, members_to_delete)
    api_instance = do_login

    members_to_delete.sort!
    members_to_delete.each do |member|
      mid = get_project_member_id_by_name(id, member)
      api_instance.projects_project_id_members_mid_delete(id, mid)
    end
  end

  def get_project_member_id_by_name(id, member)
    api_instance = do_login

    opts = {
      entityname: member,
    }
    result = api_instance.projects_project_id_members_get(id, opts)
    mid = result[0].id
    mid
  end

  def destroy
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    begin
      result = api_instance.projects_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->projects_get: #{e}"
    end

    return nil unless result

    project_id = result[0].project_id

    begin
      api_instance.projects_project_id_delete(project_id)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->projects_project_id_delete: #{e}"
    end
  end
end
