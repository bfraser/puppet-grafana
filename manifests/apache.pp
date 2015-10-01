# == Class grafana::apache
#
# This class is called from grafana
#
class grafana::apache (
  $server_addr = $grafana::cfg[server][http_addr],
  $server_port = $grafana::cfg[server][http_port]
) {
  include ::apache

  apache::vhost { 'grafana_proxy':
    servername          => $::fqdn,
    port                => 80,
    docroot             => '/var/www/',
    proxy_preserve_host => true,
    proxy_pass          => {
      'path' => '/grafana',
      'url'  => "http://${server_addr}:${server_port}",
    }
  }
}
