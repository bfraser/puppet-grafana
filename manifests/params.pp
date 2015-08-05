# == Class grafana::params
#
# This class is meant to be called from grafana
# It sets variables according to platform
#
class grafana::params {
  $cfg_location        = '/etc/grafana/grafana.ini'
  $cfg                 = {}
  $container_cfg       = false
  $container_params    = {}
  $data_dir            = '/var/lib/grafana'
  $docker_image        = 'grafana/grafana:latest'
  $docker_ports        = '3000:3000'
  $install_dir         = '/usr/share/grafana'
  $install_method      = 'package'
  $manage_package_repo = true
  $package_name        = 'grafana'
  $service_name        = 'grafana-server'

  case $::operatingsystem {
    'RedHat','CentOS': { $version = '2.1.0-1' }
    'Debian','Ubuntu': { $version = '2.1.0'}
    default: { fail("Unsupported operating system: ${::operatingsystem}") }
  }
}
