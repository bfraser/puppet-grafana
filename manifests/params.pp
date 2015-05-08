# == Class grafana::params
#
# This class is meant to be called from grafana
# It sets variables according to platform
#
class grafana::params {
  $cfg              = {}
  $cfg_location     = '/etc/grafana/grafana.ini'
  $container_cfg    = false
  $container_params = {}
  $data_dir         = '/var/lib/grafana'
  $docker_image     = 'grafana/grafana:latest'
  $docker_ports     = '3000:3000'
  $install_dir      = '/usr/share/grafana'
  $install_method   = 'package'
  $log_dir          = '/var/log/grafana'
  $package_name     = 'grafana'
  $service_name     = 'grafana-server'
  $version          = '2.0.2'
}
