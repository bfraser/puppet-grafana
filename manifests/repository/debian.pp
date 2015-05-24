class grafana::repository::debian {

  apt::source { 'grafana':
    location    => 'https://packagecloud.io/grafana/testing/debian/',
    release     => 'wheezy',
    repos       => 'main',
    key         => {
      id     => '418A7F2FB0E1E6E7EABF6FE8C2E73424D59097AB',
      source => 'https://packagecloud.io/gpg.key'
    }
  }

}
