class grafana (
    $version            = $grafana::params::version,
    $download_url       = $grafana::params::download_url,
    $install_dir        = $grafana::params::install_dir,
    $user               = $grafana::params::user,
    $group              = $grafana::params::group,
    $graphite_host      = $grafana::params::graphite_host,
    $graphite_port      = $grafana::params::graphite_port,
    $elasticsearch_host = $grafana::params::elasticsearch_host,
    $elasticsearch_port = $grafana::params::elasticsearch_port,
) inherits grafana::params {
    archive { "grafana-${version}":
        ensure      => present,
        url         => $download_url,
        target      => $install_dir,
        checksum    => false,
    }

    file { "${install_dir}/grafana-${version}/config.js":
        ensure  => present,
        content => template('grafana/config.js.erb'),
        owner   => $user,
        group   => $group,
        require => Archive["grafana-${version}"],
    }
}
