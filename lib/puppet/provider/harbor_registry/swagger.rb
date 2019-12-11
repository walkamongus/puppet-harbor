# frozen_string_literal: true

Puppet::Type.newtype(:harbor_registry) do
  desc 'Manage Harbor registry endpoints'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Name of the Registry'
  end

  newproperty(:description) do
  end

  newproperty(:url) do
  end

  newproperty(:access_key) do
  end

  newproperty(:access_secret) do
  end

  newproperty(:insecure) do
    defaultto :false
    newvalues(:true, :false)
  end
end

[root@us01vlhrbr006 AKA harbor-ny2-lab harbor_registry]# cat swagger.rb
# frozen_string_literal: true

Puppet::Type.type(:harbor_registry).provide(:swagger) do
  mk_resource_methods

  def self.instances
    api_instance = do_login

    registries = api_instance.registries_get()

    registries.map do |registry|
      new(
        ensure: :present,
        name: registry.name,
        description: registry.description,
        url: registry.url,
        access_key: registry.credential.access_key,
        access_secret: registry.credential.access_secret,
        insecure: registry.insecure,
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

  def exists?
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    begin
      result = api_instance.registries_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end

    if result.nil?
      false
    else
      true
    end
  end

  def create
    api_instance = do_login

    insecure_bool = cast_insecure_to_bool(resource[:insecure])

    nr = SwaggerClient::Registry.new(name: resource[:name], url: resource[:url], insecure: insecure_bool, type: 'harbor', credential: { access_key: resource[:access_key], access_secret: resource[:access_secret] })

    begin
      api_instance.registries_post(nr)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_post: #{e}"
    end
  end

  def cast_insecure_to_bool(insecure)
    if insecure == "true"
      insecure_bool = insecure == insecure
    end

    if insecure == "false"
      insecure_bool = insecure != insecure
    end

    insecure_bool
  end

  def url
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    begin
      registry = api_instance.registries_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end

    registry[0].url
  end

  def url=(_value)
    api_instance = do_login
    id = get_registry_id_by_name(resource[:name])
    repo_target = {
      url: resource[:url],
    }

    begin
      api_instance.registries_id_put(id, repo_target)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_put: #{e}"
    end
  end

  def access_secret
    return '*****'
  end

  def insecure
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    begin
      registry = api_instance.registries_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end

    registry[0].insecure
  end

  def insecure=(_value)
    api_instance = do_login
    id = get_registry_id_by_name(resource[:name])

    insecure_bool = cast_insecure_to_bool(resource[:insecure])

    repo_target = {
      insecure: insecure_bool,
    }

    api_instance.registries_id_put(id, repo_target)
  end

  def get_registry_id_by_name(name)
    api_instance = do_login

    opts = {
      name: name,
    }

    begin
      registry = api_instance.registries_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end

    registry[0].id
  end


  def destroy
    api_instance = do_login

    registry_id = get_registry_id_by_name(resource[:name])

    begin
      api_instance.registries_id_delete(registry_id)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_delete: #{e}"
    end
  end
end
