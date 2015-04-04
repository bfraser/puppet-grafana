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
    'package': {
      service { 'grafana':
        ensure => 'running',
        enable => true
      }
    }
    'archive': {
      # start grafana by executing ./grafana web
      # working directory must be set to the root install dir
    }
  }
}
