# == Class grafana::service
#
# This class is meant to be called from grafana
# It ensure the service is running
#
class grafana::service {
  case $::grafana::install_method {
    'docker': {
      $container = {
        'grafana' => $::grafana::container_params
      }

      $defaults = {
        image => $::grafana::params::docker_image,
        ports => $::grafana::params::docker_ports
      }

      create_resources(docker::run, $container, $defaults)
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
