# frozen_string_literal: true

Puppet::Type.type(:harbor_replication_policy).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor replication policies'

  def self.instances
    all_policies = get_all_policies
    all_policies.map do |p|
      new(
        ensure:         :present,
        name:           p.name,
        description:    p.description,
        src_registry:   p.src_registry.name,
        dest_registry:  p.dest_registry,
        dest_namespace: p.dest_namespace,
        trigger:        trigger_object_to_hash(p.trigger),
        filters:        filter_objects_to_array(p.filters),
        deletion:       cast_bool_to_symbol(p.deletion),
        override:       cast_bool_to_symbol(p.override),
        enabled:        cast_bool_to_symbol(p.enabled),
        provider:       :swagger,
      )
    end
  end

  def self.get_all_policies
    api_instance = do_login
    api_instance[:legacy_client].replication_policies_get
  end

  def self.cast_bool_to_symbol(foo)
    foo ? :true : :false
  end

  def self.prefetch(resources)
    instances.each do |int|
      if (resource = resources[int.name])
        resource.provider = int
      end
    end
  end

  def self.filter_objects_to_array(filters)
    filter_arry = []
    filters.each do |fil|
      filter_arry << { 'type' => fil.type, 'value' => fil.value }
    end
    filter_arry
  end

  def self.trigger_object_to_hash(trigger)
    hsh = { 'type' => trigger.type }
    if trigger.trigger_settings
      hsh['trigger_settings'] = { 'cron' => trigger.trigger_settings.cron }
    end
    hsh
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

  def exists?
    policy = get_replication_policy_with_name(resource[:name])
    !policy.nil?
  end

  def get_replication_policy_with_name(name)
    policies = get_policies_containing_name(name)
    filter_policy_with_name(policies, name)
  end

  def get_policies_containing_name(name)
    # This might return also other policies which contain the name, e.g. when searching for 'demo'
    # and there is also 'demo_push' the resulting array will contain both.
    opts = { name: name, }
    get_policies_with_opts(opts)
  end

  def get_policies_with_opts(opts)
    api_instance = self.class.do_login
    begin
      api_instance[:legacy_client].replication_policies_get(opts)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->replication_policies_get: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->replication_policies_get: #{e}"
    end
  end

  def filter_policy_with_name(policies, name)
    filtered = policies.select { |p| p.name == name }
    filtered.empty? ? nil : filtered[0]
  end

  def create
    policy = create_policy_from_resource
    post_replication_policy(policy)
  end

  def create_policy_from_resource
    remote_registry_info = get_registry_info_by_name(resource[:remote_registry])
    mode = resource[:replication_mode].to_s
    SwaggerClient::ReplicationPolicy.new(
      name:           resource[:name],
      description:    resource[:description],
      deletion:       cast_symbol_to_bool(resource[:deletion]),
      enabled:        cast_symbol_to_bool(resource[:enabled]),
      override:       cast_symbol_to_bool(resource[:override]),
      dest_registry:  (mode == 'push') ? remote_registry_info : nil,
      src_registry:   (mode == 'pull') ? remote_registry_info : nil,
      dest_namespace: resource[:dest_namespace],
      trigger:        create_replication_trigger_object(resource[:trigger]),
      filters:        create_replication_filter_object(resource[:filters]),
    )
  end

  def get_registry_info_by_name(registry_name)
    api_instance = self.class.do_login
    opts = { name: registry_name }

    begin
      registries = api_instance[:legacy_client].registries_get(opts)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end

    filtered = registries.select { |r| r.name == registry_name }
    filtered.empty? ? nil : filtered[0]
  end

  def cast_symbol_to_bool(foo)
    foo.to_s == 'true'
  end

  def create_replication_filter_object(filters)
    all_filters = []
    filters.each do |filter|
      fil = SwaggerClient::ReplicationFilter.new(filter)
      all_filters << fil
    end
    all_filters
  end

  def create_replication_trigger_object(trigger)
    SwaggerClient::ReplicationTrigger.new(trigger)
  end

  def post_replication_policy(policy)
    api_instance = self.class.do_login
    begin
      api_instance[:legacy_client].replication_policies_post(policy)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->replication_policies_post: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->replication_policies_post: #{e}"
    end
  end

  def flush
    update_replication_policy_param(resource)
  end

  def update_replication_policy_param(resource)
    policy = create_policy_from_resource
    put_replication_policy(policy)
  end

  def put_replication_policy(policy)
    id = get_replication_policy_id_by_name(policy.name)
    api_instance = self.class.do_login
    begin
      api_instance[:legacy_client].replication_policies_id_put(id, policy)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->replication_policies_id_put: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->replication_policies_id_put: #{e}"
    end
  end

  def get_replication_policy_id_by_name(name)
    policy = get_replication_policy_with_name(name)
    policy.id
  end

  def destroy
    api_instance = self.class.do_login
    id = get_replication_policy_id_by_name(resource[:name])
    begin
      api_instance[:legacy_client].replication_policies_id_delete(id)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->replication_policy_id_delete: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->replication_policy_id_delete: #{e}"
    end
  end
end
