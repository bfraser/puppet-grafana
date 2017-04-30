# defined resource to add plugins to grafana via CLI
# this won't work with the docker installation method
define grafana::plugin(
  String $plugin = $title,
){
  exec{"install ${plugin}":
    command => "/usr/bin/grafana-cli plugins install ${plugin}",
    creates => "/var/lib/grafana/plugins/${plugin}",
  }
}
