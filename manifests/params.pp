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

  $grafana_version     = '2.1.0'
  $rpm_iteration       = '1'
  $archive_source = "https://grafanarel.s3.amazonaws.com/builds/grafana-${grafana_version}.linux-x64.tar.gz"

  case $::osfamily {
    /(RedHat|Amazon)/: {
      $version        = "${grafana_version}-${rpm_iteration}"
      $package_source = "https://grafanarel.s3.amazonaws.com/builds/grafana-${version}.x86_64.rpm"
    }
    'Debian': {
      $version        = $grafana_version
      $package_source = "https://grafanarel.s3.amazonaws.com/builds/grafana_${version}_amd64.deb"
    }
    default: {
      $version        = $grafana_version
      $package_source = $archive_source
    }
  }
}
