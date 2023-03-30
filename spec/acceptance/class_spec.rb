# frozen_string_literal: true

require 'spec_helper_acceptance'

supported_versions.each do |grafana_version|
  describe "grafana class with Grafana version #{grafana_version}" do
    # Create dummy module directorty
    shell('mkdir -p /etc/puppetlabs/code/environments/production/modules/my_custom_module/files/dashboards')
    context 'default parameters' do
      before do
        install_module_from_forge('puppetlabs/apt', '>= 7.5.0 < 9.0.0')
      end
      # Using puppet_apply as a helper

      it 'works idempotently with no errors' do
        pp = <<-EOS
        class { 'grafana':
          version => "#{grafana_version}"
        }
        EOS

        prepare_host

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
          version => "#{grafana_version}",
          provisioning_datasources => {
            apiVersion  => 1,
            datasources => [
              {
              name      => 'Prometheus',
              type      => 'prometheus',
              access    => 'proxy',
              url       => 'http://localhost:9090/prometheus',
              isDefault => false,
              },
            ],
          },
          provisioning_dashboards => {
            apiVersion => 1,
            providers  => [
              {
                name            => 'default',
                orgId           => 1,
                folder         => '',
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
          version => "#{grafana_version}",
          provisioning_datasources      => {
            apiVersion  => 1,
            datasources => [
              {
              name      => 'Prometheus',
              type      => 'prometheus',
              access    => 'proxy',
              url       => 'http://localhost:9090/prometheus',
              isDefault => false,
              },
            ],
          },
          provisioning_dashboards       => {
            apiVersion => 1,
            providers  => [
              {
                name            => 'default',
                orgId           => 1,
                folder         => '',
                type            => 'file',
                disableDeletion => true,
                options         => {
                  path          => '/var/lib/grafana/dashboards',
                  puppetsource  => 'puppet:///modules/my_custom_module/dashboards',
                },
              },
            ],
          },
          provisioning_dashboards_file  => '/etc/grafana/provisioning/dashboards/dashboard.yaml',
          provisioning_datasources_file => '/etc/grafana/provisioning/datasources/datasources.yaml'
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
    end
  end
end

describe 'grafana class with latest grafana version' do
  context 'update to beta release', unless: fact('os.family') == 'Debian' do
    it 'works idempotently with no errors' do
      case fact('os.family')
      when 'Debian'
        # As of 2023-03-22, Debian beta packages are non functinal and disabled
        pp = <<-EOS
        class { 'grafana':
          version   => 'latest',
          repo_name => 'beta',
        }
        EOS
      when 'RedHat'
        pp = <<-EOS
        class { 'grafana':
          version       => 'latest',
          repo_name     => 'beta',
        }
        EOS
      end

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('grafana') do
      it { is_expected.to be_installed }
    end
  end

  context 'revert back to stable' do
    it 'works idempotently with no errors' do
      case fact('os.family')
      when 'Debian'
        pp = <<-EOS
        class { 'grafana':
          version => 'latest',
        }
        EOS
        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      when 'RedHat'
        shell('/bin/rm /etc/yum.repos.d/grafana-beta.repo')
        shell('yum -y downgrade grafana')
        # No manifest to apply here
      end
    end

    describe package('grafana') do
      it { is_expected.to be_installed }
    end
  end
end
