# frozen_string_literal: true

Puppet::Type.type(:harbor_replication_policy).provide(:swagger) do
  mk_resource_methods

  def self.instances
    api_instance = do_login

    replication_policies = api_instance.replication_policies_get()

    replication_policies.map do |replication_policy|
      new(
        ensure: :present,
        name: replication_policy.name,
        description: replication_policy.description,
        src_registry: replication_policy.src_registry.name,
        dest_registry: replication_policy.dest_registry,
        dest_namespace: replication_policy.dest_namespace,
        trigger: replication_policy.trigger,
        filters: replication_policy.filters,
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

  def create
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
