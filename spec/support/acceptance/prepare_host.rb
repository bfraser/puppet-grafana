def prepare_host
  cleanup_script = <<-SHELL
  /opt/puppetlabs/bin/puppet resource package grafana ensure=purged
  rm -rf /var/lib/grafana/
  SHELL

  shell(cleanup_script)
end
