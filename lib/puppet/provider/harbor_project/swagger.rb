# frozen_string_literal: true
require 'puppet_x/walkamongus/harbor/client'

Puppet::Type.type(:harbor_project).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor projects'

  def self.instances
    projects = get_all_projects
    projects.map do |project|
      new(
        ensure:        :present,
        name:          project.name,
        public:        project.metadata.public,
        auto_scan:     project.metadata.auto_scan.nil? ? :false : project.metadata.auto_scan.to_sym,
        members:       get_project_member_names(project.project_id),
        member_groups: get_project_member_group_names(project.project_id),
        guests:        get_project_guest_names(project.project_id),
        guest_groups:  get_project_guest_group_names(project.project_id),
        provider:      :swagger,
      )
    end
  end

  def self.get_all_projects
    projects = []
    page = 1
    begin
      page_projects = get_projects_with_opts({:page => page})
      projects += page_projects
      page += 1
    end until page_projects.empty?
    projects
  end

  def self.get_projects_with_opts(opts)
    api_instance = do_login
    begin
      if api_instance[:api_version] == 2
        projects = api_instance[:client].list_projects(opts)
        projects.nil? ? [] : projects
      else
        projects = api_instance[:client].projects_get(opts)
        projects.nil? ? [] : projects
      end
    end
  end

  def self.do_login
     PuppetX::Walkamongus::Harbor::Client.do_login
  end

  def self.get_project_member_names(project_id)
    members = get_project_members_with_entity_type(project_id, 'u')
    names = members.map { |m| m.entity_name }
    names.sort!.delete('admin')
    names
  end

  def self.get_project_members_with_entity_type(project_id, type)
    api_instance = do_login
    members_and_groups = api_instance[:legacy_client].projects_project_id_members_get(project_id)
    members_and_groups.select { |m| m.entity_type == type }
  end

  def self.get_project_member_group_names(project_id)
    members = get_project_members_with_entity_type(project_id, 'g')
    names = members.map { |m| m.entity_name }
    names.sort!
    names
  end

  def self.prefetch(resources)
    instances.each do |int|
      if (resource = resources[int.name])
        resource.provider = int
      end
    rescue Harbor2Client::ApiError => e
      puts "Exception when calling ProjectApi->list_projects: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->projects_get: #{e}"
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
    self.class.get_projects_with_opts(opts)
  end

  def create
    api_instance = self.class.do_login
    if api_instance[:api_version] == 2
      np = Harbor2Client::ProjectReq.new(
        project_name: resource[:name],
        metadata: {
          public:    resource[:public],
          auto_scan: resource[:auto_scan].to_s,
        }
      )
    else
      np = Harbor1Client::ProjectReq.new(
        project_name: resource[:name],
        metadata: {
          public:    resource[:public],
          auto_scan: resource[:auto_scan].to_s,
        }
      )
    end
    begin
      if api_instance[:api_version] == 2
        api_instance[:client].create_project(np)
      else
        api_instance[:client].projects_post(np)
      end
    rescue Harbor2Client::ApiError => e
      puts "Exception when calling ProjectApi->create_project: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->projects_post: #{e}"
    end
    return nil if resource[:members].nil? and resource[:member_groups].nil? and resource[:guests].nil? and resource[:guest_groups].nil?
    id = get_project_id_by_name(resource[:name])
    unless resource[:members].nil?
      members = resource[:members]
      add_members_to_project(id, members)
    end
    unless resource[:member_groups].nil?
      member_groups = resource[:member_groups]
      add_member_groups_to_project(id, member_groups)
    end
    unless resource[:guest].nil?
      guests = resource[:guests]
      add_guests_to_project(id, guests)
    end
    unless resource[:guest_groups].nil?
      guest_groups = resource[:guest_groups]
      add_guest_groups_to_project(id, guest_groups)
    end
  ends

  def get_project_id_by_name(project_name)
    project = get_project_with_name(resource[:name])
    project.project_id
  end

  def public=(_value)
    project = {
      "metadata": {
        "public": resource[:public],
      }
    }
    put_project(project)
  end

  def put_project(project_hash)
    api_instance = self.class.do_login
    id = get_project_id_by_name(resource[:name])
    begin
      if api_instance[:api_version] == 2
        api_instance[:client].update_project(id, project_hash, opts = {})
      else
        api_instance[:client].projects_project_id_put(id, project_hash, opts = {})
      end
    rescue Harbor2Client::ApiError => e
      puts "Exception when calling ProjectApi->update_project: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->projects_project_id_put: #{e}"
    end
  end

  def auto_scan=(_value)
    project = {
      "metadata": {
        "auto_scan": resource[:auto_scan].to_s,
      }
    }
    put_project(project)
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
      api_instance[:legacy_client].projects_project_id_members_mid_delete(project_id, member_id)
    end
  end

  def get_project_member_id_by_name(project_id, name)
    api_instance = self.class.do_login
    opts = {
      entityname: name,
    }
    result = api_instance[:legacy_client].projects_project_id_members_get(project_id, opts)
    result[0].id
  end

  def add_members_to_project(project_id, member_names)
    member_names.sort!
    member_names.each do |name|
      opts = { project_member: { role_id: 2, member_user: { "username": name.to_s } } } # role_id 2 == 'Developer'
      post_project_members(project_id, opts)
    end
  end

  def add_members_to_project(project_id, guest_names)
    guest_names.sort!
    guest_names.each do |name|
      opts = { project_member: { role_id: 3, member_user: { "username": name.to_s } } } # role_id 3 == 'Guest'
      post_project_members(project_id, opts)
    end
  end

  def post_project_members(project_id, opts)
    api_instance = self.class.do_login
    begin
      api_instance[:legacy_client].projects_project_id_members_post(project_id, opts)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->projects_project_id_members_post: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->projects_project_id_members_post: #{e}"
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

  def guest_groups=(_value)
    project_id = get_project_id_by_name(resource[:name])
    curren-guest_groups = self.class.get_project_member_group_names(project_id)
    guest_groups = resource[:guest_groups]
    guest_groups_to_delete = current_guest_groups - guest_groups
    guest_groups_to_add = guest_groups - current_guest_groups
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

  def add_guest_groups_to_project(project_id, guest_group_names)
    guest_group_names.sort!
    guest_group_names.each do |name|
      gid = get_usergroup_id_by_name(name)
      opts = { project_member: { role_id: 3, member_group: { "id": gid } } } # role_id 3 == 'Guest'
      post_project_members(project_id, opts)
    end
  end

  def get_usergroup_id_by_name(name)
    api_instance = self.class.do_login
    all_groups = api_instance[:legacy_client].usergroups_get()
    x = all_groups.select { |g| g.group_name == name }
    x[0].id
  end

  def destroy
    project = get_project_with_name(resource[:name])
    delete_project_with_id(project.project_id)
  end

  def delete_project_with_id(id)
    api_instance = self.class.do_login
    begin
      if api_instance[:api_version] == 2
        api_instance[:client].delete_project(id)
      else
        api_instance[:client].projects_project_id_delete(id)
      end
    rescue Harbor2Client::ApiError => e
      puts "Exception when calling ProductsApi->delete_project: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->projects_project_id_delete: #{e}"
    end
  end
end
