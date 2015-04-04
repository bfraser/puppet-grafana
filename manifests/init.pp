# == Class: grafana
#
# Installs and configures Grafana.
#
# === Parameters
# [*install_method*]
# Set to 'archive' to install Grafana using the tar archive.
# Set to 'docker' to install Grafana using the official Docker container.
# Set to 'package' to install Grafana using .deb or .rpm packages.
# Defaults to 'package'.
#
# === Examples
#
#  class { '::grafana':
#    install_method  => 'docker',
#  }
#
class grafana (
  $install_method = $::grafana::params::install_method,
  $package_name   = $::grafana::params::package_name,
  $package_source = $::grafana::params::package_source,
  $service_name   = $::grafana::params::service_name,
  $version        = $::grafana::params::version,
) inherits grafana::params {

  # validate parameters here

  class { 'grafana::install': } ->
  class { 'grafana::config': } ~>
  class { 'grafana::service': }

  contain 'grafana::install'
  contain 'grafana::service'
  
  #Class['grafana']
}
