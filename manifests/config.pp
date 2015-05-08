# == Class grafana::config
#
# This class is called from grafana
#
class grafana::config {
  file {
    $::grafana::log_dir:
      ensure => directory,
      group  => 'grafana',
      mode   => '0750',
      owner  => 'grafana';

    "${::grafana::log_dir}/grafana.log":
      ensure  => file,
      group   => 'grafana',
      owner   => 'grafana',
      require => File[$::grafana::log_dir];
  }

  case $::grafana::install_method {
    'docker': {
      if $::grafana::container_cfg {
        $cfg = $::grafana::cfg

        file {  $::grafana::cfg_location:
          ensure  => present,
          content => template('grafana/config.ini.erb'),
        }
      }
    }
    'package': {
      $cfg = $::grafana::cfg

      file {  $::grafana::cfg_location:
        ensure  => present,
        content => template('grafana/config.ini.erb'),
      }
    }
    'archive': {
      $cfg = $::grafana::cfg

      file { "${::grafana::install_dir}/conf/custom.ini":
        ensure  => present,
        content => template('grafana/config.ini.erb'),
      }
    }
    default: {
      fail("Installation method ${::grafana::install_method} not supported")
    }
  }
}
