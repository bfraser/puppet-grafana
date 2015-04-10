# == Class grafana::config
#
# This class is called from grafana
#
class grafana::config {

  $cfg = $::grafana::cfg

  file {  $::grafana::cfg_location:
    ensure  => present,
    content => template('grafana/config.ini.erb'),
  }
}
