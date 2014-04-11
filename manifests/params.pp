class grafana::params {
    $version            = '1.5.2'
    $download_url       = "https://github.com/torkelo/grafana/releases/download/v${version}/grafana-${version}.tar.gz"
    $install_dir        = '/opt'
    $user               = 'root'
    $group              = 'root'
    $graphite_host      = 'localhost'
    $graphite_port      = 80
    $elasticsearch_host = 'localhost'
    $elasticsearch_port = 9200
}
