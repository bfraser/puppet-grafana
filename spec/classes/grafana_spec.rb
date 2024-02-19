# frozen_string_literal: true

require 'spec_helper'

describe 'grafana' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('grafana') }
        it { is_expected.to contain_class('grafana::install').that_comes_before('Class[grafana::config]') }
        it { is_expected.to contain_class('grafana::config').that_notifies('Class[grafana::service]') }
        it { is_expected.to contain_class('grafana::service') }
      end

      context 'with parameter install_method is set to package' do
        let(:params) do
          {
            install_method: 'package',
            version: '5.4.2'
          }
        end

        case facts[:osfamily]
        when 'Debian'
          download_location = '/tmp/grafana.deb'

          describe 'use archive to fetch the package to a temporary location' do
            it do
              expect(subject).to contain_archive('/tmp/grafana.deb').with_source(
                'https://dl.grafana.com/oss/release/grafana_5.4.2_amd64.deb'
              )
            end

            it { is_expected.to contain_archive('/tmp/grafana.deb').that_comes_before('Package[grafana]') }
          end

          describe 'install dependencies first' do
            it { is_expected.to contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_provider('dpkg') }
            it { is_expected.to contain_package('grafana').with_source(download_location) }
          end
        when 'RedHat'
          describe 'install dependencies first' do
            it { is_expected.to contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_provider('rpm') }
          end
        end
      end

      context 'with some plugins passed in' do
        let(:params) do
          {
            plugins:
            {
              'grafana-wizzle' => { 'ensure' => 'present' },
              'grafana-woozle' => { 'ensure' => 'absent' },
              'grafana-plugin' => { 'ensure' => 'present', 'repo' => 'https://nexus.company.com/grafana/plugins' },
              'grafana-plugin-url' => { 'ensure' => 'present', 'plugin_url' => 'https://grafana.com/api/plugins/grafana-simple-json-datasource/versions/latest/download' }
            }
          }
        end

        it { is_expected.to contain_grafana_plugin('grafana-wizzle').with(ensure: 'present') }
        it { is_expected.to contain_grafana_plugin('grafana-woozle').with(ensure: 'absent').that_notifies('Class[grafana::service]') }

        describe 'install plugin with plugin repo' do
          it { is_expected.to contain_grafana_plugin('grafana-plugin').with(ensure: 'present', repo: 'https://nexus.company.com/grafana/plugins') }
        end

        describe 'install plugin with plugin url' do
          it { is_expected.to contain_grafana_plugin('grafana-plugin-url').with(ensure: 'present', plugin_url: 'https://grafana.com/api/plugins/grafana-simple-json-datasource/versions/latest/download') }
        end
      end

      context 'with parameter install_method is set to repo' do
        let(:params) do
          {
            install_method: 'repo'
          }
        end

        case facts[:osfamily]
        when 'Debian'
          describe 'install apt repo dependencies first' do
            it { is_expected.to contain_class('apt') }
            it { is_expected.to contain_apt__source('grafana').with(release: 'stable', repos: 'main', location: 'https://apt.grafana.com') }
            it { is_expected.to contain_apt__source('grafana').that_comes_before('Package[grafana]') }
          end

          describe 'install dependencies first' do
            it { is_expected.to contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('installed') }
          end
        when 'RedHat'
          describe 'yum repo dependencies first' do
            it { is_expected.to contain_yumrepo('grafana-stable').with(baseurl: 'https://rpm.grafana.com', gpgkey: 'https://packages.grafana.com/gpg.key', enabled: 1) }
            it { is_expected.to contain_yumrepo('grafana-stable').that_comes_before('Package[grafana]') }
          end

          describe 'install dependencies first' do
            it { is_expected.to contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('installed') }
          end
        end
      end

      context 'with parameter install_method is set to repo and manage_package_repo is set to false' do
        let(:params) do
          {
            install_method: 'repo',
            manage_package_repo: false,
            version: 'present'
          }
        end

        case facts[:osfamily]
        when 'Debian'
          describe 'install dependencies first' do
            it { is_expected.to contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('present') }
          end
        when 'RedHat'
          describe 'install dependencies first' do
            it { is_expected.to contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('present') }
          end
        when 'Archlinux'
          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('present') }
          end
        end
      end

      context 'with parameter install_method is set to archive' do
        let(:params) do
          {
            install_method: 'archive',
            version: '5.4.2'
          }
        end

        install_dir    = '/usr/share/grafana'
        service_config = '/usr/share/grafana/conf/custom.ini'
        archive_source = 'https://dl.grafana.com/oss/release/grafana-5.4.2.linux-amd64.tar.gz'

        describe 'extract archive to install_dir' do
          it { is_expected.to contain_archive('/tmp/grafana.tar.gz').with_ensure('present') }
          it { is_expected.to contain_archive('/tmp/grafana.tar.gz').with_source(archive_source) }
          it { is_expected.to contain_archive('/tmp/grafana.tar.gz').with_extract_path(install_dir) }
        end

        describe 'create grafana user' do
          it { is_expected.to contain_user('grafana').with_ensure('present').with_home(install_dir) }
          it { is_expected.to contain_user('grafana').that_comes_before('File[/usr/share/grafana]') }
        end

        case facts[:osfamily]
        when 'Archlinux', 'Debian', 'RedHat'
          describe 'create data_dir' do
            it { is_expected.to contain_file('/var/lib/grafana').with_ensure('directory') }
          end
        when 'FreeBSD'
          describe 'create data_dir' do
            it { is_expected.to contain_file('/var/db/grafana').with_ensure('directory') }
          end
        end

        describe 'manage install_dir' do
          it { is_expected.to contain_file(install_dir).with_ensure('directory') }
          it { is_expected.to contain_file(install_dir).with_group('grafana').with_owner('grafana') }
        end

        describe 'configure grafana' do
          it { is_expected.to contain_file(service_config).with_ensure('file') }
        end

        describe 'run grafana as service' do
          it { is_expected.to contain_service('grafana').with_ensure('running').with_provider('base') }
          it { is_expected.to contain_service('grafana').with_hasrestart(false).with_hasstatus(false) }
        end

        context 'when user already defined' do
          let(:pre_condition) do
            'user{"grafana":
              ensure => present,
            }'
          end

          describe 'do NOT create grafana user' do
            it { is_expected.not_to contain_user('grafana').with_ensure('present').with_home(install_dir) }
          end
        end

        context 'when service already defined' do
          let(:pre_condition) do
            'service{"grafana":
              ensure     => running,
              name       => "grafana-server",
              hasrestart => true,
              hasstatus  => true,
            }'
          end

          describe 'do NOT run service' do
            it { is_expected.not_to contain_service('grafana').with_hasrestart(false).with_hasstatus(false) }
          end
        end
      end

      context 'invalid parameters' do
        context 'cfg' do
          describe 'should not raise an error when cfg parameter is a hash' do
            let(:params) do
              {
                cfg: {}
              }
            end

            it { is_expected.to contain_package('grafana') }
          end
        end
      end

      context 'configuration file' do
        describe 'should not contain any configuration when cfg param is empty' do
          it { is_expected.to contain_file('grafana.ini').with_content("# This file is managed by Puppet, any changes will be overwritten\n\n") }
        end

        describe 'should correctly transform cfg param entries to Grafana configuration' do
          let(:params) do
            {
              cfg: {
                'app_mode' => 'production',
                'section' => {
                  'string' => 'production',
                  'number' => 8080,
                  'boolean' => false,
                  'empty' => ''
                }
              },
              ldap_cfg: {
                'servers' => [
                  { 'host' => 'server1',
                    'use_ssl' => true,
                    'search_filter' => '(sAMAccountName=%s)',
                    'search_base_dns' => ['dc=domain1,dc=com'] }
                ],
                'servers.attributes' => {
                  'name' => 'givenName',
                  'surname' => 'sn',
                  'username' => 'sAMAccountName',
                  'member_of' => 'memberOf',
                  'email' => 'mail'
                }
              }
            }
          end

          expected = "# This file is managed by Puppet, any changes will be overwritten\n\n" \
                     "app_mode = production\n\n" \
                     "[section]\n" \
                     "boolean = false\n" \
                     "empty = \n" \
                     "number = 8080\n" \
                     "string = production\n"

          it { is_expected.to contain_file('grafana.ini').with_content(expected) }

          ldap_expected = "\n[[servers]]\n" \
                          "host = \"server1\"\n" \
                          "search_base_dns = [\"dc=domain1,dc=com\"]\n" \
                          "search_filter = \"(sAMAccountName=%s)\"\n" \
                          "use_ssl = true\n" \
                          "\n" \
                          "[servers.attributes]\n" \
                          "email = \"mail\"\n" \
                          "member_of = \"memberOf\"\n" \
                          "name = \"givenName\"\n" \
                          "surname = \"sn\"\n" \
                          "username = \"sAMAccountName\"\n" \
                          "\n"

          it { is_expected.to contain_file('/etc/grafana/ldap.toml').with_content(ldap_expected) }
        end

        context 'with Sensitive `cfg`' do
          let(:params) do
            {
              cfg: sensitive(
                {
                  'database' => {
                    'type' => 'postgres',
                    'host' => 'db.example.com:5432',
                    'name' => 'grafana',
                    'user' => 'grafana',
                    'password' => 'hunter2',
                  },
                }
              )
            }
          end

          let(:expected) do
            <<~CONTENT
              # This file is managed by Puppet, any changes will be overwritten


              [database]
              host = db.example.com:5432
              name = grafana
              password = hunter2
              type = postgres
              user = grafana
            CONTENT
          end

          it { is_expected.to contain_file('grafana.ini').with_content(sensitive(expected)) }
        end
      end

      context 'multiple ldap configuration' do
        describe 'should correctly transform ldap config param into Grafana ldap.toml' do
          let(:params) do
            {
              cfg: {},
              ldap_cfg: [
                {
                  'servers' => [
                    { 'host' => 'server1a server1b',
                      'use_ssl' => true,
                      'search_filter' => '(sAMAccountName=%s)',
                      'search_base_dns' => ['dc=domain1,dc=com'] }
                  ],
                  'servers.attributes' => {
                    'name' => 'givenName',
                    'surname' => 'sn',
                    'username' => 'sAMAccountName',
                    'member_of' => 'memberOf',
                    'email' => 'mail'
                  }
                },
                {
                  'servers' => [
                    { 'host' => 'server2a server2b',
                      'use_ssl' => true,
                      'search_filter' => '(sAMAccountName=%s)',
                      'search_base_dns' => ['dc=domain2,dc=com'] }
                  ],
                  'servers.attributes' => {
                    'name' => 'givenName',
                    'surname' => 'sn',
                    'username' => 'sAMAccountName',
                    'member_of' => 'memberOf',
                    'email' => 'mail'
                  }
                }
              ]
            }
          end

          ldap_expected = "\n[[servers]]\n" \
                          "host = \"server1a server1b\"\n" \
                          "search_base_dns = [\"dc=domain1,dc=com\"]\n" \
                          "search_filter = \"(sAMAccountName=%s)\"\n" \
                          "use_ssl = true\n" \
                          "\n" \
                          "[servers.attributes]\n" \
                          "email = \"mail\"\n" \
                          "member_of = \"memberOf\"\n" \
                          "name = \"givenName\"\n" \
                          "surname = \"sn\"\n" \
                          "username = \"sAMAccountName\"\n" \
                          "\n" \
                          "\n[[servers]]\n" \
                          "host = \"server2a server2b\"\n" \
                          "search_base_dns = [\"dc=domain2,dc=com\"]\n" \
                          "search_filter = \"(sAMAccountName=%s)\"\n" \
                          "use_ssl = true\n" \
                          "\n" \
                          "[servers.attributes]\n" \
                          "email = \"mail\"\n" \
                          "member_of = \"memberOf\"\n" \
                          "name = \"givenName\"\n" \
                          "surname = \"sn\"\n" \
                          "username = \"sAMAccountName\"\n" \
                          "\n"

          it { is_expected.to contain_file('/etc/grafana/ldap.toml').with_content(ldap_expected) }
        end
      end

      context 'with Sensitive `ldap_cfg`' do
        let(:ldap_cfg) do
          {
            'servers' => [
              { 'host' => 'server1a server1b',
                'use_ssl' => true,
                'search_filter' => '(sAMAccountName=%s)',
                'search_base_dns' => ['dc=domain1,dc=com'] }
            ],
            'servers.attributes' => {
              'name' => 'givenName',
              'surname' => 'sn',
              'username' => 'sAMAccountName',
              'member_of' => 'memberOf',
              'email' => 'mail'
            }
          }
        end

        let(:expected) do
          <<~CONTENT

            [[servers]]
            host = "server1a server1b"
            search_base_dns = ["dc=domain1,dc=com"]
            search_filter = "(sAMAccountName=%s)"
            use_ssl = true

            [servers.attributes]
            email = "mail"
            member_of = "memberOf"
            name = "givenName"
            surname = "sn"
            username = "sAMAccountName"

          CONTENT
        end

        context 'Sensitive[Hash]' do
          let(:params) do
            {
              ldap_cfg: sensitive(ldap_cfg)
            }
          end

          it { is_expected.to contain_file('/etc/grafana/ldap.toml').with_content(sensitive(expected)) }
        end

        context 'Sensitive[Array[Hash]]' do
          let(:params) do
            {
              ldap_cfg: sensitive([ldap_cfg])
            }
          end

          it { is_expected.to contain_file('/etc/grafana/ldap.toml').with_content(sensitive(expected)) }
        end
      end

      context 'provisioning_dashboards defined' do
        let(:params) do
          {
            version: '6.0.0',
            provisioning_dashboards: {
              apiVersion: 1,
              providers: [
                {
                  name: 'default',
                  orgId: 1,
                  folder: '',
                  type: 'file',
                  disableDeletion: true,
                  options: {
                    path: '/var/lib/grafana/dashboards',
                    puppetsource: 'puppet:///modules/my_custom_module/dashboards'
                  }
                }
              ]
            }
          }
        end

        it do
          expect(subject).to contain_file('/var/lib/grafana/dashboards').with(
            ensure: 'directory',
            owner: 'grafana',
            group: 'grafana',
            mode: '0750',
            recurse: true,
            purge: true,
            source: 'puppet:///modules/my_custom_module/dashboards'
          )
        end

        context 'without puppetsource defined' do
          let(:params) do
            {
              version: '6.0.0',
              provisioning_dashboards: {
                apiVersion: 1,
                providers: [
                  {
                    name: 'default',
                    orgId: 1,
                    folder: '',
                    type: 'file',
                    disableDeletion: true,
                    options: {
                      path: '/var/lib/grafana/dashboards'
                    }
                  }
                ]
              }
            }
          end

          it { is_expected.not_to contain_file('/var/lib/grafana/dashboards') }
        end
      end

      context 'sysconfig environment variables' do
        let(:params) do
          {
            install_method: 'repo',
            sysconfig: { http_proxy: 'http://proxy.example.com/' }
          }
        end

        case facts[:osfamily]
        when 'Debian'
          describe 'Add the environment variable to the config file' do
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_context('/files/etc/default/grafana-server') }
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_changes(['set http_proxy http://proxy.example.com/']) }
          end
        when 'RedHat'
          describe 'Add the environment variable to the config file' do
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_context('/files/etc/sysconfig/grafana-server') }
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_changes(['set http_proxy http://proxy.example.com/']) }
          end
        end
      end
    end
  end
end
