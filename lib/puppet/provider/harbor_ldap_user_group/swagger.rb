# frozen_string_literal: true

Puppet::Type.type(:harbor_ldap_user_group).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor LDAP user group'

  def self.instances
    api_instance = do_login
    groups = api_instance[:legacy_client].usergroups_get
    if groups.nil?
      []
    else
      groups.map do |group|
        new(
          ensure:        :present,
          group_name:    group.group_name,
          ldap_group_dn: group.ldap_group_dn,
          provider:      :swagger,
        )
      end
    end
  end

  def self.do_login
    require 'yaml'
    my_config = YAML.load_file('/etc/puppetlabs/swagger.yaml')
    require 'harbor2_client'
    require 'harbor2_legacy_client'
    require 'harbor1_client'
    if my_config.fetch('api_version', 1) == 2
      Harbor2Client.configure do |config|
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
      Harbor2LegacyClient.configure do |config|
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
      api_instance = {
        :api_version => 2,
        :client => Harbor2Client::ProjectApi.new,
        :legacy_client => Harbor2LegacyClient::ProductsApi.new
      }
    else
      Harbor1Client.configure do |config|
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
      client = Harbor1Client::ProductsApi.new
      api_instance = {
        :api_version => 1,
        :client => client,
        :legacy_client => client
      }
    end
    api_instance
  end

  def self.prefetch(resources)
    instances.each do |int|
      if (resource = resources[int.ldap_group_dn])
        resource.provider = int
      end
    end
  end

  def exists?
    group = get_group_with_ldap_dn(resource[:ldap_group_dn])
    !group.nil?
  end

  def get_group_with_ldap_dn(dn)
    groups = get_groups_containing_ldap_dn(dn)
    filtered = filter_group_matching_ldap_dn(groups, dn)
    filtered
  end

  def get_groups_containing_ldap_dn(dn)
    opts = { ldap_group_dn: dn }
    get_groups_with_opts(opts)
  end

  def get_groups_with_opts(opts)
    api_instance = self.class.do_login
    begin
      groups = api_instance[:legacy_client].usergroups_get(opts)
      groups.nil? ? [] : groups
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->usergroups_get: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->usergroups_get: #{e}"
    end
  end

  def filter_group_matching_ldap_dn(all_groups, dn)
    filtered = all_groups.select { |p| p.ldap_group_dn == dn }
    filtered.empty? ? nil : filtered[0]
  end

  def create
    api_instance = self.class.do_login
    if api_instance[:api_version] == 2
      group = Harbor2LegacyClient::UserGroup.new(
        group_name: resource[:group_name],
        group_type: 1,
        ldap_group_dn: resource[:ldap_group_dn],
      )
    else
      group = Harbor1Client::UserGroup.new(
        group_name: resource[:group_name],
        group_type: 1,
        ldap_group_dn: resource[:ldap_group_dn],
      )
    end
    begin
      api_instance[:legacy_client].usergroups_post(opts = {usergroup: group})
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->usergroups_post: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->usergroups_post: #{e}"
    end
  end

  def group_name=(_value)
    api_instance = self.class.do_login
    if api_instance[:api_version] == 2
      group = Harbor2LegacyClient::UserGroup.new(
        group_name: _value,
        group_type: 1,
        ldap_group_dn: resource[:ldap_group_dn],
      )
    else
      group = Harbor1Client::UserGroup.new(
        group_name: _value,
        group_type: 1,
        ldap_group_dn: resource[:ldap_group_dn],
      )
    end
    id = get_id_of_group_with_ldap_dn(resource[:ldap_group_dn])
    update_group_with_id(id, group)
  end

  def get_id_of_group_with_ldap_dn(dn)
    group = get_group_with_ldap_dn(dn)
    group.id
  end

  def update_group_with_id(id, group)
    api_instance = self.class.do_login
    begin
      api_instance[:legacy_client].usergroups_group_id_put(id, opts = {usergroup: group})
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->usergroups_group_id_put: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->usergroups_group_id_put: #{e}"
    end
  end

  def destroy
    group = get_group_with_ldap_dn(resource[:ldap_group_dn])
    delete_group_with_id(group.id)
  end

  def delete_group_with_id(id)
    api_instance = self.class.do_login
    begin
      api_instance[:legacy_client].usergroups_group_id_delete(id)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->usergroups_group_id_delete: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->usergroups_group_id_delete: #{e}"
    end
  end
end
