# frozen_string_literal: true

require 'spec_helper_acceptance'

supported_versions.each do |grafana_version|
  describe "grafana_team wth Grafana version #{grafana_version}" do
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

    context 'create team resource on `Main Org.`' do
      it 'creates the team' do
        pp = <<-EOS
        include grafana::validator
        grafana_team { 'example-team':
          ensure           => present,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        EOS
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'has created the example team' do
        shell('curl --user admin:admin http://localhost:3000/api/teams/search?name=example-team') do |f|
          expect(f.stdout).to match(%r{example-team})
        end
      end

      it 'has set default home dashboard' do
        shell('curl --user admin:admin http://localhost:3000/api/teams/1/preferences') do |f|
          data = JSON.parse(f.stdout)
          expect(data).to include('homeDashboardId' => 0)
        end
      end
    end

    context 'updates team resource' do
      it 'creates dashboard and sets team home dashboard' do
        pp = <<-EOS
        include grafana::validator
        grafana_dashboard { 'example-dashboard':
          ensure           => present,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
          content          => '{"description": "example dashboard"}',
        }
        grafana_folder { 'example-folder':
          ensure           => present,
          uid              => 'example-folder',
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        -> grafana_dashboard { 'example-dashboard2':
          ensure           => present,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
          content          => '{"description": "example dashboard2"}',
          folder           => 'example-folder',
        }
        grafana_team { 'example-team':
          ensure           => present,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
          home_dashboard   => 'example-dashboard',
        }
        grafana_team { 'example-team2':
          ensure                => present,
          grafana_url           => 'http://localhost:3000',
          grafana_user          => 'admin',
          grafana_password      => 'admin',
          home_dashboard_folder => 'example-folder',
          home_dashboard        => 'example-dashboard2',
        }
        EOS
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'has updated the example team home dashboard' do
        shell('curl --user admin:admin http://localhost:3000/api/teams/1/preferences') do |f|
          data = JSON.parse(f.stdout)
          expect(data['homeDashboardId']).not_to eq(0)
        end
      end

      it 'has updated the example team home dashboard with folder' do
        shell('curl --user admin:admin http://localhost:3000/api/teams/2/preferences') do |f|
          data = JSON.parse(f.stdout)
          expect(data['homeDashboardId']).not_to eq(0)
        end
      end
    end

    context 'create team resource on seperate organization' do
      it 'creates organization and team' do
        pp = <<-EOS
        include grafana::validator
        grafana_organization { 'example-organization':
          ensure           => present,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        grafana_team { 'example-team-on-org':
          ensure           => present,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
          organization     => 'example-organization',
        }
        EOS
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'creates team on organization' do
        shell('curl --user admin:admin -X POST http://localhost:3000/api/user/using/2 && '\
              'curl --user admin:admin http://localhost:3000/api/teams/search?name=example-team-on-org') do |f|
          expect(f.stdout).to match(%r{example-team-on-org})
        end
      end
    end

    context 'destroy resources' do
      it 'destroys the teams, dashboard, and organization' do
        pp = <<-EOS
        include grafana::validator
        grafana_team { 'example-team':
          ensure           => absent,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        grafana_team { 'example-team2':
          ensure           => absent,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        grafana_team { 'example-team-on-org':
          ensure           => absent,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
          organization     => 'example-organization',
        }
        grafana_dashboard { 'example-dashboard':
          ensure           => absent,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        grafana_dashboard { 'example-dashboard2':
          ensure           => absent,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        grafana_folder { 'example-folder':
          ensure           => absent,
          uid              => 'example-folder',
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        grafana_organization { 'example-organization':
          ensure           => absent,
          grafana_url      => 'http://localhost:3000',
          grafana_user     => 'admin',
          grafana_password => 'admin',
        }
        EOS
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'has no example-team' do
        shell('curl --user admin:admin -X POST http://localhost:3000/api/user/using/1 && '\
              'curl --user admin:admin http://localhost:3000/api/teams/search') do |f|
          expect(f.stdout).not_to match(%r{example-team})
        end
      end

      it 'has no example-team-on-org' do
        shell('curl --user admin:admin -X POST http://localhost:3000/api/user/using/2 && '\
              'curl --user admin:admin http://localhost:3000/api/teams') do |f|
          expect(f.stdout).not_to match(%r{example-team-on-org})
        end
      end
    end
  end
end
