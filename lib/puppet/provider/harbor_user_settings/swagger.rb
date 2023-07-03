# frozen_string_literal: true
require 'puppet_x/walkamongus/harbor/client'

Puppet::Type.type(:harbor_user_settings).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for harbor system configurations'

  def do_login
     PuppetX::Walkamongus::Harbor::Client.do_login
  end

  def get_config(api_instance)
    begin
      config = api_instance[:legacy_client].configurations_get
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_get: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_get: #{e}"
    end
    config
  end

  def auth_mode
    api_instance = do_login
    config = get_config(api_instance)
    config.auth_mode.value
  end

  def auth_mode=(_value)
    api_instance = do_login

    configurations = {
      "auth_mode": resource[:auth_mode],
    }

    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for auth_mode: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for auth_mode: #{e}"
    end
  end

  def ldap_url
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_url.value
  end

  def ldap_url=(_value)
    api_instance = do_login
    configurations = {
      "ldap_url": resource[:ldap_url],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_url: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_url: #{e}"
    end
  end

  def ldap_base_dn
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_base_dn.value
  end

  def ldap_base_dn=(_value)
    api_instance = do_login
    configurations = {
      "ldap_base_dn": resource[:ldap_base_dn],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_base_dn: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_base_dn: #{e}"
    end
  end

  def ldap_filter
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_filter.value
  end

  def ldap_filter=(_value)
    api_instance = do_login
    configurations = {
      "ldap_filter": resource[:ldap_filter],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_filter: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_filter: #{e}"
    end
  end

  def ldap_scope
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_scope.value.to_s
  end

  def ldap_scope=(_value)
    api_instance = do_login
    configurations = {
      "ldap_scope": resource[:ldap_scope],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_scope: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_scope: #{e}"
    end
  end

  def ldap_uid
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_uid.value
  end

  def ldap_uid=(_value)
    api_instance = do_login
    configurations = {
      "ldap_uid": resource[:ldap_uid],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_uid: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_uid: #{e}"
    end
  end

  def ldap_search_dn
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_search_dn.value
  end

  def ldap_search_dn=(_value)
    api_instance = do_login
    configurations = {
      "ldap_search_dn": resource[:ldap_search_dn],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_search_dn: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_search_dn: #{e}"
    end
  end

  def ldap_timeout
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_timeout.value
  end

  def ldap_timeout=(_value)
    api_instance = do_login
    configurations = {
      "ldap_timeout": resource[:ldap_timeout],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_timeout: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_timeout: #{e}"
    end
  end

  def ldap_group_attribute_name
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_group_attribute_name.value
  end

  def ldap_group_attribute_name=(_value)
    api_instance = do_login
    configurations = {
      "ldap_group_attribute_name": resource[:ldap_group_attribute_name],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_attribute_name: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_attribute_name: #{e}"
    end
  end

  def ldap_group_base_dn
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_group_base_dn.value
  end

  def ldap_group_base_dn=(_value)
    api_instance = do_login
    configurations = {
      "ldap_group_base_dn": resource[:ldap_group_base_dn],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_base_dn: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_base_dn: #{e}"
    end
  end

  def ldap_group_search_filter
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_group_search_filter.value
  end

  def ldap_group_search_filter=(_value)
    api_instance = do_login
    configurations = {
      "ldap_group_search_filter": resource[:ldap_group_search_filter],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_search_filter: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_search_filter: #{e}"
    end
  end

  def ldap_group_search_scope
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_group_search_scope.value.to_s
  end

  def ldap_group_search_scope=(_value)
    api_instance = do_login
    configurations = {
      "ldap_group_search_scope": resource[:ldap_group_search_scope],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_search_scope: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_search_scope: #{e}"
    end
  end

  def ldap_group_admin_dn
    api_instance = do_login
    config = get_config(api_instance)
    config.ldap_group_admin_dn.value
  end

  def ldap_group_admin_dn=(_value)
    api_instance = do_login
    configurations = {
      "ldap_group_admin_dn": resource[:ldap_group_admin_dn],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_admin_dn: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for ldap_group_admin_dn: #{e}"
    end
  end

  [
    :oidc_client_id,
    :oidc_endpoint,
    :oidc_name,
    :oidc_scope,
    :oidc_verify_cert,
  ].each do |prop|
    define_method prop do
      api_instance = do_login
      config = get_config(api_instance)
      _value = config.send(prop).value
      if !!_value == _value
        _value = _value.to_s.to_sym
      end
      _value
    end
    define_method "#{prop}=".to_sym do |value|
      api_instance = do_login
      configurations = {
        "#{prop}": resource[prop],
      }
      begin
        api_instance[:legacy_client].configurations_put(configurations)
      rescue Harbor2LegacyClient::ApiError => e
        puts "Exception when calling ProductsApi->configurations_put for #{prop}: #{e}"
      rescue Harbor1Client::ApiError => e
        puts "Exception when calling ProductsApi->configurations_put for #{prop}: #{e}"
      end
    end
  end

  def project_creation_restriction
    api_instance = do_login
    config = get_config(api_instance)
    config.project_creation_restriction.value
  end

  def project_creation_restriction=(_value)
    api_instance = do_login
    configurations = {
      "project_creation_restriction": resource[:project_creation_restriction],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for project_creation_restriction: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for project_creation_restriction: #{e}"
    end
  end

  def read_only
    api_instance = do_login
    config = get_config(api_instance)
    config.read_only.value
  end

  def read_only=(_value)
    api_instance = do_login
    configurations = {
      "read_only": resource[:read_only],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for read_only: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for read_only: #{e}"
    end
  end

  def self_registration
    api_instance = do_login
    config = get_config(api_instance)
    config.self_registration.value.to_s
  end

  def self_registration=(_value)
    api_instance = do_login
    configurations = {
      "self_registration": resource[:self_registration],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for self_registration: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for self_registration: #{e}"
    end
  end

  def token_expiration
    api_instance = do_login
    config = get_config(api_instance)
    config.token_expiration.value
  end

  def token_expiration=(_value)
    api_instance = do_login
    configurations = {
      "token_expiration": resource[:token_expiration],
    }
    begin
      api_instance[:legacy_client].configurations_put(configurations)
    rescue Harbor2LegacyClient::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for token_expiration: #{e}"
    rescue Harbor1Client::ApiError => e
      puts "Exception when calling ProductsApi->configurations_put for token_expiration: #{e}"
    end
  end

end
