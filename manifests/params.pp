# == Class grafana::params
#
# This class is meant to be called from grafana
# It sets variables according to platform
#
class grafana::params {
 $install_method = 'package'
  case $::osfamily {
    'Debian': {
      $package_name   = 'grafana'
      $package_source = 'https://grafanarel.s3.amazonaws.com/builds/grafana_2.0.0-beta1_amd64.deb'
      $service_name   = 'grafana'
    }
    'RedHat', 'Amazon': {
      $package_name   = 'grafana'
      $package_source = 'https://grafanarel.s3.amazonaws.com/builds/grafana-2.0.0_beta1-1.x86_64.rpm'
      $service_name   = 'grafana'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
