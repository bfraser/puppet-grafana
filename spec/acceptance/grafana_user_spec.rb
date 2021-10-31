# frozen_string_literal: true

require 'spec_helper_acceptance'

supported_versions.each do |grafana_version|
  describe "grafana_user with Grafana version #{grafana_version}" do
    prepare_host
    context 'setup grafana server' do
      it 'runs successfully' do
        pp = <<-EOS
        class { 'grafana':
          version => "#{grafana_version}",
          cfg => {
            security => {
              admin_user     => 'admin',
              admin_password => 'admin'
            }
          }
        }
        EOS
        prepare_host

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
    end

    it 'runs successfully' do
      pp = <<-EOS
      grafana_user { 'user1':
        grafana_url       => 'http://localhost:3000',
        grafana_user      => 'admin',
        grafana_password  => 'admin',
        full_name         => 'John Doe',
        password          => 'Us3r5ecret',
        email             => 'john@example.com',
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
