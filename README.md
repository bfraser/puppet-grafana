#grafana

[![Puppet Forge](http://img.shields.io/puppetforge/v/bfraser/grafana.svg)](https://forge.puppetlabs.com/bfraser/grafana)
[![Build Status](http://img.shields.io/travis/bfraser/puppet-grafana.svg)](http://travis-ci.org/bfraser/puppet-grafana)

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Beginning with Grafana](#beginning-with-grafana)
4. [Usage](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
    * [Templates](#templates)
5. [Limitations](#limitations)
6. [Copyright and License](#copyright-and-license)

##Overview

This module installs Grafana, a dashboard and graph editor for Graphite, InfluxDB and OpenTSDB.

##Module Description

This module assumes you will be using, and has only been tested against, Graphite. Therefore it is assumed you have a Graphite installation Grafana will be pulling data from. This module does **not** manage Graphite in any way.

##Setup

This module assumes that you will be serving Grafana using a web server such as Apache or Nginx. It will:

* Download and extract Grafana to an installation directory or use your package manager
* Create a symlink in the installation directory to enable future version upgrades if not using a package manager
* Configure Grafana with a default Graphite and Elasticsearch host of 'localhost'
* Allow you to override the Grafana version, download URL, and Graphite / Elasticsearch urls

Add the following to your manifest to create an Apache virtual host to serve Grafana. **NOTE** This requires the puppetlabs-apache module.

```puppet
    # Grafana is to be served by Apache
    class { 'apache':
        default_vhost   => false,
    }

    # Create Apache virtual host
    apache::vhost { 'grafana.example.com':
        servername      => 'grafana.example.com',
        port            => 80,
        docroot         => '/opt/grafana',
        error_log_file  => 'grafana-error.log',
        access_log_file => 'grafana-access.log',
        directories     => [
            {
                path            => '/opt/grafana',
                options         => [ 'None' ],
                allow           => 'from All',
                allow_override  => [ 'None' ],
                order           => 'Allow,Deny',
            }
        ]
    }
```

###Beginning with Grafana

To install Grafana with the default parameters:

```puppet
    class { 'grafana': }
```

This assumes that you have Graphite running on the same server as Grafana, and that you want to install Grafana to in /opt. To establish customized parameters:

```puppet
    class { 'grafana':
      install_dir  => '/usr/local',
      datasources  => {
        'graphite' => {
          'type'    => 'graphite',
          'url'     => 'http://172.16.0.10',
          'default' => 'true'
        },
        'elasticsearch' => {
          'type'      => 'elasticsearch',
          'url'       => 'http://172.16.0.10:9200',
          'index'     => 'grafana-dash',
          'grafanaDB' => 'true',
        },
      }
    }
```
##Usage

###Classes and Defined Types

####Class: `grafana`

The Grafana module's primary class, `grafana`, guides the basic setup of Grafana on your system.

```puppet
    class { 'grafana': }
```
**Parameters within `grafana`:**

#####`datasources`

The graphite, elasticsearch, influxdb, and opentsdb connection properties. See init.pp for an example.

#####`default_route`

The default start dashboard. Defaults to '/dashboard/file/default.json'.

#####`grafana_group`

The group that will own the installation directory. The default is 'root' and there is no login in place to check that the value specified is a valid group on the system.

#####`grafana_user`

The user that will own the installation directory. The default is 'root' and there is no logic in place to check that the value specified is a valid user on the system.

#####`install_dir`

Controls which directory Grafana is downloaded and extracted in. The default value is '/opt'.

#####`max_search_results`

Max number of dashboards in search results. Defaults to 20.

#####`symlink`

Determines if a symlink should be created in the installation directory for the extracted archive. The default is 'true'.

#####`symlink_name`

Sets the name to be used for the symlink. The default is '${install_dir}/grafana'.

#####`version`

Controls the version of Grafana that gets downloaded and extracted. The default value is the latest stable version available at the time of module release.

###Templates

This module currently makes use of one template to manage Grafana's main configuration file, `config.js`.

##Limitations

This module has been tested on CentOS 6.4, serving Grafana with Apache. Other configurations should work with minimal, if any, additional effort.

##Copyright and License

Copyright (C) 2014 Bill Fraser

Bill can be contacted at: fraser@pythian.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
