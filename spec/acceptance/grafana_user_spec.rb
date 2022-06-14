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

      describe 'organizations' do
        describe 'Adding a new user to a new organization' do
          it_behaves_like 'an idempotent resource' do
            let(:manifest) do
              <<-PUPPET
              grafana_user { 'orguser1':
                ensure           => present,
                grafana_url      => 'http://localhost:3000',
                grafana_user     => 'admin',
                grafana_password => 'admin',
                organizations    => {
                  'testorg1' => 'admin',
                },
              }

              grafana_organization { ['testorg1','testorg2','testorg3']:
                ensure           => present,
                grafana_url      => 'http://localhost:3000',
                grafana_user     => 'admin',
                grafana_password => 'admin',
              }
              PUPPET
            end
          end
        end

        describe 'Adding a user to existing organizations' do
          it_behaves_like 'an idempotent resource' do
            let(:manifest) do
              <<-PUPPET
              grafana_user { 'orguser1':
                ensure           => present,
                grafana_url      => 'http://localhost:3000',
                grafana_user     => 'admin',
                grafana_password => 'admin',
                organizations    => {
                  'testorg1' => 'admin',
                  'testorg2' => 'viewer',
                  'testorg3' => 'Editor',
                },
              }
              PUPPET
            end
          end
        end

        describe 'Updating a users organizations' do
          it_behaves_like 'an idempotent resource' do
            let(:manifest) do
              <<-PUPPET
              grafana_user { 'orguser1':
                ensure           => present,
                grafana_url      => 'http://localhost:3000',
                grafana_user     => 'admin',
                grafana_password => 'admin',
                organizations    => {
                  'testorg1' => 'viewer',
                  'testorg2' => 'editor',
                  'testorg3' => 'admin',
                },
              }
              PUPPET
            end
          end
        end

        describe 'Removing a user from an organization' do
          it_behaves_like 'an idempotent resource' do
            let(:manifest) do
              <<-PUPPET
              grafana_user { 'orguser1':
                ensure           => present,
                grafana_url      => 'http://localhost:3000',
                grafana_user     => 'admin',
                grafana_password => 'admin',
                organizations    => {
                  'testorg1' => 'viewer',
                  'testorg2' => 'editor',
                },
              }
              PUPPET
            end
          end
        end

        describe 'Cleaning up' do
          it_behaves_like 'an idempotent resource' do
            let(:manifest) do
              <<-PUPPET
              grafana_user { 'orguser1':
                ensure           => absent,
                grafana_url      => 'http://localhost:3000',
                grafana_user     => 'admin',
                grafana_password => 'admin',
              }
              grafana_organization {['testorg1','testorg2','testorg3']:
                ensure           => absent,
                grafana_url      => 'http://localhost:3000',
                grafana_user     => 'admin',
                grafana_password => 'admin',
                require          => Grafana_user['orguser1'],
              }
              PUPPET
            end
          end
        end
      end
    end
  end
end
