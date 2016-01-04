# == Class grafana::params
#
# This class is meant to be called from grafana
# It sets variables according to platform
#
class grafana::params {
  $cfg_location        = '/etc/grafana/grafana.ini'
  $cfg                 = {}
  $container_cfg       = false
  $container_params    = {}
  $data_dir            = '/var/lib/grafana'
  $docker_image        = 'grafana/grafana:latest'
  $docker_ports        = '3000:3000'
  $install_dir         = '/usr/share/grafana'
  $install_method      = 'package'
  $ldap_cfg            = false
  $manage_package_repo = true
  $package_name        = 'grafana'
  $rpm_iteration       = '1'
  $service_name        = 'grafana-server'
  $version             = '2.5.0'
  $archive_source      = "https://grafanarel.s3.amazonaws.com/builds/grafana-<%= scope.lookupvar('::grafana::version') %>.linux-x64.tar.gz"
  $package_source      = $::osfamily ? {
    /(RedHat|Amazon)/ => "https://grafanarel.s3.amazonaws.com/builds/grafana-<%= scope.lookupvar('::grafana::version') %>-<%= scope.lookupvar('::grafana::rpm_iteration') %>.x86_64.rpm",
    'Debian'          => "https://grafanarel.s3.amazonaws.com/builds/grafana_<%= scope.lookupvar('::grafana::version') %>_amd64.deb",
    default           => $archive_source,
  }

}
