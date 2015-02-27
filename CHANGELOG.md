# 1.0.1 (2015-02-27)

**Enhancements**
- New parameter for Grafana admin password

**Fixes**
- Package install method now makes use of install_dir for config.js path

**Behind The Scenes**
- Add archive module to .fixtures.yml
- Unquote booleans to make lint happy
- Fix license identifier and unbounded dependencies in module metadata
- Allow Travis to fail on Ruby 1.8.7
- More Puppet versions are tested by Travis

# 1.0.0 (2014-12-16)

**Enhancements**
- Add max_search_results parameter
- Install Grafana 1.9.0 by default

**Documentation**
- Add download_url and install_method parameters to README

**Behind The Scenes**
- [Issue #6](https://github.com/bfraser/puppet-grafana/issues/6) Replace gini/archive dependency with camptocamp/archive
- Addition of CHANGELOG
- Style fixes
- Removal of vagrant-wrapper gem
- Fancy badges for build status

# 0.2.2 (2014-10-27)

**Enhancements**
- Add default_route parameter to manage start dashboard

**Fixes**
- Symlink behavior

**Behind The Scenes**
- [Issue #9](https://github.com/bfraser/puppet-grafana/issues/9) Remove stdlib inclusion from manifest

# 0.2.1 (2014-10-14)

**Enhancements**
- Support for multiple datasources
- Install Grafana 1.8.1 by default

**Behind The Scenes**
- Added RSpec tests
- Add stdlib as a module dependency
- Add operating system compatibility

# 0.1.3 (2014-07-03)

**Enhancements**
- Added support for InfluxDB

# 0.1.2 (2014-06-30)

First release on the Puppet Forge