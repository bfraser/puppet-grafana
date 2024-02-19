# grafana

[![Build Status](https://github.com/voxpupuli/puppet-grafana/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-grafana/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-grafana/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-grafana/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/grafana.svg)](https://forge.puppetlabs.com/puppet/grafana)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/grafana.svg)](https://forge.puppetlabs.com/puppet/grafana)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/grafana.svg)](https://forge.puppetlabs.com/puppet/grafana)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/grafana.svg)](https://forge.puppetlabs.com/puppet/grafana)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-grafana)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-grafana.svg)](LICENSE)

#### Table of Contents

1. [Overview](#overview)
1. [Module Description](#module-description)
1. [Setup](#setup)
    * [Requirements](#requirements)
    * [Beginning with Grafana](#beginning-with-grafana)
1. [Usage](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
    * [Advanced usage](#advanced-usage)
1. [Tasks](#tasks)
1. [Limitations](#limitations)
1. [Copyright and License](#copyright-and-license)

## Overview

This module installs Grafana, a dashboard and graph editor for Graphite,
InfluxDB and OpenTSDB.

## Module Description

With the 9.0.0 release of this module we only support Grafana 6.x/7.x/8.x.
Version 8 of the module was tested successfully on Grafana 6 and 7.

## Setup

This module will:

* Install Grafana using your preferred method: package (default), Docker
  container, or tar archive
* Allow you to override the version of Grafana to be installed, and / or the
  package source
* Perform basic configuration of Grafana

### Requirements

* If using an operating system of the Debian-based family, and the "repo"
`install_method`, you will need to ensure that
[puppetlabs-apt](https://forge.puppet.com/puppetlabs/apt) version 4.x is
installed.
* If using Docker, you will need the
[garethr/docker](https://forge.puppet.com/garethr/docker) module version 5.x

### Beginning with Grafana

To install Grafana with the default parameters:

```puppet
    class { 'grafana': }
```

This assumes that you want to install Grafana using the 'package' method. To
establish customized parameters:

```puppet
    class { 'grafana':
      install_method  => 'docker',
    }
```

## Usage

### Classes and Defined Types

#### Class: `grafana`

The Grafana module's primary class, `grafana`, guides the basic setup of Grafana
on your system.

```puppet
    class { 'grafana': }
```

**Parameters within `grafana`:**

##### `archive_source`

The download location of a tarball to use with the 'archive' install method.
Defaults to the URL of the latest version of Grafana available at the time of
module release.

##### `cfg_location`

Configures the location to which the Grafana configuration is written. The
default location is '/etc/grafana/grafana.ini'.

##### `cfg`

Manages the Grafana configuration file. Grafana comes with its own default
settings in a different configuration file (/opt/grafana/current/conf/defaults.ini),
therefore this module does not supply any defaults.

This parameter only accepts a `Hash` (or `Sensitive[Hash]`) as its value. Keys with hashes as values will
generate sections, any other values are just plain values. The example below will
result in...

```puppet
    class { 'grafana':
      cfg => {
        app_mode => 'production',
        server   => {
          http_port     => 8080,
        },
        database => {
          type          => 'mysql',
          host          => '127.0.0.1:3306',
          name          => 'grafana',
          user          => 'root',
          password      => '',
        },
        users    => {
          allow_sign_up => false,
        },
      },
    }
```

...the following Grafana configuration:

```ini
# This file is managed by Puppet, any changes will be overwritten

app_mode = production

[server]
http_port = 8080

[database]
type = mysql
host = 127.0.0.1:3306
name = grafana
user = root
password =

[users]
allow_sign_up = false
```

Some minor notes:

* If you want empty values, just use an empty string.
* Keys that contains dots (like auth.google) need to be quoted.
* The order of the keys in this hash is the same as they will be written to the
  configuration file. So settings that do not fall under a section will have to
  come before any sections in the hash.
* If your configuration contains secrets you want hidden in Puppet log output and reports
  use a `Sensitive[Hash]` instead of a normal `Hash`

#### `ldap_cfg`

Manages the Grafana LDAP configuration file. This hash is directly translated
into the corresponding TOML file, allowing for full flexibility in generating
the configuration.

See the [LDAP documentation](http://docs.grafana.org/v2.1/installation/ldap/)
for more information.

##### TOML note

This option **requires** the [toml](https://rubygems.org/gems/toml/) gem. Either
install the gem using puppet's native gem provider,
[puppetserver_gem](https://forge.puppetlabs.com/puppetlabs/puppetserver_gem),
[pe_gem](https://forge.puppetlabs.com/puppetlabs/pe_gem),
[pe_puppetserver_gem](https://forge.puppetlabs.com/puppetlabs/pe_puppetserver_gem),
or manually using one of the following:

```
  # apply or puppet-master
  gem install toml
  # PE apply
  /opt/puppet/bin/gem install toml
  # AIO or PE puppetserver
  /opt/puppet/bin/puppetserver gem install toml
```
##### secrets

LDAP configuration usually contains secrets. If you want to stop these being leaked in logs and reports,
the `ldap_cfg` parameter will optionally accept the `Sensitive` data type.

##### cfg note

This option by itself is not sufficient to enable LDAP configuration as it must
be enabled in the main configuration file. Enable it in cfg with:

```
'auth.ldap' => {
  enabled     => 'true',
  config_file => '/etc/grafana/ldap.toml',
},
```
#### Example LDAP config

```
ldap_cfg => Sensitive({
  servers => [
    { host            => 'ldapserver1.domain1.com',
      port            => 636,
      use_ssl         => true,
      search_filter   => '(sAMAccountName=%s)',
      search_base_dns => [ 'dc=domain1,dc=com' ],
      bind_dn         => 'user@domain1.com',
      bind_password   => 'passwordhere',
    },
  ],
  'servers.attributes' => {
    name      => 'givenName',
    surname   => 'sn',
    username  => 'sAMAccountName',
    member_of => 'memberOf',
    email     => 'mail',
  }
}),
```

If you want to connect to multiple LDAP servers using different configurations,
use an array to enwrap the configurations as shown below.

```
ldap_cfg => Sensitive([
  {
    servers => [
      {
        host            => 'ldapserver1.domain1.com',
        port            => 636,
        use_ssl         => true,
        search_filter   => '(sAMAccountName=%s)',
        search_base_dns => [ 'dc=domain1,dc=com' ],
        bind_dn         => 'user@domain1.com',
        bind_password   => 'passwordhere',
      },
    ],
    'servers.attributes' => {
      name      => 'givenName',
      surname   => 'sn',
      username  => 'sAMAccountName',
      member_of => 'memberOf',
      email     => 'mail',
    },
    'servers.group_mappings' => [
      {
        group_dn => 'cn=grafana_viewers,ou=groups,dc=domain1,dc=com',
        org_role => 'Viewer',
      }
    ],
  },
  {
    servers => [
      {
        host            => 'ldapserver2.domain2.com',
        port            => 389,
        use_ssl         => false,
        start_tls       => true,
        search_filter   => '(uid=%s)',
        search_base_dns => [ 'dc=domain2,dc=com' ],
        bind_dn         => 'user@domain2.com',
        bind_password   => 'passwordhere',
      },
    ],
    'servers.attributes' => {
      name      => 'givenName',
      surname   => 'sn',
      username  => 'uid',
      member_of => 'memberOf',
      email     => 'mail',
    }
    'servers.group_mappings' => [
      {
        'group_dn'      => 'cn=grafana_admins,ou=groups,dc=domain2,dc=com',
        'org_role'      => 'Admin',
        'grafana_admin' => true,
      }
    ],
  },
])


#####
# or in hiera-yaml style
grafana::ldap_cfg:
  - servers:
      - host: ldapserver1.domain1.com
        port: 636
        use_ssl: true
        search_filter: '(sAMAccountName=%s)'
        search_base_dns: ['dc=domain1,dc=com']
        bind_dn: 'user@domain1.com'
        bind_password: 'passwordhere'
    servers.attributes:
      name: givenName
      surname: sn
      username: sAMAccountName
      member_of: memberOf
      email: mail
    servers.group_mappings:
      - group_dn: cn=grafana_viewers,ou=groups,dc=domain1,dc=com
        org_role: Viewer

  - servers:
      - host: ldapserver2.domain2.com
        port: 389
        use_ssl: false
        start_tls: true
        search_filter: '(uid=%s)',
        search_base_dns: ['dc=domain2,dc=com']
        bind_dn: 'user@domain2.com'
        bind_password: 'passwordhere'
    servers.attributes:
      name: givenName
      surname: sn
      username: uid
      member_of: memberOf
      email: mail
    servers.group_mappings:
      - group_dn: cn=grafana_admins,ou=groups,dc=domain2,dc=com
        org_role: Admin
        grafana_admin: true


#####
```

##### `container_cfg`

Boolean to control whether a configuration file should be generated when using
the 'docker' install method. If 'true', use the 'cfg' and 'cfg_location'
parameters to control creation of the file. Defaults to false.

##### `container_params`

A hash of parameters to use when creating the Docker container. For use with the
'docker' install method. Refer to documentation of the 'docker::run' resource in
the [garethr-docker](https://github.com/garethr/garethr-docker) module for details
of available parameters. Defaults to:

```puppet
container_params => {
  'image' => 'grafana/grafana:latest',
  'ports' => '3000:3000'
}
```

##### `data_dir`

The directory Grafana will use for storing its data. Defaults to '/var/lib/grafana'.

##### `install_dir`

The installation directory to be used with the 'archive' install method. Defaults
to '/usr/share/grafana'.

##### `install_method`

Controls which method to use for installing Grafana. Valid options are: 'archive',
'docker', 'repo' and 'package'. The default is 'package'. If you wish to use the
'docker' installation method, you will need to include the 'docker' class in your
node's manifest / profile. If you wish to use the 'repo' installation method, you
can control whether the official Grafana repositories will be used. See
`manage_package_repo` below for details.

##### `manage_package_repo`

Boolean. When using the 'repo' installation method, controls whether the official
Grafana repositories are enabled on your host. If true, the official Grafana
repositories will be enabled. If false, the module assumes you are managing your
own package repository and will not set one up for you. Defaults to true.

##### `plugins`

Hash. This is a passthrough to call `create_resources()` on the
`grafana_plugin` resource type.

##### `package_name`

The name of the package managed with the 'package' install method. Defaults to
'grafana'.

##### `package_source`

The download location of a package to be used with the 'package' install method.
Defaults to the URL of the latest version of Grafana available at the time of
module release.

##### `provisioning_datasources`

A Hash which is converted to YAML for grafana to provision data
sources. See [provisioning
grafana](http://docs.grafana.org/administration/provisioning/) for
details and example config file. Requires grafana > v5.0.0.

This is very useful with Hiera as you can provide a yaml
hash/dictionary which will effectively 'passthrough' to grafana. See
**Advanced Usage** for examples.

##### `provisioning_dashboards`

A Hash which is converted to YAML for grafana to provision
dashboards. See [provisioning
grafana](http://docs.grafana.org/administration/provisioning/) for
details and example config file.  Requires grafana > v5.0.0.

This is very useful with Hiera as you can provide a yaml
hash/dictionary which will effectively 'passthrough' to grafana. See
**Advanced Usage** for examples.

N.B. A option named `puppetsource` may be given in the `options` hash
which is not part of grafana's syntax. This option will be extracted
from the hash, and used to "source" a directory of dashboards. See
**Advanced Usage** for details.

#### `provisioning_dashboards_file`

A String that is used as the target file name for the dashabords
provisioning file. This way the module can be used to generate placeholder
files so password can be sepecified in a different iteration, avoiding them
to be put in the module code.

#### `provisioning_datasources_file`

A String that is used as the target file name for the datasources
provisioning file. This way the module can be used to generate placeholder
files so password can be sepecified in a different iteration, avoiding them
to be put in the module code.

##### `rpm_iteration`

Used when installing Grafana from package ('package' or 'repo' install methods)
on Red Hat based systems. Defaults to '1'. It should not be necessary to change
this in most cases.

##### `service_name`

The name of the service managed with the 'archive' and 'package' install methods.
Defaults to 'grafana-server'.

##### `version`

The version of Grafana to install and manage. Defaults to 'installed'

##### `sysconfig_location`

The RPM and DEB packages bring with them the default environment files for the
services. The default location of this file for Debian is /etc/default/grafana-server
and for RedHat /etc/sysconfig/grafana-server.

##### `sysconfig`

A hash of environment variables for the service. This only has an effect for installations
with RPM and DEB packages (if install_method is set to 'package' or 'repo').

Example:

```puppet
sysconfig => {
  'http_proxy' => 'http://proxy.example.com',
}
```

### Advanced usage

The archive install method will create the user and a "command line" service by
default. There are no extra parameters to manage user/service for archive.
However, both check to see if they are defined before defining. This way you can
create your own user and service with your own specifications. (sort of overriding)
The service can be a bit tricky, in this example below, the class
sensu_install::grafana::service creates a startup script and a service{'grafana-server':}

Example:

```puppet
    user { 'grafana':
      ensure => present,
      uid    => '1234',
    }
    ->
    class { 'grafana':
      install_method  => 'archive',
    }

    include sensu_install::grafana::service

    # run your service after install/config but before grafana::service
    Class[::grafana::install]
    ->
    Class[sensu_install::grafana::service]
    ->
    Class[::grafana::service]

```


#### Using a sub-path for Grafana API

If you are using a sub-path for the Grafana API, you will need to set the `grafana_api_path` parameter for the following custom types:
- `grafana_dashboard`
- `grafana_datasource`
- `grafana_organization`
- `grafana_user`
- `grafana_folder`
- `grafana_team`
- `grafana_membership`
- `grafana_dashboard_permission`

For instance, if your sub-path is `/grafana`, the `grafana_api_path` must
be set to `/grafana/api`. Do not add a trailing `/` (slash) at the end of the value.

If you are not using sub-paths, you do not need to set this parameter.

#### Custom Types and Providers

The module includes several custom types:

#### `grafana_organization`

In order to use the organization resource, add the following to your manifest:

```puppet
grafana_organization { 'example_org':
  ensure           => present,
  grafana_url      => 'http://localhost:3000',
  grafana_user     => 'admin',
  grafana_password => '5ecretPassw0rd',
}
```

`grafana_url`, `grafana_user`, and `grafana_password` are required to create organizations via the API.

set `ensure => absent` if you want to remove an organization.
Removing the default organization, (`Main org.`), is not supported.

#### `grafana_team`

In order to use the team resource, add the following to your manifest:

```puppet
grafana_team { 'example_team':
  ensure           => 'present',
  grafana_url      => 'http://localhost:3000',
  grafana_user     => 'admin',
  grafana_password => '5ecretPassw0rd',
  home_dashboard   => 'example_dashboard',
  organization     => 'example_org',
}
```

Organziation must exist if specified.

`grafana_url`, `grafana_user`, and `grafana_password` are required to create teams via the API.

`ensure` is required. If the resource should be `present` or `absent`

`name` is optional if the name will differ from example_team above.

`home_dashboard_folder` is optional. Sets the folder where home dashboard resides. Dashboard folder must exist.

`home_dashboard` is optional. Sets the home dashboard for team. Dashboard must exist.

`organization` is optional. Defaults to `Main org.`

#### `grafana_dashboard_permission`

In order to use the dashboard permission resource, add one the following to your manifest:

add permissions for user:

```puppet
grafana_dashboard_permission { 'example_user_permission':
  ensure           => 'present',
  grafana_url      => 'http://localhost:3000',
  grafana_user     => 'admin',
  grafana_password => '5ecretPassw0rd',
  dashboard        => 'example_dashboard',
  user             => 'example_user',
  organization     => 'example_org',
}
```

add permissions for team:

```puppet
grafana_dashboard_permission { 'example_team_permission':
  ensure           => 'present',
  grafana_url      => 'http://localhost:3000',
  grafana_user     => 'admin',
  grafana_password => '5ecretPassw0rd',
  dashboard        => 'example_dashboard',
  team             => 'example_team',
  organization     => 'example_org',
}
```

Organziation, team, user and dashboard must exist if specified.

`grafana_url`, `grafana_user`, and `grafana_password` are required to create teams via the API.

`ensure` is required. If the resource should be `present` or `absent`

`dashboard` is required. The dashboard to set permissions for.

`user` is required if `team` not set. The user to add permissions for.

`team` is required if `user` not set. the team to add permissions for.

`name` is optional if the name will differ from example_team above.

`organization` is optional. Defaults to `Main org.`

#### `grafana_membership`

In order to use the membership resource, add the following to your manifest:

```puppet
grafana_membership { 'example_membership':
  ensure           => 'present',
  grafana_url      => 'http://localhost:3000',
  grafana_user     => 'admin',
  grafana_password => '5ecretPassw0rd',
  membership_type  => 'team',
  organization     => 'example_org',
  target_name      => 'example_team',
  user_name        => 'example_user',
  role             => 'Viewer'
  }
}
```
A membership is the concept of a user belonging to a target - either a `team` or an `organization`

The user and target must both exist for a membership to be created

`grafana_url`, `grafana_user`, and `grafana_password` are required to create memberships via the API.

`ensure` is required. If the resource should be `present` or `absent`

`membership_type` is required. Either `team` or `organization`

`target_name` is required. Specifies the target of the membership.

`user_name` is required. Specifies the user that is the focus of the membership.

`role` is required. Specifies what rights to grant the user. Either `Viewer`, `Editor` or `Admin`

`organization` is optional when using the `membership_type` of `team`. Defaults to `Main org.`

#### `grafana_dashboard`

In order to use the dashboard resource, add the following to your manifest:

```puppet
grafana_dashboard { 'example_dashboard':
  grafana_url       => 'http://localhost:3000',
  grafana_user      => 'admin',
  grafana_password  => '5ecretPassw0rd',
  grafana_api_path  => '/grafana/api',
  folder            => 'folder-name',
  organization      => 'NewOrg',
  content           => template('path/to/exported/file.json'),
}
```

`content` must be valid JSON, and is parsed before imported. You can use the JSON generated with the share/export functionality or from the API call to /dashboards/uid but must remove the fields "id", "uid", "title" and "version" to make the resource call idempotent.
`grafana_user` and `grafana_password` are optional, and required when
authentication is enabled in Grafana. `grafana_api_path` is optional, and only used when using sub-paths for the API. `organization` is optional, and used when creating a dashboard for a specific organization.
`folder` is an optional parameter, but the folder resource must exist.

Example:
Make sure the `grafana-server` service is up and running before creating the `grafana_dashboard` definition. One option is to use the `http_conn_validator` from the [healthcheck](https://forge.puppet.com/puppet/healthcheck) module

```puppet
http_conn_validator { 'grafana-conn-validator' :
  host     => 'localhost',
  port     => '3000',
  use_ssl  => false,
  test_url => '/public/img/grafana_icon.svg',
  require  => Class['grafana'],
}
-> grafana_dashboard { 'example_dashboard':
  grafana_url       => 'http://localhost:3000',
  grafana_user      => 'admin',
  grafana_password  => '5ecretPassw0rd',
  content           => template('path/to/exported/file.json'),
}
```

##### `grafana_datasource`

In order to use the datasource resource, add the following to your manifest:

```puppet
grafana_datasource { 'influxdb':
  grafana_url      => 'http://localhost:3000',
  grafana_user     => 'admin',
  grafana_password => '5ecretPassw0rd',
  grafana_api_path => '/grafana/api',
  type             => 'influxdb',
  organization     => 'NewOrg',
  url              => 'http://localhost:8086',
  user             => 'admin',
  password         => '1nFlux5ecret',
  database         => 'graphite',
  access_mode      => 'proxy',
  is_default       => true,
  json_data        => template('path/to/additional/config.json'),
  secure_json_data => template('path/to/additional/secure/config.json')
}
```

Available types are: influxdb, elasticsearch, graphite, cloudwatch, mysql, opentsdb, postgres and prometheus

`organization` is used to set which organization a datasource will be created on. If this parameter is not set, it will default to organization ID 1 (Main Org. by default). If the default org is deleted, organizations will need to be specified.

Access mode determines how Grafana connects to the datasource, either `direct`
from the browser, or `proxy` to send requests via grafana.

Setting `basic_auth` to `true` will allow use of the `basic_auth_user` and `basic_auth_password` params.

Authentication is optional, as are `database` and `grafana_api_path`; additional `json_data` and `secure_json_data` can be provided to allow custom configuration options.

Example:
Make sure the `grafana-server` service is up and running before creating the `grafana_datasource` definition. One option is to use the `http_conn_validator` from the [healthcheck](https://forge.puppet.com/puppet/healthcheck) module

```puppet
http_conn_validator { 'grafana-conn-validator' :
  host     => 'localhost',
  port     => '3000',
  use_ssl  => false,
  test_url => '/public/img/grafana_icon.svg',
  require  => Class['grafana'],
}
-> grafana_datasource { 'influxdb':
  grafana_url       => 'http://localhost:3000',
  grafana_user      => 'admin',
  grafana_password  => '5ecretPassw0rd',
  type              => 'influxdb',
  url               => 'http://localhost:8086',
  user              => 'admin',
  password          => '1nFlux5ecret',
  database          => 'graphite',
  access_mode       => 'proxy',
  is_default        => true,
  json_data         => template('path/to/additional/config.json'),
}
```

Note that the `database` is dynamic, setting things other than "database" for separate types. Ex: for Elasticsearch it will set the Index Name.

**`jsonData` Settings**

Note that there are separate options for json_data / secure_json_data based on the type of datasource you create.

##### **Elasticsearch**

`esVersion` - Required, either 2 or 5, set as a bare number.

`timeField` - Required. By default this is @timestamp, but without setting it in jsonData, the datasource won't work without refreshing it in the GUI.

`timeInterval` - Optional. A lower limit for the auto group by time interval. Recommended to be set to write frequency, for example "1m" if your data is written every minute.

Example:
```puppet
json_data => {"esVersion":5,"timeField":"@timestamp","timeInterval":"1m"}
```

##### **CloudWatch**

`authType` - Required. Options are `Access & Secret Key`, `Credentials File`, or `ARN`.

-"keys" = Access & Secret Key

-"credentials" = Credentials File

-"arn" = ARN

*When setting authType to `credentials`, the `database` param will set the Credentials Profile Name.*

*When setting authType to `arn`, another jsonData value of `assumeRoleARN` is available, which is not required for other authType settings*

`customMetricsNamespaces` - Optional. Namespaces of Custom Metrics, separated by commas within double quotes.

`defaultRegion` - Required. Options are "ap-northeast-(1 or 2)", "ap-southeast-(1 or 2)", "ap-south-1", "ca-central-1", "cn-north-1", "eu-central-1", "eu-west-(1 or 2)", "sa-east-(1 or 2)", "us-east-(1 or 2)", "us-gov-west-1", "us-west-(1 or 2)".

`timeField`

Example:
```puppet
{"authType":"arn","assumeRoleARN":"arn:aws:iam:*","customMetricsNamespaces":"Namespace1,Namespace2","defaultRegion":"us-east-1","timeField":"@timestamp"}
```

##### **Graphite**

`graphiteVersion` - Required. Available versions are `0.9` or `1.0`.

`tlsAuth` - Set to `true` or `false`

`tlsAuthWithCACert` - Set to `true` or `false`

Example:
```puppet
{"graphiteVersion":"0.9","tlsAuth":true,"tlsAuthWithCACert":false}
```

##### **OpenTSDB**

`tsdbResolution` - Required. Options are `1` or `2`.

  `1` = second

  `2` = millisecond

`tsdbVersion` - Required. Options are `1`, `2`, or `3`.

  `1` &nbsp;&nbsp; = &nbsp;&nbsp; <=2.1

  `2` &nbsp;&nbsp; = &nbsp;&nbsp; ==2.2

  `3` &nbsp;&nbsp; = &nbsp;&nbsp; ==2.3

Example:
```puppet
{"tsdbResolution:1,"tsdbVersion":3}
```

##### **InfluxDB**

N/A

##### **MySQL**

N/A

##### **Prometheus**

N/A

##### `grafana_plugin`

An example is provided for convenience; for more details, please view the
puppet strings docs.

```puppet
grafana_plugin { 'grafana-simple-json-datasource':
  ensure => present,
}
```

It is possible to specify a custom plugin repository to install a plugin. This will use the --repo option for plugin installation with grafana_cli.

```puppet
grafana_plugin { 'grafana-simple-json-datasource':
  ensure    => present,
  repo      => 'https://nexus.company.com/grafana/plugins',
}
```

It is also possible to specify a custom plugin url to install a plugin. This will use the --pluginUrl option for plugin installation with grafana_cli.

```puppet
grafana_plugin { 'grafana-example-custom-plugin':
  ensure     => present,
  plugin_url => 'https://github.com/example/example-custom-plugin/zipball/v1.0.0'
}
```

##### `grafana_folder`

Creates and manages Grafana folders via the API.

The following example creates a folder named 'folder1':
```puppet
grafana_folder { 'folder1':
  ensure            => present,
  grafana_url       => 'http://localhost:3000',
  grafana_api_path  => '/grafana/api',
  grafana_user      => 'admin',
  grafana_password  => '5ecretPassw0rd',
}
```
`grafana_api_path` is only required if using sub-paths for the API

##### `grafana::user`

Creates and manages a global grafana user via the API.

```puppet
grafana_user { 'username':
  grafana_url       => 'http://localhost:3000',
  grafana_api_path  => '/grafana/api',
  grafana_user      => 'admin',
  grafana_password  => '5ecretPassw0rd',
  full_name         => 'John Doe',
  password          => 'Us3r5ecret',
  email             => 'john@example.com',
  organizations     => {
    'Example Org' => 'Editor',
    'Main org.'   => 'Viewer',
    'Another Org' => 'Admin',
  },
}
```

`grafana_api_path` is only required if using sub-paths for the API

If `organizations` is specified, the user's organizations will be managed.
These should be specified as a hash of organization names and roles.

If puppet is managing any of these organizations, they will be autorequired.

##### `grafana::notification`

Creates and manages a global alert notification channel via the API.

```puppet
grafana_notification { 'channelname':
  grafana_url       => 'http://localhost:3000',
  grafana_api_path  => '/grafana/api',
  grafana_user      => 'admin',
  grafana_password  => '5ecretPassw0rd',

  name              => 'channelname',
  type              => 'email',
  is_default        => false,
  send_reminder     => false,
  frequency         => '20m',
  settings          => {
              addresses    => "alerts@example.com; it@example.com"
  }
}
```
`grafana_api_path` is only required if using sub-paths for the API

Notification types and related settingsi (cf doc Grafana : https://github.com/grafana/grafana/blob/master/docs/sources/alerting/notifications.md ) :
   - email:
       - addresses: "example.com"
   - hipchat:
       - apikey       : "0a0a0a0a0a0a0a0a0a0a0a"
       - autoResolve  : true
       - httpMethod   : "POST"
       - uploadImage  : true
       - url          : "https://grafana.hipchat.com"
   - kafka:
       - autoResolve   : true
       - httpMethod    : "POST"
       - kafkaRestProxy: "http://localhost:8082"
       - kafkaTopic    : "topic1"
       - uploadImage   : true
   - LINE:
       - autoResolve: true
       - httpMethod : "POST"
       - token      : "token"
       - uploadImage: true
   - teams (Microsoft Teams):
       - autoResolve : true
       - httpMethod  : "POST"
       - uploadImage :true
       - url         : "http://example.com"
   - pagerduty:
       - autoResolve    : true
       - httpMethod     : POST
       - integrationKey :"0a0a0a0a0a"
       - uploadImage    : true
   - prometheus-alertmanager:
       - autoResolve : true
       - httpMethod  : "POST"
       - uploadImage : true
       - url         : "http://localhost:9093"
   - sensu:
       - autoResolve : true
       - handler     : "default",
       - httpMethod  : "POST"
       - uploadImage : true
       - url         : "http://sensu-api.local:4567/results"
   - slack:
       - autoResolve : true
       - httpMethod  : "POST"
       - uploadImage : true
       - url         : "http://slack.com/"
       - token       : "0a0a0a0a0a0a0a0a0a0a0a"
   - threema:
       - api_secret  : "0a0a0a0a0a0a0a0a0a0a0a"
       - autoResolve : true
       - gateway_id  : "*3MAGWID"
       - httpMethod  : "POST"
       - recipient_id: "YOUR3MID"
       - uploadImage : true
   - discord:
       - autoResolve : true,
       - httpMethod  : "POST"
       - uploadImage : true
       - url         : "https://example.com"
   - webhook:
       - autoResolve : true
       - httpMethod  : "POST"
       - uploadImage : false
       - url         : "http://localhost:8080"
   - telegram:
       - autoResolve : true
       - bottoken    : "0a0a0a0a0a0a"
       - chatid      : "789789789"
       - httpMethod  : "POST"
       - uploadImage : true

#### Provisioning Grafana

[Grafana documentation on
provisioning](http://docs.grafana.org/administration/provisioning/).

This module will provision grafana by placing yaml files into
`/etc/grafana/provisioning/datasources` and
`/etc/grafana/provisioning/dashboards` by default.

##### Example datasource

A puppet hash example for Prometheus. The module will place the hash
as a yaml file into `/etc/gafana/provisioning/datasources/puppetprovisioned.yaml`.

```puppet
class { 'grafana':
  provisioning_datasources => {
    apiVersion  => 1,
    datasources => [
      {
        name      => 'Prometheus',
        type      => 'prometheus',
        access    => 'proxy',
        url       => 'http://localhost:9090/prometheus',
        isDefault => true,
      },
    ],
  }
}
```

Here is the same configuration example as a hiera hash.

```yaml
grafana::provisioning_datasources:
  apiVersion: 1
  datasources:
    - name: 'Prometheus'
      type: 'prometheus'
      access: 'proxy'
      url: 'http://localhost:9090/prometheus'
      isDefault: true
```

##### Example dashboard

An example puppet hash for provisioning dashboards. The module will
place the hash as a yaml file into
`/etc/grafana/provisioning/dashboards/puppetprovisioned.yaml` by default. More details follow the examples.

```puppet
class { 'grafana':
  provisioning_dashboards => {
    apiVersion => 1,
    providers  => [
      {
        name            => 'default',
        orgId           => 1,
        folder          => '',
        type            => 'file',
        disableDeletion => true,
        options         => {
          path         => '/var/lib/grafana/dashboards',
          puppetsource => 'puppet:///modules/my_custom_module/dashboards',
        },
      },
    ],
  }
}
```

Here is the same configuraiton example as a hiera hash.

```yaml
grafana::provisioning_dashboards:
  apiVersion: 1
  providers:
    - name: 'default'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: true
      options:
        path: '/var/lib/grafana/dashboards'
        puppetsource: 'puppet:///modules/my_custom_module/dashboards'
```

In both examples above a non-grafana option named `puppetsource` has
been used. When this module finds that the provisioning_dashboards hash
contains keys `path` and `puppetsource` in the `options` subhash, it
will do the following.
* It will create the path found in `options['path']`. Note: puppet
  will only create the final directory of the path unless the
  parameter `create_subdirs_provisioning` is set to true: this defaults
  to false.
* It will use `puppetsource` as the file resource's 'source' for the
  directory.
* It removes the `puppetsource` key from the `options` subhash, so the
  subsequent yaml file for gafana does not contain this key. (The
  `path` key will remain.)

This feature allows you to define a custom module, and place any
dashboards you want provisioned in the its `files/` directory. In the
example above you would put dashboards into
`my_custom_module/files/dashboards` and puppet-grafana will create
`/var/lib/grafana/dashboards` and provision it with the contents of
`my_custom_module/files/dashboards`.

Puppet's file resource may also be given a `file://` URI which may
point to a locally available directory on the filesystem, typically
the filesystem of the puppetserver/master. Thus you may specify a
local directory with grafana dashboards you wish to provision into
grafana.

##### Provisioning with dashboards from grafana.com

GrafanaLabs provides lots of [dashboards that may be reused](https://grafana.com/grafana/dashboards).
Those ones are **not directly usable** for provisioning (this is
a Grafana issue, not a Puppet one).

In order to have a "provisionable" dashboard in JSON format, you have
to prepare it before adding it in your Puppet code. Here are the steps
to follow:

1. Use a Grafana instance
1. Import the desired dashboard
1. Define its datasource
1. From the dashboard view:
    * Click the "Share dashboard" icon (top left corner of screen)
    * Select the "Export" tab,
    * Activate "Export for sharing externally"
    * Click "Save to file"
1. In the JSON file:
    * Remove the keys `__imports` and `__requires`
    * Replace all `${DS_PROMETHEUS}` by your datasource name
1. Once saved, you may place this JSON file in your
   `puppet:///modules/my_custom_module/dashboards` directory

**Note:**

This procedure have been tested with Grafana 6.x. It may not work for
 any dashboard, depending on how it's been coded.

Dashboards known to be "provisionable":

* [Node Exporter Server Metric](https://grafana.com/dashboards/405)
* [Prometheus Blackbox Exporter](https://grafana.com/dashboards/7587)

Dashboards known not to be "provisionable":

* [HTTP Services Status](https://grafana.com/dashboards/4859)

## Tasks

### `change_grafana_admin_password`

`old_password`: the old admin password

`new_password`: the password you want to use for the admin user

`uri`: `http` or `https`

`port`: the port Grafana runs on locally

This task can be used to change the password for the admin user in grafana

## Limitations

This module has been tested on every operating system in the metadata.json, using
each of the 'archive', 'docker' and 'package' installation methods. Other
configurations should work with minimal, if any, additional effort.

## Development

This module is a fork of
[bfraser/grafana](https://github.com/bfraser/puppet-grafana) maintained by [Vox
Pupuli](https://voxpupuli.org/). Vox Pupuli welcomes new contributions to this
module, especially those that include documentation and rspec tests. We are
happy to provide guidance if necessary.

Please see [CONTRIBUTING](.github/CONTRIBUTING.md) for more details.

### Authors
* Bill Fraser <fraser@pythian.com>
* Vox Pupuli Team

## Copyright and License

Copyright (C) 2015 Bill Fraser

Bill can be contacted at: fraser@pythian.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
