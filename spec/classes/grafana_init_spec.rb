require 'spec_helper'

#Puppet::Util::Log.level = :debug
#Puppet::Util::Log.newdestination(:console)

describe 'grafana', :type => 'class' do

  context 'valid datasources' do

    datasources = {
      'graphite' => {
        'type'    => 'graphite',
        'url'     => 'http://localhost:80',
        'default' => 'true'
      },
      'elasticsearch' => {
        'type'      => 'elasticsearch',
        'url'       => 'http://localhost:9200',
        'index'     => 'grafana-dash',
        'grafanaDB' => 'true',
      },
    }

      context 'make sure it compiles' do
        let (:params) {{ :datasources => datasources }}
        it { should compile }
      end

      context 'installs via package' do
        let :params do
          {
            :install_method => 'package',
            :install_dir    => '/usr/share/grafana',
            :datasources    => datasources
          }
        end

        it { should contain_package('grafana').with(:ensure	=> '1.9.0') }
        it { should contain_file('/usr/share/grafana/config.js').with_ensure('present') }
      end

      context 'installs via archive and no symlink' do
        let :params do
          {
            :install_method	=> 'archive',
            :symlink        => false,
            :datasources    => datasources
          }
        end

        it { should contain_archive('grafana-1.9.0')}
        it { should contain_file('/opt/grafana-1.9.0/config.js').with_ensure('present') }
        it { should_not contain_file('/opt/grafana').with_ensure('link').with_target('/opt/grafana-1.9.0') }
      end

      context 'installs via archive with symlink' do
        let :params do
          {
            :install_method	=> 'archive',
            :symlink        => true,
            :datasources    => datasources
          }
        end

        it { should contain_archive('grafana-1.9.0')}
        it { should contain_file('/opt/grafana-1.9.0/config.js').with_ensure('present') }
        it { should contain_file('/opt/grafana').with_ensure('link').with_target('/opt/grafana-1.9.0') }
      end

      context 'install dir is not default' do
        let :params do
          {
            :install_method	=> 'archive',
            :install_dir    => '/tmp',
            :datasources    => datasources
          }
        end

        it { should contain_archive('grafana-1.9.0')}
        it { should contain_file('/tmp/grafana-1.9.0/config.js').with_ensure('present') }
      end

      context 'fail on empty datasources' do
        let :params do
          {
            :datasources	=> {},
          }
        end

        it { should_not compile }
      end

      context 'with graphite and elasticsearch datasources' do
        let :params do
          {
            :datasources => datasources
          }
        end

        it {
          should contain_file('/opt/grafana-1.9.0/config.js').with_content(/graphite: \{\n\s*default: true,\n\s*type: 'graphite',\n\s.*url: 'http:\/\/localhost:80/).with_content(/elasticsearch: \{\n\s*grafanaDB: true,\n\s*index: 'grafana-dash',\n\s*type: 'elasticsearch',\n\s*url: 'http:\/\/localhost:9200',/)
        }
      end
    end
end
