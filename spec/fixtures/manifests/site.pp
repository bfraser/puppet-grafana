define archive (
  $url,
  $target,
  $ensure           = present,
  $checksum         = true,
  $digest_url       = '',
  $digest_string    = '',
  $digest_type      = 'md5',
  $timeout          = 120,
  $root_dir         = '',
  $extension        = 'tar.gz',
  $src_target       = '/usr/src',
  $allow_insecure   = false,
  $allow_redirects  = true,
  $strip_components = 0,
  $username         = undef,
  $password         = undef,
  $proxy            = undef,
  $dependency_class = Class['archive::prerequisites'],
  $exec_path        = ['/usr/local/bin', '/usr/bin', '/bin']) { }

define archive::download (
  $url,
  $ensure          = present,
  $checksum        = true,
  $digest_url      = '',
  $digest_string   = '',
  $digest_type     = 'md5',
  $timeout         = 120,
  $src_target      = '/usr/src',
  $allow_insecure  = false,
  $allow_redirects = true,
  $username        = undef,
  $password        = undef,
  $proxy           = undef,
  $exec_path       = ['/usr/local/bin', '/usr/bin', '/bin']) { }

define archive::extract (
  $target,
  $ensure           = present,
  $src_target       = '/usr/src',
  $root_dir         = '',
  $extension        = 'tar.gz',
  $timeout          = 120,
  $strip_components = 0,
  $exec_path        = ['/usr/local/bin', '/usr/bin', '/bin']) { }

class archive::prerequisites { }
