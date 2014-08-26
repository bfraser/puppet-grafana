class grafana (
    $version            = $grafana::params::version,
    $download_url       = "http://grafanarel.s3.amazonaws.com/grafana-${version}.tar.gz",
    $install_dir        = $grafana::params::install_dir,
    $symlink            = $grafana::params::symlink,
    $symlink_name       = "${install_dir}/grafana",
    $grafana_user       = $grafana::params::grafana_user,
    $grafana_group      = $grafana::params::grafana_group,
    $datasource         = $grafana::params::datasource,
    $elasticsearch_url  = $grafana::params::elasticsearch_url,
    $graphite_url       = $grafana::params::graphite_url,
    $influxdb_url       = $grafana::params::influxdb_url,
    $influxdb_user      = $grafana::params::influxdb_user,
    $influxdb_password  = $grafana::params::influxdb_password,
    $opentsdb_url       = $grafana::params::opentsdb_url,
    $admin_password     = $grafana::params::admin_password,
    $playlist_timespan  = $grafana::params::playlist_timespan,
) inherits grafana::params {
    archive { "grafana-${version}":
        ensure   => present,
        url      => $download_url,
        target   => $install_dir,
        checksum => false,
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
