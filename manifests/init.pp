class grafana (
    $version            = $grafana::params::version,
    $download_url       = "http://grafanarel.s3.amazonaws.com/grafana-${version}.tar.gz",
    $install_dir        = $grafana::params::install_dir,
    $symlink            = $grafana::params::symlink,
    $symlink_name       = "${install_dir}/grafana",
    $grafana_user       = $grafana::params::grafana_user,
    $grafana_group      = $grafana::params::grafana_group,
    $elasticsearch_scheme = $grafana::params::elasticsearch_scheme,
    $elasticsearch_host = $grafana::params::elasticsearch_host,
    $elasticsearch_port = $grafana::params::elasticsearch_port,
    $graphite_scheme    = $grafana::params::graphite_scheme,
    $graphite_host      = $grafana::params::graphite_host,
    $graphite_port      = $grafana::params::graphite_port,
    $influxdb_scheme    = $grafana::params::influxdb_scheme,
    $influxdb_host      = $grafana::params::influxdb_host,
    $influxdb_port      = $grafana::params::influxdb_port,
    $influxdb_user      = $grafana::params::influxdb_user,
    $influxdb_password  = $grafana::params::influxdb_password,
    $influxdb_dbname    = $grafana::params::influxdb_dbname,
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
        owner   => $grafana_user,
        group   => $grafana_group,
        require => Archive["grafana-${version}"],
    }

    if $symlink {
        file { $symlink_name:
            ensure  => link,
            target  => "${install_dir}/grafana-${version}",
            require => Archive["grafana-${version}"],
        }
    }
}
