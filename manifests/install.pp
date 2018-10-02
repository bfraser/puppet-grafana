# == Class grafana::install
#
class grafana::install {
  $base_url = 'https://s3-us-west-2.amazonaws.com/grafana-releases/release'
  if $::grafana::archive_source != undef {
    $real_archive_source = $::grafana::archive_source
  }
  else {
    $real_archive_source = "${base_url}/grafana-${::grafana::version}.linux-x64.tar.gz"
  }

  if $::grafana::package_source != undef {
    $real_package_source = $::grafana::package_source
  }
  else {
    $real_package_source = $::osfamily ? {
      /(RedHat|Amazon)/ => "${base_url}/grafana-${::grafana::version}-${::grafana::rpm_iteration}.x86_64.rpm",
      'Debian'          => "${base_url}/builds/grafana_${::grafana::version}_amd64.deb",
      default           => $real_archive_source,
    }
  }

  case $::grafana::install_method {
    'docker': {
      docker::image { 'grafana/grafana':
        image_tag => $::grafana::version,
        require   => Class['docker'],
      }
    }
    'package': {
      case $facts['os']['family'] {
        'Debian': {
          package { 'libfontconfig1':
            ensure => present,
          }

          archive { '/tmp/grafana.deb':
            source  => $real_package_source,
          }

          package { $::grafana::package_name:
            ensure   => present,
            provider => 'dpkg',
            source   => '/tmp/grafana.deb',
            require  => [Archive['/tmp/grafana.deb'],Package['libfontconfig1']],
          }
        }
        'RedHat': {
          package { 'fontconfig':
            ensure => present,
          }

          package { $::grafana::package_name:
            ensure   => present,
            provider => 'rpm',
            source   => $real_package_source,
            require  => Package['fontconfig'],
          }
        }
        default: {
          fail("${facts['os']['family']} not supported")
        }
      }
    }
    'repo': {
      case $facts['os']['family'] {
        'Debian': {
          package { 'libfontconfig1':
            ensure => present,
          }

          if ( $::grafana::manage_package_repo ){
            if !defined( Class['apt'] ) {
              class { '::apt': }
            }
            apt::source { 'grafana':
              location => "https://packagecloud.io/grafana/${::grafana::repo_name}/debian",
              release  => 'stretch',
              repos    => 'main',
              key      =>  {
                'id'     => '418A7F2FB0E1E6E7EABF6FE8C2E73424D59097AB',
                'source' => 'https://packagecloud.io/gpg.key',
              },
              before   => Package[$::grafana::package_name],
            }
            Class['apt::update'] -> Package[$::grafana::package_name]
          }

          package { $::grafana::package_name:
            ensure  => $::grafana::version,
            require => Package['libfontconfig1'],
          }
        }
        'RedHat': {
          package { 'fontconfig':
            ensure => present,
          }

          if ( $::grafana::manage_package_repo ){
            yumrepo { 'grafana':
              descr    => 'grafana repo',
              baseurl  => "https://packagecloud.io/grafana/${::grafana::repo_name}/el/${::operatingsystemmajrelease}/\$basearch",
              gpgcheck => 1,
              gpgkey   => 'https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana',
              enabled  => 1,
              before   => Package[$::grafana::package_name],
            }
          }

          if $::grafana::version =~ /(installed|latest|present)/ {
            $real_version = $::grafana::version
          } else {
            $real_version = "${::grafana::version}-${::grafana::rpm_iteration}"
          }

          package { $::grafana::package_name:
            ensure  => $real_version,
            require => Package['fontconfig'],
          }
        }
        'Archlinux': {
          if $::grafana::manage_package_repo {
            fail('manage_package_repo is not supported on Archlinux')
          }
          package { $::grafana::package_name:
            ensure  => 'present', # pacman provider doesn't have feature versionable
          }
        }
        default: {
          fail("${::operatingsystem} not supported")
        }
      }
    }
    'archive': {
      # create log directory /var/log/grafana (or parameterize)

      if !defined(User['grafana']){
        user { 'grafana':
          ensure => present,
          home   => $::grafana::install_dir,
        }
      }

      file { $::grafana::install_dir:
        ensure  => directory,
        group   => 'grafana',
        owner   => 'grafana',
        require => User['grafana'],
      }

      archive { '/tmp/grafana.tar.gz':
        ensure          => present,
        extract         => true,
        extract_command => 'tar xfz %s --strip-components=1',
        extract_path    => $::grafana::install_dir,
        source          => $real_archive_source,
        user            => 'grafana',
        group           => 'grafana',
        cleanup         => true,
        require         => File[$::grafana::install_dir],
      }

    }
    default: {
      fail("Installation method ${::grafana::install_method} not supported")
    }
  }
}
