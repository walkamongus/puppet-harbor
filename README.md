[![Build Status](https://travis-ci.org/walkamongus/puppet-harbor.svg?branch=master)](https://travis-ci.org/walkamongus/puppet-harbor)

# harbor

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with harbor](#setup)
    * [What harbor affects](#what-harbor-affects)
    * [Beginning with harbor](#beginning-with-harbor)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

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

## Limitations

This module supports:

    Centos 7.0
    RedHat 7.0
    Debian 9.0

For an extensive list of supported operating systems, see [metadata.json](metadata.json).

## Development

If you would like to contribute to this module, see the guidelines in [CONTRIBUTING.MD](CONTRIBUTING.md).
