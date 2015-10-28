# == Class grafana::apache
#
# This class is called from grafana
#
class grafana::apache (
  $server_addr      = $grafana::cfg[server][http_addr],
  $server_port      = $grafana::cfg[server][http_port],
  $vhost_servername = $::fqdn,
  $vhost_port       = 80,
) {
  include ::apache

  apache::vhost { 'grafana_proxy':
    servername          => $vhost_servername,
    port                => $vhost_port,
    docroot             => '/var/www/',
    proxy_preserve_host => true,
    proxy_pass          => {
      'path' => '/grafana',
      'url'  => "http://${server_addr}:${server_port}",
    }
  }
}
