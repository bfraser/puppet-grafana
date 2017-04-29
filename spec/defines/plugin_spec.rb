require 'spec_helper'

describe 'grafana::plugin', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      let :title do
        'grafana-simple-json-datasource'
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec("install #{title}") }
      end
    end
  end
end
