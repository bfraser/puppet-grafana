class grafana::params {
    $version            = '1.6.1'
    $install_dir        = '/opt'
    $symlink            = true
    $grafana_user       = 'root'
    $grafana_group      = 'root'
    $datasource         = 'influxdb'
    $elasticsearch_url  = 'http://localhost:9200/'
    $graphite_url       = 'http://localhost/'
    $influxdb_url       = 'http://localhost:8086/db/database_name'
    $influxdb_user      = 'root'
    $influxdb_password  = 'root'
    $opentsdb_url       = 'http://localhost:4242'
}
