class grafana::repository::debian {

  apt::source { 'grafana':
    location    => 'https://packagecloud.io/grafana/testing/debian/',
    release     => 'wheezy',
    repos       => 'main',
    key         => 'D59097AB',
    key_source  => 'https://packagecloud.io/gpg.key',
    include_src => false,
  }

}
