# == Class grafana::params
#
# This class is meant to be called from grafana
# It sets variables according to platform
#
class grafana::params {
  $archive_source      = undef
  $cfg                 = {}
  $container_cfg       = false
  $container_params    = {}
  $data_dir            = '/var/lib/grafana'
  $docker_image        = 'grafana/grafana'
  $docker_ports        = '3000:3000'
  $install_dir         = '/usr/share/grafana'
  $ldap_cfg            = false
  $package_name        = 'grafana'
  $package_source      = undef
  $rpm_iteration       = '1'
  $repo_name           = 'stable'

  case $::osfamily {
    'Archlinux': {
      $manage_package_repo = false
      $install_method      = 'repo'
      $cfg_location        = '/etc/grafana.ini'
      $service_name        = 'grafana'
      $version             = 'present'
    }
    default: {
      $manage_package_repo = true
      $install_method      = 'package'
      $cfg_location        = '/etc/grafana/grafana.ini'
      $service_name        = 'grafana-server'
      $version             = '2.5.0'
    }
  }
}
