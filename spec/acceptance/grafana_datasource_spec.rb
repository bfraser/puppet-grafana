# frozen_string_literal: true

require 'spec_helper_acceptance'

supported_versions.each do |grafana_version|
  describe "grafana_datasource with Grafana version #{grafana_version}" do
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

    describe 'prometheus ds' do
      context 'without basic auth' do
        it_behaves_like 'an idempotent resource' do
          let(:manifest) do
            <<-PUPPET
            grafana_datasource { 'prometheus prom1.example.com':
              grafana_url      => 'http://localhost:3000',
              grafana_user     => 'admin',
              grafana_password => 'admin',
              type             => 'prometheus',
              url              => 'https://prom1.example.com',
              access_mode      => 'proxy',
              json_data        => {
                'httpMethod'   => 'POST',
                'timeInterval' => '10s',
              },
            }
            PUPPET
          end
        end
      end

      if Gem::Version.new(grafana_version) > Gem::Version.new('9')
        context 'with basic auth in secure json data' do
          let(:manifest) do
            <<-PUPPET
              grafana_datasource { 'prometheus2':
                grafana_url          => 'http://localhost:3000',
                grafana_user         => 'admin',
                grafana_password     => 'admin',
                type                 => 'prometheus',
                url                  => 'https://prom2.example.com',
                access_mode          => 'proxy',
                json_data            => {
                  'httpMethod'       => 'POST',
                  'timeInterval'     => '10s',
                },
                secure_json_data     => {
                  'basicAuthPassword' => 'prom_password',
                },
                basic_auth_user      => 'prom_user',
              }
            PUPPET
          end

          it 'works with no errors' do
            apply_manifest_on(default, manifest, catch_failures: true)
          end

          it 'is idempotent' do
            pending('secure_json_data is not returned by API')
            apply_manifest_on(default, manifest, catch_changes: true)
          end
        end
      else
        context 'with basic auth in legacy field' do
          it_behaves_like 'an idempotent resource' do
            let(:manifest) do
              <<-PUPPET
              grafana_datasource { 'prometheus2':
                grafana_url          => 'http://localhost:3000',
                grafana_user         => 'admin',
                grafana_password     => 'admin',
                type                 => 'prometheus',
                url                  => 'https://prom2.example.com',
                access_mode          => 'proxy',
                json_data            => {
                  'httpMethod'       => 'POST',
                  'timeInterval'     => '10s',
                },
                basic_auth_user      => 'prom_user',
                basic_auth_password  => 'prom_password',
              }
              PUPPET
            end
          end
        end
      end
    end

    describe 'influxdb ds' do
      if Gem::Version.new(grafana_version) > Gem::Version.new('9')
        context 'with password in secure_json_data' do
          let(:manifest) do
            <<-PUPPET
              grafana_datasource { 'influxdb':
                grafana_url      => 'http://localhost:3000',
                grafana_user     => 'admin',
                grafana_password => 'admin',
                type             => 'influxdb',
                url              => 'http://localhost:8086',
                access_mode      => 'proxy',
                user             => 'admin',
                secure_json_data => {
                  'password' => '1nFlux5ecret',
                },
                database         => 'mydb',
              }
            PUPPET
          end

          it 'works with no errors' do
            apply_manifest_on(default, manifest, catch_failures: true)
          end

          it 'is idempotent' do
            pending('secure_json_data is not returned by API')
            apply_manifest_on(default, manifest, catch_changes: true)
          end
        end
      else
        context 'with password in legacy field' do
          it_behaves_like 'an idempotent resource' do
            let(:manifest) do
              <<-PUPPET
              grafana_datasource { 'influxdb':
                grafana_url      => 'http://localhost:3000',
                grafana_user     => 'admin',
                grafana_password => 'admin',
                type             => 'influxdb',
                url              => 'http://localhost:8086',
                access_mode      => 'proxy',
                user             => 'admin',
                password         => '1nFlux5ecret',
                database         => 'mydb',
              }
              PUPPET
            end
          end
        end
      end
    end
  end
end
