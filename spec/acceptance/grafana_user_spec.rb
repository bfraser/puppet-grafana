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

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        grafana_user { 'user1':
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
          full_name        => 'John Doe',
          password         => 'Us3r5ecret',
          email            => 'john@example.com',
        }
        PUPPET
      end
    end

    describe 'managing 100 users' do
      it_behaves_like 'an idempotent resource' do
        let(:manifest) do
          <<-PUPPET
          grafana_user { range('testuser00', 'testuser99'):
            ensure           => present,
            grafana_url      => 'http://localhost:3000',
            grafana_user     => 'admin',
            grafana_password => 'admin',
          }
          PUPPET
        end
      end
      it_behaves_like 'an idempotent resource' do
        let(:manifest) do
          <<-PUPPET
          grafana_user { range('testuser00', 'testuser99'):
            ensure           => absent,
            grafana_url      => 'http://localhost:3000',
            grafana_user     => 'admin',
            grafana_password => 'admin',
          }
          PUPPET
        end
      end
    end

    describe 'advanced use' do
      describe 'creating an admin' do
        it_behaves_like 'an idempotent resource' do
          let(:manifest) do
            <<-PUPPET
            grafana_user { 'admin1':
              grafana_url      => 'http://localhost:3000',
              grafana_user     => 'admin',
              grafana_password => 'admin',
              full_name        => 'Admin User',
              password         => 'Admin5ecret',
              email            => 'admin@example.com',
              is_admin         => true,
            }
            PUPPET
          end
        end
      end

      describe 'updating a user password with new admin user' do
        it_behaves_like 'an idempotent resource' do
          let(:manifest) do
            <<-PUPPET
            grafana_user { 'user1':
              grafana_url      => 'http://localhost:3000',
              grafana_user     => 'admin1',
              grafana_password => 'Admin5ecret',
              password         => 'newpassword',
            }
            PUPPET
          end
        end
      end

      describe 'Turning a user into an admin' do
        it_behaves_like 'an idempotent resource' do
          let(:manifest) do
            <<-PUPPET
            grafana_user { 'user1':
              grafana_url      => 'http://localhost:3000',
              grafana_user     => 'admin1',
              grafana_password => 'Admin5ecret',
              is_admin         => true,
            }
            PUPPET
          end
        end
      end

      describe 'updating full_name' do
        it_behaves_like 'an idempotent resource' do
          let(:manifest) do
            <<-PUPPET
            grafana_user { 'user1':
              grafana_url      => 'http://localhost:3000',
              grafana_user     => 'admin1',
              grafana_password => 'Admin5ecret',
              full_name        => 'My new Admin user',
            }
            PUPPET
          end
        end
      end

      describe 'deleting a user' do
        it_behaves_like 'an idempotent resource' do
          let(:manifest) do
            <<-PUPPET
            grafana_user { 'admin1':
              ensure           => absent,
              grafana_url      => 'http://localhost:3000',
              grafana_user     => 'user1',
              grafana_password => 'newpassword',
            }
            PUPPET
          end
        end
      end
    end
  end
end
