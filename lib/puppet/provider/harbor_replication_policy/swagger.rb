# frozen_string_literal: true

Puppet::Type.type(:harbor_replication_policy).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor replication policies'

  def self.instances
    api_instance = do_login

    replication_policies = api_instance.replication_policies_get

    replication_policies.map do |replication_policy|
      new(
        ensure: :present,
        name: replication_policy.name,
        description: replication_policy.description,
        src_registry: replication_policy.src_registry.name,
        dest_registry: replication_policy.dest_registry,
        dest_namespace: replication_policy.dest_namespace,
        trigger: trigger_object_to_hash(replication_policy.trigger),
        filters: filter_objects_to_array(replication_policy.filters),
        deletion: replication_policy.deletion,
        override: replication_policy.override,
        enabled: replication_policy.enabled,
        provider: :swagger,
      )
    end
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
    if trigger.trigger_settings
      hsh = { 'type' => trigger.type, 'trigger_settings' => { 'cron' => trigger.trigger_settings.cron } }
    end
    hsh
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

  def get_replication_policy_id_by_name(replication_policy_name)
    api_instance = do_login

    opts = {
      name: replication_policy_name,
    }

    begin
      replication_policy = api_instance.replication_policies_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->replication_policies_get: #{e}"
    end

    replication_policy[0].id
  end

  def exists?
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    begin
      result = api_instance.replication_policies_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->replication_policies_get: #{e}"
    end

    if result.empty?
      false
    else
      true
    end
  end

  def cast_to_bool(foo)
    return true if foo == 'true'
    return false if foo == 'false'
  end

  def get_registry_id_by_name(registry_name)
    api_instance = do_login

    opts = {
      name: registry_name,
    }

    begin
      registry = api_instance.registries_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end

    registry[0].id
  end

  def get_registry_info_by_name(registry_name)
    api_instance = do_login

    opts = {
      name: registry_name,
    }

    begin
      registry = api_instance.registries_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end

    registry[0]
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
    tr = SwaggerClient::ReplicationTrigger.new(trigger)
    tr
  end

  def create
    api_instance = do_login

    if resource[:deletion]
      deletion_bool = cast_to_bool(resource[:deletion].to_s)
    end

    if resource[:enabled]
      enabled_bool = cast_to_bool(resource[:enabled].to_s)
    end

    if resource[:override]
      override_bool = cast_to_bool(resource[:override].to_s)
    end

    if resource[:replication_mode].to_s == 'push'
      dest_registry_info = get_registry_info_by_name(resource[:remote_registry])
      fil = create_replication_filter_object(resource[:filters])
      tr = create_replication_trigger_object(resource[:trigger])
      np = SwaggerClient::ReplicationPolicy.new(
        name: resource[:name],
        deletion: deletion_bool,
        enabled: enabled_bool,
        override: override_bool,
        dest_registry: dest_registry_info,
        trigger: tr,
        filters: fil,
      )
    end

    if resource[:replication_mode].to_s == 'pull'
      src_registry_info = get_registry_info_by_name(resource[:remote_registry])
      fil = create_replication_filter_object(resource[:filters])
      tr = create_replication_trigger_object(resource[:trigger])
      np = SwaggerClient::ReplicationPolicy.new(
        name: resource[:name],
        deletion: deletion_bool,
        enabled: enabled_bool,
        override: override_bool,
        src_registry: src_registry_info,
        trigger: tr,
        filters: fil,
      )
    end

    begin
      api_instance.replication_policies_post(np)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->replication_policies_post: #{e}"
    end
  end

  def destroy
    api_instance = do_login

    replication_policy_id = get_replication_policy_id_by_name(resource[:name])

    begin
      api_instance.replication_policies_id_delete(replication_policy_id)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->replication_policy_id_delete: #{e}"
    end
  end
end
