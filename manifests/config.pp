# == Class grafana::config
#
# This class is called from grafana
#
class grafana::config {
  if $::grafana::install_method =~ /archive|package/ {
    $cfg = $::grafana::cfg

    file {  $::grafana::cfg_location:
      ensure  => present,
      content => template('grafana/config.ini.erb'),
    }
  }
  elsif $::grafana::install_method == 'docker' {
    if $::grafana::container_cfg {
      $cfg = $::grafana::cfg

      file {  $::grafana::cfg_location:
        ensure  => present,
        content => template('grafana/config.ini.erb'),
      }
    }
  }
}
