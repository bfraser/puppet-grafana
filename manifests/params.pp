# == Class grafana::params
#
# This class is meant to be called from grafana
# It sets variables according to platform
#
class grafana::params {
  $cfg_location     = '/etc/grafana/grafana.ini'
  $cfg              = {}
  $container_cfg    = false
  $container_params = {}
  $docker_image     = 'grafana/grafana:latest'
  $docker_ports     = '3000:3000'
  $install_dir      = '/opt/grafana'
  $install_method   = 'package'
  $package_name     = 'grafana'
  $service_name     = 'grafana'
  $version          = '2.0.0-beta1'
}
