# == Class: grafana
#
# Default parameters
#
class grafana::params {
  $datasources        = {
    'elasticsearch' => {
      'grafanaDB' => true,
      'index'     => 'grafana-dash',
      'type'      => 'elasticsearch',
      'url'       => 'http://localhost:9200',
    },
    'graphite' => {
      'default' => true,
      'type'    => 'graphite',
      'url'     => 'http://localhost:80',
    },
  }

  $default_route      = '/dashboard/file/default.json'
  $grafana_group      = 'root'
  $grafana_user       = 'root'
  $admin_password     = ''
  $install_dir        = '/opt'
  $install_method     = 'archive'
  $max_search_results = 100
  $symlink            = true
  $version            = '1.9.0'
  $manage_repository  = false
  $config_ini         = '/etc/grafana/grafana.ini'
  $database_type      = 'sqlite3'
  $database_host      = '127.0.0.1:3306'
  $database_name      = 'grafana'
  $database_user      = 'root'
  $database_password  = ''

}
