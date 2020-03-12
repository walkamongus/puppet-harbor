[![Build Status](https://travis-ci.org/walkamongus/puppet-harbor.svg?branch=master)](https://travis-ci.org/walkamongus/puppet-harbor)

# harbor

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with harbor](#setup)
    * [What harbor affects](#what-harbor-affects)
    * [Beginning with harbor](#beginning-with-harbor)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Advanced features](#advanced-features)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

Puppet module for installing, configuring, and running Harbor container registry project: https://goharbor.io/

## Setup

### What harbor affects

This module will install Docker and run Harbor through docker-compose as this is the method used by Harbor's install.sh script.

### Beginning with harbor

 `include harbor`

This will set up and start harbor with the completely default harbor.cfg configuration.

Make sure your target system meets the Harbor prerequisites outlined at https://github.com/goharbor/harbor/blob/master/docs/installation_guide.md#prerequisites-for-the-target-host

## Usage

Include usage examples for common use cases in the **Usage** section. Show your users how to use your module to solve problems, and be sure to include code examples. Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

## Advanced features

This module comes with types and providers to manage harbor user setttings (https://github.com/goharbor/harbor/blob/master/docs/configure_user_settings.md#harbor-user-settings) and harbor projects via Harbor's swagger API.

To use these features you must install the harbor-swagger-client gem (https://github.com/bt-lemery/harbor-swagger-client) and create the file '/etc/puppetlabs/swagger.yaml' on your Harbor server with the following (minimum) content:

```
---
username: 'admin'
password: '<admin_default_password>'
```

If using Harbor with SSL enabled you should also include:
```
scheme: 'https'
```

If using Harbor with a self-signed SSL certificate you should also include:
```
verify_ssl: false
verify_ssl_host: false
```

### User settings

The module currently supports the ability to provide user authentication via your own LDAP store.  To enable this create a 'harbor_user_settings' resource like:
```
  harbor_user_settings { 'ldap_settings':
    auth_mode      => 'ldap_auth',
    ldap_url       => 'ldap://example.org',
    ldap_base_dn   => 'dc=example,dc=org',
    ldap_search_dn => '<ldap_bind_user>',
  }
```
See 'Limitations' below.

### Projects

It is possible to create projects using the 'harbor_project' resource.  You can also manage user membership in projects, and control whether projects are public or private: 

```
  harbor_project { 'my-project':
    ensure        => present,
    public        => 'true',
    members       => ['bob', 'alice'],
    member_groups => ['This Team', 'That Team'],
  }
```
All members and member groups will be created as 'Developers' giving them full Read and Write access to the project and its associated repositories.

See 'Limitations' below.

## Limitations

If you wish to enable ldap auth you must do so before adding any local user accounts.  If you have created any local user accounts it is not possible to modify the auth_mode from the default 'db_auth'.

The Harbor API currently provides no facility for passing the password for the ldap user passed in the above harbor_user_settings resource.  You will need to login to the U
I to set the user password.

Group membership has only been tested against LDAP groups that have been imported in to Harbor but probably works for other types.  It is necessary to pre-create/import your groups before attempting to assign member_groups using this module.

This module supports:

    Centos 7.0
    RedHat 7.0
    Debian 9.0

For an extensive list of supported operating systems, see [metadata.json](metadata.json).

## Development

If you would like to contribute to this module, see the guidelines in [CONTRIBUTING.MD](CONTRIBUTING.md).
