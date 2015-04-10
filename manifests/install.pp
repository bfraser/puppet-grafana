# == Class grafana::install
#
class grafana::install {
  case $::grafana::install_method {
    'docker': {
      docker::image { 'grafana/grafana':
        image_tag => 'latest',
        require   => Class['docker']
      }
    }
    'package': {
      case $::osfamily {
        'Debian': {
          wget::fetch { 'grafana':
            source      => $::grafana::package_source,
            destination => '/tmp/grafana.deb'
          }
          
          package { $::grafana::package_name:
            ensure   => present,
            provider => 'dpkg',
            source   => '/tmp/grafana.deb',
            require  => Wget::Fetch['grafana']
          }
        }
        'RedHat': {
          package { $::grafana::package_name:
            ensure   => present,
            provider => 'rpm',
            source   => $::grafana::package_source
          }
        }
        default: {
          fail("${::operatingsystem} not supported")
        }
      }
    }
    'archive': {
      # create log directory /var/log/grafana (or parameterize)

      archive { $::grafana::version:
        ensure           => present,
        checksum         => false,
        strip_components => 1,
        target           => "${::grafana::install_dir}/versions/${::grafana::version}",
        url              => $::grafana::archive_source
      }

      file { "${::grafana::install_dir}/current":
        ensure  => link,
        target  => "${::grafana::install_dir}/versions/${::grafana::version}",
        require => Archive[$::grafana::version]
      }

      file { "${::grafana::install_dir}/current/scripts/init.sh":
        ensure  => present,
        mode    => '0755',
        require => File["${::grafana::install_dir}/current"]
      }
      
      file { '/etc/init.d/grafana':
        ensure  => link,
        target  => "${::grafana::install_dir}/current/scripts/init.sh",
        require => File["${::grafana::install_dir}/current/scripts/init.sh"]
      }

      user { 'grafana':
        ensure  => present,
        home    => $::grafana::install_dir,
        require => Archive[$::grafana::version]
      }

      file { $::grafana::install_dir:
        ensure       => directory,
        group        => 'grafana',
        owner        => 'grafana',
        recurse      => true,
        recurselimit => 2,
        require      => User['grafana']
      }

      file { '/etc/grafana':
        ensure  => directory,
        group   => 'grafana',
        owner   => 'grafana',
        require => User['grafana']
      }
    }
    default: {
      fail("Installation method ${::grafana::install_method} not supported")
    }
  }
}
