require 'spec_helper_acceptance'

describe 'grafana class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'grafana': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('grafana') do
      it { is_expected.to be_installed }
    end

    describe service('grafana-server') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'with fancy dashboard config' do
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'grafana':
        provisioning_datasources => {
          apiVersion  => 1,
          datasources => [
            {
            name      => 'Prometheus',
            type      => 'prometheus',
            access    => 'proxy',
            url       => 'http://localhost:9090/prometheus',
            isDefault => true,
            },
          ],
        },
        provisioning_dashboards => {
          apiVersion => 1,
          providers  => [
            {
              name            => 'default',
              orgId           => 1,
              fiolder         => '',
              type            => 'file',
              disableDeletion => true,
              options         => {
                path          => '/var/lib/grafana/dashboards',
                puppetsource  => 'puppet:///modules/my_custom_module/dashboards',
              },
            },
          ],
        }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'with fancy dashboard config and custom target file' do
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'grafana':
        provisioning_datasources      => {
          apiVersion  => 1,
          datasources => [
            {
            name      => 'Prometheus',
            type      => 'prometheus',
            access    => 'proxy',
            url       => 'http://localhost:9090/prometheus',
            isDefault => true,
            },
          ],
        },
        provisioning_dashboards       => {
          apiVersion => 1,
          providers  => [
            {
              name            => 'default',
              orgId           => 1,
              fiolder         => '',
              type            => 'file',
              disableDeletion => true,
              options         => {
                path          => '/var/lib/grafana/dashboards',
                puppetsource  => 'puppet:///modules/my_custom_module/dashboards',
              },
            },
          ],
        },
        provisioning_dashboards_file  => '/opt/grafana/conf/provisioning/dashboards/dashboard.yaml',
        provisioning_datasources_file => '/opt/grafana/conf/provisioning/datasources/datasources.yaml'
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
