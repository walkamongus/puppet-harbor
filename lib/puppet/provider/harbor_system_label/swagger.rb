# frozen_string_literal: true

Puppet::Type.type(:harbor_system_label).provide(:swagger) do
  mk_resource_methods

  def self.instances
    api_instance = do_login

    labels = api_instance.labels_get(scope="g")

    labels.map do |label|
      new(
        ensure: :present,
        name: label.name,
        description: label.description,
        color: label.color,
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

  def get_label_id_by_name(label_name)
    api_instance = do_login

    opts = {
      name: label_name,
    }

    begin
      label = api_instance.labels_get("g", opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_get: #{e}"
    end

    label[0].id
  end

  def exists?
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    begin
      result = api_instance.labels_get("g", opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_get: #{e}"
    end

    if result.empty?
      false
    else
      true
    end
  end

  def create
    api_instance = do_login

    nl = SwaggerClient::Label.new(name: resource[:name], description: resource[:description], color: resource[:color], scope: "g")

    begin
      api_instance.labels_post(nl)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_post: #{e}"
    end
  end

  def destroy
    api_instance = do_login

    label_id = get_label_id_by_name(resource[:name])

    begin
      api_instance.labels_id_delete(label_id)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_id_delete: #{e}"
    end
  end

end
