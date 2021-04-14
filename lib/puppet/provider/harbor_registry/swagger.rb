# frozen_string_literal: true
require 'puppet_x/walkamongus/harbor/client'

Puppet::Type.type(:harbor_registry).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor registries'

  def self.instances
    api_instance = do_login
    registries = api_instance[:legacy_client].registries_get
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
     PuppetX::Walkamongus::Harbor::Client.do_login
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
      registries = api_instance[:legacy_client].registries_get(opts)
      registries.nil? ? [] : registries
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end
  end

  def filter_registry_with_name(all_registries, name)
    filtered_registries = all_registries.select { |r| r.name == name }
    filtered_registries.empty? ? nil : filtered_registries[0]
  end

  def create
    api_instance = self.class.do_login
    if api_instance[:api_version] == 2
      nr = Harbor2LegacyClient::Registry.new(
        name:        resource[:name],
        description: resource[:description],
        url:         resource[:url],
        type:        resource[:type],
        insecure:    cast_symbol_to_bool(resource[:insecure]),
        credential:  create_credential)
    else
      nr = Harbor1Client::Registry.new(
        name:        resource[:name],
        description: resource[:description],
        url:         resource[:url],
        type:        resource[:type],
        insecure:    cast_symbol_to_bool(resource[:insecure]),
        credential:  create_credential)
    end
    post_registry(nr)
  end

  def create_credential
    api_instance = self.class.do_login
    if cast_symbol_to_bool(resource[:set_credential])
      if api_instance[:api_version] == 2
        Harbor2LegacyClient::RegistryCredential.new(
          type:          'basic',
          access_key:    resource[:access_key],
          access_secret: resource[:access_secret])
      else
        Harbor1Client::RegistryCredential.new(
          type:          'basic',
          access_key:    resource[:access_key],
          access_secret: resource[:access_secret])
      end
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
    api_instance = self.class.do_login
    begin
      api_instance[:legacy_client].registries_post(registry)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_post: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->registries_post: #{e}"
    end
  end

  def description=(_value)
    api_instance = self.class.do_login
    if api_instance[:api_version] == 2
      registry_target = Harbor2LegacyClient::PutRegistry.new(description: resource[:description])
    else
      registry_target = Harbor1Client::PutRegistry.new(description: resource[:description])
    end
    put_registry(registry_target)
  end

  def put_registry(registry)
    api_instance = self.class.do_login
    id = get_registry_id_by_name(resource[:name])
    begin
      api_instance[:legacy_client].registries_id_put(id, registry)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_put: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_put: #{e}"
    end
  end

  def get_registry_id_by_name(name)
    registry = get_registry_with_name(name)
    registry.id
  end

  def insecure=(_value)
    api_instance = self.class.do_login
    insecure_bool = cast_to_bool(resource[:insecure].to_s)
    if api_instance[:api_version] == 2
      registry_target = Harbor2LegacyClient::PutRegistry.new(insecure: insecure_bool)
    else
      registry_target = Harbor1Client::PutRegistry.new(insecure: insecure_bool)
    end
    put_registry(registry_target)
  end

  def url=(_value)
    api_instance = self.class.do_login
    if api_instance[:api_version] == 2
      registry_target = Harbor2LegacyClient::PutRegistry.new(url: resource[:url])
    else
      registry_target = Harbor1Client::PutRegistry.new(url: resource[:url])
    end
    put_registry(registry_target)
  end

  def destroy
    api_instance = self.class.do_login
    registry_id = get_registry_id_by_name(resource[:name])

    begin
      api_instance[:legacy_client].registries_id_delete(registry_id)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_delete: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_delete: #{e}"
    end
  end
end
