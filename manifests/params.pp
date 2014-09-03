class grafana::params {
    $version            = '1.7.1'
    $install_method     = 'archive'
    $install_dir        = '/opt'
    $symlink            = false
    $grafana_user       = 'root'
    $grafana_group      = 'root'
    $datasources        = {
      'graphite' => {
        'type'    => 'graphite',
        'url'     => 'http://localhost:80',
        'default' => 'true'
      },
      'elasticsearch' => {
        'type'      => 'elasticsearch',
        'url'       => 'http://localhost:9200',
        'index'     => 'grafana-dash',
        'grafanaDB' => 'true',
      },
    }
}