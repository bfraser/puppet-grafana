# == Class: grafana
#
# Installs and configures Grafana.
#
# === Parameters
# [*archive_source*]
# Download location of tarball to be used with the 'archive' install method.
# Defaults to the URL of the latest version of Grafana available at the time of module release.
#
# [*container_cfg*]
# Boolean. Determines whether a configuration file should be generated when using the 'docker' install method.
# If true, use the `cfg` and `cfg_location` parameters to control creation of the file.
# Defaults to false.
#
# [*container_params*]
# Hash of parameters to use when creating the Docker container. For use with the 'docker' install method.
# Refer to documentation of the `docker::run` resource in the `garethr-docker` module for details of available parameters.
# Defaults to:
#
#   container_params => {
#     'image' => 'grafana/grafana:latest',
#     'ports' => '3000'
#   }
#
# [*data_dir*]
# The directory Grafana will use for storing its data.
# Defaults to '/var/lib/grafana'.
#
# [*install_dir*]
# Installation directory to be used with the 'archive' install method.
# Defaults to '/usr/share/grafana'.
#
# [*install_method*]
# Set to 'archive' to install Grafana using the tar archive.
# Set to 'docker' to install Grafana using the official Docker container.
# Set to 'package' to install Grafana using .deb or .rpm packages.
# Set to 'repo' to install Grafana using an apt or yum repository.
# Defaults to 'package'.
#
# [*manage_package_repo*]
# If true this will setup the official grafana repositories on your host. Defaults to true.
#
# [*package_name*]
# The name of the package managed with the 'package' install method.
# Defaults to 'grafana'.
#
# [*package_source*]
# Download location of package to be used with the 'package' install method.
# Defaults to the URL of the latest version of Grafana available at the time of module release.
#
# [*service_name*]
# The name of the service managed with the 'archive' and 'package' install methods.
# Defaults to 'grafana-server'.
#
# [*version*]
# The version of Grafana to install and manage.
# Defaults to 'installed'
#
# [*repo_name*]
# When using 'repo' install_method, the repo to look for packages in.
# Set to 'stable' to install only stable versions
# Set to 'beta' to install beta versions
# Defaults to stable.
#
# [*plugins*]
# A hash of plugins to be passed to `create_resources`, wraps around the
# `grafana_plugin` resource.
#
# [*provisioning_dashboards*]
# Hash of dashboards to provision into grafana. grafana > v5.0.0
# required. Hash will be converted into YAML and used by grafana to
# provision dashboards.
#
# [*provisioning_datasources*]
# Hash of datasources to provision into grafana, grafana > v5.0.0
# required. Hash will be converted into YAML and used by granfana to
# configure datasources.
#
# [*provisioning_dashboards_file*]
# String with the fully qualified path to place the provisioning file
# for dashboards, only used if provisioning_dashboards is specified.
# Defaults to '/etc/grafana/provisioning/dashboards/puppetprovisioned.yaml'
#
# [*provisioning_datasources_file*]
# String with the fully qualified path to place the provisioning file
# for datasources, only used if provisioning_datasources is specified.
# Default to '/etc/grafana/provisioning/datasources/puppetprovisioned.yaml'
#
# [*create_subdirs_provisioning*]
# Boolean, defaults to false. If true puppet will create any
# subdirectories in the given path when provisioning dashboards.
#
# [*sysconfig_location*]
# Location of the sysconfig file for the environment of the grafana-server service.
# This is only used when the install_method is 'package' or 'repo'.
#
# [*sysconfig*]
# A hash of environment variables for the grafana-server service
#
# Example:
#   sysconfig => { 'http_proxy' => 'http://proxy.example.com/' }
#
# [*ldap_servers*]
# A hash of ldap_servers to be passed to `create_resources`, wraps around the
# `grafana_ldap_server` resource.
#
# [*ldap_group_mappings*]
# A hash of ldap_servers to be passed to `create_resources`, wraps around the
# `grafana_ldap_group_mapping` resource.
#
# [*toml_manage_package*]
# ruby-toml is required to generate the TOML-based LDAP config for Grafana.
# Defaults to true. Set to false if you manage package- or gem-install
# somewhere else.
#
# [*toml_package_name*]
# Name of the software-package providing the TOML parser library.
# Defaults to ruby-toml.
#
# [*toml_package_ensure*]
# Ensure the package-resource - e.g. installed, absent, etc.
# https://puppet.com/docs/puppet/latest/types/package.html#package-attribute-ensure
# Defaults to present
#
# [*toml_package_provider*]
# The package-provider used to install the TOML parser library.
# Defaults to undef, to let Puppet decide. See
# https://puppet.com/docs/puppet/latest/types/package.html#package-attribute-provider
#
# === Examples
#
#  class { '::grafana':
#    install_method  => 'docker',
#  }
#
class grafana (
  Optional[String] $archive_source,
  String $cfg_location,
  Hash $cfg,
  Optional[Variant[Hash,Array]] $ldap_cfg,
  Boolean $container_cfg,
  Hash $container_params,
  String $docker_image,
  String $docker_ports,
  String $data_dir,
  String $install_dir,
  String $install_method,
  Boolean $manage_package_repo,
  String $package_name,
  Optional[String] $package_source,
  Enum['stable', 'beta'] $repo_name,
  String $rpm_iteration,
  String $service_name,
  String $version,
  Hash $plugins,
  Hash $provisioning_dashboards,
  Hash $provisioning_datasources,
  String $provisioning_dashboards_file,
  String $provisioning_datasources_file,
  Boolean $create_subdirs_provisioning,
  Optional[String] $sysconfig_location,
  Optional[Hash] $sysconfig,
  Hash[String[1], Hash] $ldap_servers,
  Hash[String[1], Hash] $ldap_group_mappings,
  Boolean $toml_manage_package,
  String[1] $toml_package_name,
  String[1] $toml_package_ensure,
  Optional[String[1]] $toml_package_provider,
) {
  contain grafana::install
  contain grafana::config
  contain grafana::service

  Class['grafana::install']
  -> Class['grafana::config']
  -> Class['grafana::service']

  create_resources(grafana_plugin, $plugins)
  # Dependency added for Grafana_plugins to ensure it runs at the
  # correct time.
  Class['grafana::config'] -> Grafana_Plugin <| |> ~> Class['grafana::service']

  create_resources('grafana_ldap_server', $ldap_servers)
  create_resources('grafana_ldap_group_mapping', $ldap_group_mappings)
}
