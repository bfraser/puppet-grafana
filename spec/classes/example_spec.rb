require 'spec_helper'

describe 'grafana' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "grafana class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('grafana::params') }
        it { should contain_class('grafana::install').that_comes_before('grafana::config') }
        it { should contain_class('grafana::config') }
        it { should contain_class('grafana::service').that_subscribes_to('grafana::config') }

        it { should contain_service('grafana') }
        it { should contain_package('grafana').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'grafana class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('grafana') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end

  context 'invalid parameters' do
    context 'cfg' do
      let(:facts) {{
        :osfamily => 'Debian',
      }}

      describe 'should raise an error when cfg parameter is not a hash' do
        let(:params) {{
          :cfg => [],
        }}

        it { expect { should contain_package('grafana') }.to raise_error(Puppet::Error, /cfg parameter must be a hash/) }
      end

      describe 'should not raise an error when cfg parameter is a hash' do
        let(:params) {{
          :cfg => {},
        }}

        it { should contain_package('grafana') }
      end
    end
  end

  context 'configuration file' do
    let(:facts) {{
      :osfamily => 'Debian',
    }}

    describe 'should not contain any configuration when cfg param is empty' do
      it { should contain_file('/etc/grafana/grafana.ini').with_content("# This file is managed by Puppet, any changes will be overwritten\n\n") }
    end

    describe 'should correctly transform cfg param entries to Grafana configuration' do
      let(:params) {{
        :cfg => {
          'app_mode' => 'production',
          'section' => {
            'string' => 'production',
            'number' => 8080,
            'boolean' => false,
            'empty' => '',
          },
        },
      }}

      expected = "# This file is managed by Puppet, any changes will be overwritten\n\n"\
                 "app_mode = production\n\n"\
                 "[section]\n"\
                 "string = production\n"\
                 "number = 8080\n"\
                 "boolean = false\n"\
                 "empty = \n"

      it { should contain_file('/etc/grafana/grafana.ini').with_content(expected) }
    end
  end
end
