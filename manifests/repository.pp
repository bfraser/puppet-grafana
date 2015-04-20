class grafana::repository {

  case $operatingsystem {
    'RedHat', 'CentOS': {
      fail('CentOS repository support must be implemented, please fix')
    }
    /^(Debian|Ubuntu)$/:{
      include grafana::repository::debian
    }
    default: {
      fail('Unsupported operating system repository')
    }
  }
}
