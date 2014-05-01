class grafana::params {
    $version            = '1.5.3'
    $download_url       = "http://grafanarel.s3.amazonaws.com/grafana-${version}.tar.gz"
    $install_dir        = '/opt'
    $symlink            = true
    $symlink_name       = "${install_dir}/grafana"
    $user               = 'root'
    $group              = 'root'
    $graphite_host      = 'localhost'
    $graphite_port      = 80
    $elasticsearch_host = 'localhost'
    $elasticsearch_port = 9200
}
