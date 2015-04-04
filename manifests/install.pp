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
          
          package { 'grafana':
            provider => 'dpkg',
            source   => '/tmp/grafana.deb',
            require  => Wget::Fetch['grafana']
          }
        }
        'RedHat': {
          package { 'grafana':
            provider => 'rpm',
            source   => $::grafana::package_source
          }
        }
      }
    }
    'archive': {
      # extract archive to /opt/grafana/versions/<version>
      # symlink /opt/grafana/current to /opt/grafana/versions/<version>
      # symlink /etc/init.d/grafana to /opt/grafana/current/scripts/init.sh
      # copy /opt/grafana/current/conf/defaults.ini to /etc/grafana/grafana.ini
      # create log directory /var/log/grafana (or parameterize)
    }
    default: {
      fail("Installation method ${::grafana::install_method} not supported")
    }
  }
}
