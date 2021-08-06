# frozen_string_literal: true
require 'puppet_x/walkamongus/harbor/harbor'

class PuppetX::Walkamongus::Harbor::Client

  def self.do_login
    require 'yaml'
    config = YAML.load_file('/etc/puppetlabs/swagger.yaml')
    if config.fetch('api_version', 1) == 2
      api_instance = self.do_login_api_v2(config)
    else
      api_instance = self.do_login_api_v1(config)
    end
    api_instance
  end

  def self.do_login_api_v2(client_config)
    require 'harbor1_client'
    require 'harbor2_client'
    require 'harbor2_legacy_client'
    Harbor2Client.configure do |config|
      config.username = client_config['username']
      config.password = client_config['password']
      config.scheme = client_config['scheme']
      config.verify_ssl = client_config['verify_ssl']
      config.verify_ssl_host = client_config['verify_ssl_host']
      config.ssl_ca_cert = client_config['ssl_ca_cert']
      if client_config['host']
        config.host = client_config['host']
      end
    end
    Harbor2LegacyClient.configure do |config|
      config.username = client_config['username']
      config.password = client_config['password']
      config.scheme = client_config['scheme']
      config.verify_ssl = client_config['verify_ssl']
      config.verify_ssl_host = client_config['verify_ssl_host']
      config.ssl_ca_cert = client_config['ssl_ca_cert']
      if client_config['host']
        config.host = client_config['host']
      end
    end
    api_instance = {
      :api_version => 2,
      :client => Harbor2Client::ProjectApi.new,
      :legacy_client => Harbor2LegacyClient::ProductsApi.new
    }
  end

  def self.do_login_api_v1(client_config)
    require 'harbor1_client'
    require 'harbor2_legacy_client'
    Harbor1Client.configure do |config|
      config.username = client_config['username']
      config.password = client_config['password']
      config.scheme = client_config['scheme']
      config.verify_ssl = client_config['verify_ssl']
      config.verify_ssl_host = client_config['verify_ssl_host']
      config.ssl_ca_cert = client_config['ssl_ca_cert']
      if client_config['host']
        config.host = client_config['host']
      end
    end
    client = Harbor1Client::ProductsApi.new
    api_instance = {
      :api_version => 1,
      :client => client,
      :legacy_client => client
    }
  end

end
