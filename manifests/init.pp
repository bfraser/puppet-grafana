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
# Defaults to the latest version of Grafana available at the time of module release.
#
# [*repo_name*]
# When using 'repo' install_method, the repo to look for packages in.
# Set to 'stable' to install only stable versions
# Set to 'testing' to install beta versions
# Defaults to stable.
#
# === Examples
#
#  class { '::grafana':
#    install_method  => 'docker',
#  }
#
class grafana (
  $archive_source      = $::grafana::params::archive_source,
  $cfg_location        = $::grafana::params::cfg_location,
  $cfg                 = $::grafana::params::cfg,
  $ldap_cfg            = $::grafana::params::ldap_cfg,
  $container_cfg       = $::grafana::params::container_cfg,
  $container_params    = $::grafana::params::container_params,
  $data_dir            = $::grafana::params::data_dir,
  $install_dir         = $::grafana::params::install_dir,
  $install_method      = $::grafana::params::install_method,
  $manage_package_repo = $::grafana::params::manage_package_repo,
  $package_name        = $::grafana::params::package_name,
  $package_source      = $::grafana::params::package_source,
  $repo_name           = $::grafana::params::repo_name,
  $rpm_iteration       = $::grafana::params::rpm_iteration,
  $service_name        = $::grafana::params::service_name,
  $version             = $::grafana::params::version
) inherits grafana::params {

  # validate parameters here
  if !is_hash($cfg) {
    fail('cfg parameter must be a hash')
  }

  anchor { 'grafana::begin': } ->
  class { '::grafana::install': } ->
  class { '::grafana::config': } ~>
  class { '::grafana::service': } ->
  anchor { 'grafana::end': }
}
