# frozen_string_literal: true

Puppet::Type.newtype(:harbor_user_settings) do
  desc <<-DESC
@summary Manage Harbor system configuration settings

@example Set LDAP configuration settings within Harbor
    harbor_user_settings { 'ldap_settings':
      auth_mode      => 'ldap_auth',
      ldap_url       => 'ldap://example.org',
      ldap_base_dn   => 'dc=example,dc=org',
      ldap_search_dn => '<ldap_bind_user>',
    }
DESC

  newparam(:name, namevar: true) do
    desc 'Arbitrary name for the group of settings controlled in the resource'
  end

  newproperty(:auth_mode) do
    desc 'The auth mode of current system, such as "db_auth", "ldap_auth"'
    defaultto 'db_auth'
    newvalues('db_auth', 'ldap_auth', 'uaa_auth', 'oidc_auth')
  end

  newproperty(:email_from) do
    desc 'The sender name for Email notification'
    defaultto 'admin <sample_admin@mydomain.com>'
  end

  newproperty(:email_host) do
    desc 'The hostname of SMTP server that sends Email notification'
    defaultto 'smtp.mydomain.com'
  end

  newproperty(:email_port) do
    desc 'The port of SMTP server'
    defaultto 25
  end

  newproperty(:email_identity) do
    desc 'By default it is empty so the email_username is picked'
  end

  newproperty(:email_username) do
    desc 'The username for authentication against SMTP server'
    defaultto 'sample_admin@mydomain.com'
  end

  newproperty(:email_ssl) do
    desc 'When set to true the system will access Email server via TLS by default. If set to false, it still will handle "STARTTLS" from server side'
    defaultto false
    newvalues(true, false)
  end

  newproperty(:email_insecure) do
    desc 'Whether or not the certificate will be verified when Harbor tries to access the email server'
    defaultto false
    newvalues(true, false)
  end

  newproperty(:ldap_url) do
    desc 'The URL of LDAP server'
  end

  newproperty(:ldap_base_dn) do
    desc 'The Base DN for LDAP binding'
  end

  newproperty(:ldap_filter) do
    desc 'The filter for LDAP binding'
  end

  newproperty(:ldap_scope) do
    desc 'The scope to search ldap. "0-LDAP_SCOPE_BASE, 1-LDAP_SCOPE_ONELEVEL, 2-LDAP_SCOPE_SUBTREE"'
    defaultto 2
    newvalues(0, 1, 2)
  end

  newproperty(:ldap_uid) do
    desc 'The attribute which is used as identity for the LDAP binding, such as "CN" or "SAMAccountname"'
    defaultto 'cn'
  end

  newproperty(:ldap_search_dn) do
    desc 'The DN of the user to do the search'
  end

  newproperty(:ldap_timeout) do
    desc 'Timeout in seconds for connection to LDAP server'
    defaultto 5
  end

  newproperty(:ldap_group_attribute_name) do
    desc 'The attribute which is used as identity of the LDAP group, default is cn'
    newvalues('cn', 'gid')
  end

  newproperty(:ldap_group_base_dn) do
    desc 'The base DN to search LDAP group'
  end

  newproperty(:ldap_group_search_filter) do
    desc 'The filter to search the ldap group'
  end

  newproperty(:ldap_group_search_scope) do
    desc 'The scope to search ldap groups. "0-LDAP_SCOPE_BASE, 1-LDAP_SCOPE_ONELEVEL, 2-LDAP_SCOPE_SUBTREE"'
    defaultto 2
    newvalues(0, 1, 2)
  end

  newproperty(:ldap_group_admin_dn) do
    desc 'Specify the ldap group which have the same privilege with Harbor admin'
  end

  newproperty(:project_creation_restriction) do
    desc 'This attribute restricts what users have the permission to create project. It can be "everyone" or "adminonly"'
    defaultto 'everyone'
    newvalues('everyone', 'adminonly')
  end

  newproperty(:read_only) do
    desc '"docker push" is prohibited by Harbor if set to true'
    defaultto false
    newvalues(true, false)
  end

  newproperty(:self_registration) do
    desc 'Whether the Harbor instance supports self-registration. If set to false, admin needs to add user to the instance'
    defaultto true
    newvalues(true, false)
  end

  newproperty(:token_expiration) do
    desc 'The expiration time of the token for internal Registry, in minutes'
    defaultto 30
  end
end
