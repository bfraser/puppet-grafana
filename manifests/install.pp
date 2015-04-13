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
          package { 'libfontconfig':
            ensure => present
          }

          wget::fetch { 'grafana':
            source      => $::grafana::package_source,
            destination => '/tmp/grafana.deb'
          }
          
          package { $::grafana::package_name:
            ensure   => present,
            provider => 'dpkg',
            source   => '/tmp/grafana.deb',
            require  => [Wget::Fetch['grafana'],Package['libfontconfig']]
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

      archive { 'grafana':
        ensure           => present,
        checksum         => false,
        root_dir         => 'public',
        strip_components => 1,
        target           => $::grafana::install_dir,
        url              => $::grafana::archive_source
      }

      user { 'grafana':
        ensure  => present,
        home    => $::grafana::install_dir,
        require => Archive['grafana']
      }

      file { $::grafana::install_dir:
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
