# == Class: grafana
#
# Installs and configures Grafana.
#
# === Parameters
# [*archive_source*]
# Download location of tarball to be used with the 'archive' install method.
# Defaults to the URL of the latest version of Grafana available at the time of module release.
#
# [*install_dir*]
# Installation directory to be used with the 'archive' install method.
# Defaults to '/opt/grafana'.
#
# [*install_method*]
# Set to 'archive' to install Grafana using the tar archive.
# Set to 'docker' to install Grafana using the official Docker container.
# Set to 'package' to install Grafana using .deb or .rpm packages.
# Defaults to 'package'.
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
# Defaults to 'grafana'.
#
# [*version*]
# The version of Grafana to install and manage.
# Defaults to the latest version of Grafana available at the time of module release.
#
# === Examples
#
#  class { '::grafana':
#    install_method  => 'docker',
#  }
#
class grafana (
  $archive_source = "https://grafanarel.s3.amazonaws.com/builds/grafana-${version}.x86_64.tar.gz",
  $cfg_location   = $::grafana::params::cfg_location,
  $cfg            = $::grafana::params::cfg,
  $install_dir    = $::grafana::params::install_dir,
  $install_method = $::grafana::params::install_method,
  $package_name   = $::grafana::params::package_name,
  $package_source = $::osfamily ? {
    'Debian'          => "https://grafanarel.s3.amazonaws.com/builds/grafana_${version}_amd64.deb",
    /(RedHat|Amazon)/ => 'https://grafanarel.s3.amazonaws.com/builds/grafana-2.0.0_beta1-1.x86_64.rpm',
    default           => $::grafana::archive_source
  },
  $service_name   = $::grafana::params::service_name,
  $version        = $::grafana::params::version
) inherits grafana::params {

  # validate parameters here
  if !is_hash($cfg) {
    fail('cfg parameter must be a hash')
  }

  class { 'grafana::install': } ->
  class { 'grafana::config': } ~>
  class { 'grafana::service': }

  contain 'grafana::install'
  contain 'grafana::service'

  #Class['grafana']
}
