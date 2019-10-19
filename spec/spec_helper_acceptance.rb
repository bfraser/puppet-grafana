require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    install_module
    install_module_dependencies

    hosts.each do |host|
      if fact_on(host, 'osfamily') == 'Debian'
        # Install additional modules for soft deps
        install_module_from_forge('puppetlabs-apt', '>= 4.1.0 < 8.0.0')
      end
    end
  end
end
