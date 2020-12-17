# frozen_string_literal: true

Puppet::Type.type(:harbor_system_label).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor system-level labels'

  def self.instances
    api_instance = do_login
    labels = api_instance[:legacy_client].labels_get('g')
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

  def get_label_id_by_name(label_name)
    api_instance = self.class.do_login
    opts = {
      name: label_name,
    }
    begin
      label = api_instance[:legacy_client].labels_get('g', opts)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_get: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->labels_get: #{e}"
    end
    label[0].id
  end

  def name=(_value)
    api_instance = self.class.do_login
    id = get_label_id_by_name(resource[:name])
    label = {
      "name": resource[:name],
      "description": resource[:description],
      "color": resource[:color],
    }
    begin
      api_instance[:legacy_client].labels_id_put(id, label)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_id_put for color: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->labels_id_put for color: #{e}"
    end
  end

  def description=(_value)
    api_instance = self.class.do_login
    id = get_label_id_by_name(resource[:name])
    label = {
      "name": resource[:name],
      "description": resource[:description],
      "color": resource[:color],
    }
    begin
      api_instance[:legacy_client].labels_id_put(id, label)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_id_put for color: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->labels_id_put for color: #{e}"
    end
  end

  def color=(_value)
    api_instance = self.class.do_login
    id = get_label_id_by_name(resource[:name])
    label = {
      "name": resource[:name],
      "description": resource[:description],
      "color": resource[:color],
    }
    begin
      api_instance[:legacy_client].labels_id_put(id, label)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_id_put for color: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->labels_id_put for color: #{e}"
    end
  end

  def exists?
    api_instance = self.class.do_login
    opts = {
      name: resource[:name],
    }
    begin
      result = api_instance[:legacy_client].labels_get('g', opts)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_get: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->labels_get: #{e}"
    end
    if result.empty?
      false
    else
      true
    end
  end

  def create
    api_instance = self.class.do_login
    if api_instance[:api_version] == 2
      nl = Harbor2LegacyClient::Label.new(name: resource[:name], description: resource[:description], color: resource[:color], scope: 'g')
    else
      nl = Harbor1Client::Label.new(name: resource[:name], description: resource[:description], color: resource[:color], scope: 'g')
    end
    begin
      api_instance[:legacy_client].labels_post(nl)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_post: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->labels_post: #{e}"
    end
  end

  def destroy
    api_instance = self.class.do_login
    label_id = get_label_id_by_name(resource[:name])
    begin
      api_instance[:legacy_client].labels_id_delete(label_id)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->labels_id_delete: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->labels_id_delete: #{e}"
    end
  end

end
