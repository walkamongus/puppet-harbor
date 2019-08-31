# frozen_string_literal: true

Puppet::Type.newtype(:harbor_user_settings) do
  desc 'Manage Harbor user settings'

  newparam(:name, namevar: true) do
    desc 'Name of the settings'
  end

  newproperty(:auth_mode) do
    defaultto 'db_auth'
    newvalues('db_auth', 'ldap_auth', 'uaa_auth', 'oidc_auth')
  end

  newproperty(:email_from) do
    defaultto 'admin <sample_admin@mydomain.com>'
  end

  newproperty(:email_host) do
    defaultto 'smtp.mydomain.com'
  end

  newproperty(:email_port) do
    defaultto 25
  end

  newproperty(:email_identity) do
  end

  newproperty(:email_username) do
    defaultto 'sample_admin@mydomain.com'
  end

  newproperty(:email_ssl) do
    defaultto false
    newvalues(true, false)
  end

  newproperty(:email_insecure) do
    defaultto false
    newvalues(true, false)
  end

  newproperty(:ldap_url) do
  end

  newproperty(:ldap_base_dn) do
  end

  newproperty(:ldap_filter) do
  end

  newproperty(:ldap_scope) do
    defaultto 2
    newvalues(0, 1, 2)
  end

  newproperty(:ldap_uid) do
    defaultto 'cn'
  end

  newproperty(:ldap_search_dn) do
  end

  newproperty(:ldap_timeout) do
    defaultto 5
  end

  newproperty(:ldap_group_attribute_name) do
    newvalues('cn', 'gid')
  end

  newproperty(:ldap_group_base_dn) do
  end

  newproperty(:ldap_group_search_filter) do
  end

  newproperty(:ldap_group_search_scope) do
    defaultto 2
    newvalues(0, 1, 2)
  end

  newproperty(:ldap_group_admin_dn) do
  end

  newproperty(:project_creation_restriction) do
    defaultto 'everyone'
    newvalues('everyone', 'adminonly')
  end

  newproperty(:read_only) do
    defaultto false
    newvalues(true, false)
  end

  newproperty(:self_registration) do
    defaultto true
    newvalues(true, false)
  end

  newproperty(:token_expiration) do
    defaultto 30
  end
end
