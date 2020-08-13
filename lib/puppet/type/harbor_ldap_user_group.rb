# frozen_string_literal: true

Puppet::Type.newtype(:harbor_ldap_user_group) do
  @doc = %q{Manages an LDAP user groups within Harbor.

    Example creating an LDAP user group giving the LDAP group DN as title of the resource:

        harbor_ldap_user_group {'cn=ProjectA,ou=Users,dc=example,dc=local':
          ensure     => present,
          group_name => 'project_a',
        }

    Example creating an LDAP user group with separate title:

        harbor_ldap_user_group {'Members of project A':
          ensure        => present,
          ldap_group_dn => 'cn=ProjectA,ou=Users,dc=example,dc=local',
          group_name    => 'project_a',
        }

    Example remove an LDAP user group:

        harbor_ldap_user_group {'cn=ProjectA,ou=Users,dc=example,dc=local':
          ensure => absent,
        }
  }

  ensurable

  newparam(:ldap_group_dn, namevar: true) do
    desc 'The DN of the LDAP group. This is taken from resource\'s name if not
     explicitly set. It cannot be changed once the resource was created.'
  end

  newproperty(:group_name) do
    desc 'The name of the user group. This has to be unique within the Harbor
      installation. It can be changed for an existing group.'
  end

end
