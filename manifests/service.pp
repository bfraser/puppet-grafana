# == Class grafana::service
#
# This class is meant to be called from grafana
# It ensure the service is running
#
class grafana::service {
  case $::grafana::install_method {
    'docker': {
      docker::run { 'grafana':
        image => 'grafana/grafana:latest', # parameterize the version
        ports => '3000' # parameterize this
      }
    }
    /(package|archive)/: {
      service { $::grafana::service_name:
        ensure => running,
        enable => true
      }
    }
    default: {
      fail("Installation method ${::grafana::install_method} not supported")
    }
  }
}
