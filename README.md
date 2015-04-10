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
5. [Limitations](#limitations)
6. [Copyright and License](#copyright-and-license)

##Overview

This module installs Grafana, a dashboard and graph editor for Graphite, InfluxDB and OpenTSDB.

##Module Description

Version 2.x of this module is designed to work with version 2.x of Grafana. If you would like to continue to use Grafana 1.x, please use version 1.x of this module.

##Setup

This module will:

* Install Grafana using your preferred method: package (default), Docker container, or tar archive
* Allow you to override the version of Grafana to be installed, and / or the package source
* Perform basic configuration of Grafana

###Beginning with Grafana

To install Grafana with the default parameters:

```puppet
    class { 'grafana': }
```

This assumes that you with to install Grafana using the 'package' method. To establish customized parameters:

```puppet
    class { 'grafana':
      install_method  => 'docker',
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

#####`install_method`

Controls which method to use for installing Grafana. Valid options are: 'archive', 'docker' and 'package'. The default is 'package'. If you wish to use the 'docker' installation method, you will need to include the 'docker' class in your node's manifest / profile.

#####`cfg_location`

Configures the location to which the Grafana configuration is written. The default location is '/etc/grafana/grafana.ini'.

#####`cfg`

Manages the Grafana configuration file. Grafana comes with its own default settings in a different configuration file (/opt/grafana/current/conf/defaults.ini), therefore this module does not supply any defaults.

This parameter only accepts a hash as its value. Keys with hashes as values will generate sections, any other values are just plain values. The example below will result in...

```puppet
    class { 'grafana':
      cfg => {
        app_mode => 'production',
        server   => {
          http_port     => 8080,
        },
        database => {
          type          => 'sqlite3',
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
type = sqlite3
host = 127.0.0.1:3306
name = grafana
user = root
password =

[users]
allow_sign_up = false
```

Some minor notes:

 - If you want empty values, just use an empty string.
 - Keys that contains dots (like auth.google) need to be quoted.
 - The order of the keys in this hash is the same as they will be written to the configuration file. So settings that do not fall under a section will have to come before any sections in the hash.

##Limitations

This module has been tested on Ubuntu 14.04, using the 'docker' and 'package' installation methods. Other configurations should work with minimal, if any, additional effort.

##Copyright and License

Copyright (C) 2015 Bill Fraser

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
