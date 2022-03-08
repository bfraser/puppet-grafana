# Needed for os.distro.codebase fact on Ubuntu 18 with Facter 3
if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['full'] == '18.04' and versioncmp($facts['facterversion'], '4') <= 0 {
  package { 'lsb-release':
    ensure => present,
  }
}
