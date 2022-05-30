# frozen_string_literal: true

require 'spec_helper_acceptance'

supported_versions.each do |grafana_version|
  describe "grafana_organization with Grafana version #{grafana_version}" do
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

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        grafana_organization { 'org1':
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        PUPPET
      end
    end

    describe 'Organizations with specials characters in name' do
      it_behaves_like 'an idempotent resource' do
        let(:manifest) do
          <<-PUPPET
          grafana_organization { 'Example Org!':
            grafana_url      => 'http://localhost:3000',
            grafana_user     => 'admin',
            grafana_password => 'admin',
          }
          PUPPET
        end
      end
    end

    describe 'Deleting organizations' do
      it_behaves_like 'an idempotent resource' do
        let(:manifest) do
          <<-PUPPET
          grafana_organization { ['org1','Example Org!']:
            ensure           => absent,
            grafana_url      => 'http://localhost:3000',
            grafana_user     => 'admin',
            grafana_password => 'admin',
          }
          PUPPET
        end
      end
    end
  end
end
