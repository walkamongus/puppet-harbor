# frozen_string_literal: true

Puppet::Type.type(:harbor_project).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor projects'

  def self.instances
    api_instance = do_login
    projects = api_instance.projects_get
    if projects.nil?
      []
    else
      projects.map do |project|
        new(
          ensure:        :present,
          name:          project.name,
          public:        project.metadata.public,
          members:       get_project_member_names(project.project_id),
          member_groups: get_project_member_group_names(project.project_id),
          provider:      :swagger,
        )
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
      config.ssl_ca_cert = my_config['ssl_ca_cert']
      if my_config['host']
        config.host = my_config['host']
      end
    end

    api_instance = SwaggerClient::ProductsApi.new
    api_instance
  end

  def self.get_project_member_names(project_id)
    members = get_project_members_with_entity_type(project_id, 'u')
    names = members.map { |m| m.entity_name }
    names.sort!.delete('admin')
    names
  end

  def self.get_project_members_with_entity_type(project_id, type)
    api_instance = do_login
    members_and_groups = api_instance.projects_project_id_members_get(project_id)
    members_and_groups.select { |m| m.entity_type == type }
  end

  def self.get_project_member_group_names(project_id)
    members = get_project_members_with_entity_type(project_id, 'g')
    names = members.map { |m| m.entity_name.downcase! }
    names.sort!
    names
  end

  def self.prefetch(resources)
    instances.each do |int|
      if (resource = resources[int.name])
        resource.provider = int
      end
    end
  end

  def exists?
    project = get_project_with_name(resource[:name])
    !project.nil?
  end

  def get_project_with_name(name)
    projects = get_projects_containing_name(name)
    filtered = filter_project_with_name(projects, name)
    filtered
  end

  def get_projects_containing_name(name)
    opts = { name: name }
    get_projects_with_opts(opts)
  end

  def filter_project_with_name(all_projects, name)
    filtered_projects = all_projects.select { |p| p.name == name }
    filtered_projects.empty? ? nil : filtered_projects[0]
  end

  def get_projects_with_opts(opts)
    api_instance = self.class.do_login
    begin
      projects = api_instance.projects_get(opts)
      projects.nil? ? [] : projects
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->projects_get: #{e}"
    end
  end

  def create
    api_instance = self.class.do_login
    np = SwaggerClient::ProjectReq.new(project_name: resource[:name], metadata: { public: resource[:public] })
    begin
      api_instance.projects_post(np)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->projects_post: #{e}"
    end

    return nil if resource[:members].nil? and resource[:member_groups].nil?

    id = get_project_id_by_name(resource[:name])
    unless resource[:members].nil?
      members = resource[:members]
      add_members_to_project(id, members)
    end
    unless resource[:member_groups].nil?
      member_groups = resource[:member_groups]
      add_member_groups_to_project(id, member_groups)
    end
  end

  def public=(_value)
    api_instance = self.class.do_login

    id = get_project_id_by_name(resource[:name])

    project = {
      "metadata": {
        "public": resource[:public],
      }
    }

    begin
      api_instance.projects_project_id_put(id, project, opts = {})
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->projects_project_id_put: #{e}"
    end
  end

  def get_project_id_by_name(project_name)
    project = get_project_with_name(resource[:name])
    project.project_id
  end

  def members
    id = get_project_id_by_name(resource[:name])
    self.class.get_project_member_names(id)
  end

  def members=(_value)
    id = get_project_id_by_name(resource[:name])
    current_members = self.class.get_project_member_names(id)
    members = resource[:members]

    members_to_delete = current_members - members
    members_to_add = members - current_members

    remove_members_from_project(id, members_to_delete) unless members_to_delete.empty?
    add_members_to_project(id, members_to_add) unless members_to_add.empty?
  end

  def remove_members_from_project(project_id, member_names)
    api_instance = self.class.do_login
    member_names.sort!
    member_names.each do |name|
      member_id = get_project_member_id_by_name(project_id, name)
      api_instance.projects_project_id_members_mid_delete(project_id, member_id)
    end
  end

  def get_project_member_id_by_name(project_id, name)
    api_instance = self.class.do_login
    opts = {
      entityname: name,
    }
    result = api_instance.projects_project_id_members_get(project_id, opts)
    result[0].id
  end

  def add_members_to_project(project_id, member_names)
    member_names.sort!
    member_names.each do |name|
      opts = { project_member: { role_id: 2, member_user: { "username": name.to_s } } } # role_id 2 == 'Developer'
      post_project_members(project_id, opts)
    end
  end

  def post_project_members(project_id, opts)
    api_instance = self.class.do_login
    begin
      api_instance.projects_project_id_members_post(project_id, opts)
    rescue SwaggerClient::ApiError
      # EWWWWWW dirty hack to avoid 'Conflict' response from API
    end
  end

  def member_groups
    id = get_project_id_by_name(resource[:name])
    self.class.get_project_member_group_names(id)
  end

  def member_groups=(_value)
    project_id = get_project_id_by_name(resource[:name])
    current_member_groups = self.class.get_project_member_group_names(project_id)
    member_groups = resource[:member_groups]

    member_groups_to_delete = current_member_groups - member_groups
    member_groups_to_add = member_groups - current_member_groups

    remove_member_groups_from_project(project_id, member_groups_to_delete) unless member_groups_to_delete.empty?
    add_member_groups_to_project(project_id, member_groups_to_add) unless member_groups_to_add.empty?
  end

  def remove_member_groups_from_project(project_id, group_names)
    remove_members_from_project(project_id, group_names)
  end

  def add_member_groups_to_project(project_id, member_group_names)
    member_group_names.sort!
    member_group_names.each do |name|
      gid = get_usergroup_id_by_name(name)
      opts = { project_member: { role_id: 2, member_group: { "id": gid } } } # role_id 2 == 'Developer'
      post_project_members(project_id, opts)
    end
  end

  def get_usergroup_id_by_name(name)
    api_instance = self.class.do_login
    all_groups = api_instance.usergroups_get()
    name.downcase!
    x = all_groups.select { |g| g.group_name.downcase! == name }
    x[0].id
  end

  def destroy
    project = get_project_with_name(resource[:name])
    delete_project_with_id(project.project_id)
  end

  def delete_project_with_id(id)
    api_instance = self.class.do_login
    begin
      api_instance.projects_project_id_delete(id)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->projects_project_id_delete: #{e}"
    end
  end
end
