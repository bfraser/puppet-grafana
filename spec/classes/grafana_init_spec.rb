require 'spec_helper'

describe 'grafana', :type => 'class' do
  context 'with default settings' do
    let :params do
      {
        :version      => '1.6.1',
        :install_dir  => '/opt',
        :symlink      => true,
        :symlink_name => '/opt/grafana',
      }
    end

    it { should contain_file('/opt/grafana-1.6.1/config.js').with(
      :ensure => 'present'
    )}

    it { should contain_file('/opt/grafana').with(
      :ensure => 'link',
      :target => '/opt/grafana-1.6.1'
    )}
  end

  context 'with a non-default installation directory specified' do
    let :params do
      {
        :install_dir  => '/usr/local',
        :version      => '1.3.3.7',
        :symlink      => true,
      }
    end

    it { should contain_file('/usr/local/grafana-1.3.3.7/config.js') }

    it { should contain_file('/usr/local/grafana').with(
      :ensure => 'link',
      :target => '/usr/local/grafana-1.3.3.7'
    )}
  end
end
