# frozen_string_literal: true

Puppet::Type.type(:harbor_registry).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor registries'

  def self.instances
    api_instance = do_login
    registries = api_instance.registries_get
    if registries.nil?
      []
    else
      registries.map do |registry|
        new(
          ensure:      :present,
          name:        registry.name,
          description: registry.description,
          url:         registry.url,
          insecure:    cast_bool_to_symbol(registry.insecure),
          provider:    :swagger,
        )
      end
    end
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

  def exists?
    registry = get_registry_with_name(resource[:name])
    !registry.nil?
  end

  def get_registry_with_name(name)
    registries = get_registries_containing_name(resource[:name])
    filter_registry_with_name(registries, name)
  end

  def get_registries_containing_name(name)
    opts = { name: name }
    api_instance = self.class.do_login
    begin
      registries = api_instance.registries_get(opts)
      registries.nil? ? [] : registries
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end
  end

  def filter_registry_with_name(all_registries, name)
    filtered_registries = all_registries.select { |r| r.name == name }
    filtered_registries.empty? ? nil : filtered_registries[0]
  end

  def create
    nr = SwaggerClient::Registry.new(
      name:       resource[:name],
      url:        resource[:url],
      type:       resource[:type],
      insecure:   cast_symbol_to_bool(resource[:insecure]),
      credential: create_credential)
    post_registry(nr)
  end

  def create_credential
    if cast_symbol_to_bool(resource[:set_credential])
      SwaggerClient::RegistryCredential.new(
        type:          'basic',
        access_key:    resource[:access_key],
        access_secret: resource[:access_secret])
    else
      nil
    end
  end

  def cast_symbol_to_bool(foo)
    foo.to_s == 'true'
  end

  def cast_to_bool(foo)
    return true if foo == 'true'
    return false if foo == 'false'
  end

  def post_registry(registry)
    api = self.class.do_login
    begin
      api.registries_post(registry)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_post: #{e}"
    end
  end

  def description=(_value)
    repo_target = SwaggerClient::PutRegistry.new(description: resource[:description])
    put_registry(repo_target)
  end

  def put_registry(registry)
    api_instance = self.class.do_login
    id = get_registry_id_by_name(resource[:name])
    begin
      api_instance.registries_id_put(id, put_registry)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_put: #{e}"
    end
  end

  def get_registry_id_by_name(name)
    registry = get_registry_with_name(name)
    registry.id
  end

  def insecure=(_value)
    insecure_bool = cast_to_bool(resource[:insecure].to_s)
    repo_target = SwaggerClient::PutRegistry.new(insecure: insecure_bool)
    put_registry(repo_target)
  end

  def url=(_value)
    repo_target = SwaggerClient::PutRegistry.new(url: resource[:url])
    put_registry(repo_target)
  end

  def destroy
    api_instance = self.class.do_login
    registry_id = get_registry_id_by_name(resource[:name])

    begin
      api_instance.registries_id_delete(registry_id)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_delete: #{e}"
    end
  end
end
