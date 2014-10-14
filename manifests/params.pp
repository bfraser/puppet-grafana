# == Class: grafana
#
# Default parameters
#
class grafana::params {
  $version            = '1.8.1'
  $install_method     = 'archive'
  $install_dir        = '/opt'
  $symlink            = false
  $grafana_user       = 'root'
  $grafana_group      = 'root'
  $datasources        = {
    'graphite' => {
      'type'    => 'graphite',
      'url'     => 'http://localhost:80',
      'default' => 'true' # lint:ignore:quoted_booleans
    },
    'elasticsearch' => {
      'type'      => 'elasticsearch',
      'url'       => 'http://localhost:9200',
      'index'     => 'grafana-dash',
      'grafanaDB' => 'true' # lint:ignore:quoted_booleans
    },
  }
}
