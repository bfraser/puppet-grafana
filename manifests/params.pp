class grafana::params {
    $version            = '1.6.1'
    $install_dir        = '/opt'
    $symlink            = true
    $symlink_name       = "${install_dir}/grafana"
    $grafana_user       = 'root'
    $grafana_group      = 'root'
    $elasticsearch_host = 'localhost'
    $elasticsearch_port = 9200
    $graphite_host      = 'localhost'
    $graphite_port      = 80
    $influxdb_host      = 'localhost'
    $influxdb_port      = 8086
    $influxdb_user      = 'root'
    $influxdb_password  = 'root'
    $influxdb_dbname    = 'database_name'
}