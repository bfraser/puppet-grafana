require 'spec_helper'

#Puppet::Util::Log.level = :debug
#Puppet::Util::Log.newdestination(:console)

describe 'grafana', :type => 'class' do

  context 'make sure it compiles' do
    it { should compile }
  end

  context 'installs via package' do
    let :params do
  	  {
  	    :install_method	=> 'package'
  	  }
  	end

  	it { should contain_package('grafana').with(:ensure	=> '1.7.1') }
  	it { should contain_file('/usr/share/grafana/config.js').with_ensure('present') }
  end

  context 'installs via archive and no symlink' do
    let :params do
  	  {
  	    :install_method	=> 'archive'
  	  }
  	end

  	it { should contain_archive('grafana-1.7.1')}
  	it { should contain_file('/opt/grafana-1.7.1/config.js').with_ensure('present') }
  end

  context 'installs via archive with symlink' do
    let :params do
  	  {
  	    :install_method	=> 'archive',
  	    :symlink        => '/opt/grafana'
  	  }
  	end

  	it { should contain_archive('grafana-1.7.1')}
  	it { should contain_file('/opt/grafana-1.7.1/config.js').with_ensure('present') }
  	it { should contain_file('/opt/grafana').with_ensure('link').with_target('/opt/grafana-1.7.1') }
  end

  context 'install dir is not default' do
    let :params do
  	  {
  	    :install_method	=> 'archive',
  	    :install_dir    => '/tmp'
  	  }
  	end

  	it { should contain_archive('grafana-1.7.1')}
  	it { should contain_file('/tmp/grafana-1.7.1/config.js').with_ensure('present') }
  end

end
