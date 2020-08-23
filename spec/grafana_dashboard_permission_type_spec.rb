require 'spec_helper'

describe Puppet::Type.type(:grafana_dashboard_permission) do
  let(:gpermission) do
    described_class.new(
      title: 'foo_title',
      grafana_url: 'http://example.com/',
      grafana_api_path: '/api',
      user: 'foo_user',
      dashboard: 'foo_dashboard',
      permission: 'View',
      ensure: :present
    )
  end

  context 'when setting parameters' do
    it "fails if grafana_url isn't HTTP-based" do
      expect do
        described_class.new title: 'foo_title', name: 'foo', grafana_url: 'example.com', ensure: :present
      end.to raise_error(Puppet::Error, %r{not a valid URL})
    end

    it "fails if grafana_api_path isn't properly formed" do
      expect do
        described_class.new title: 'foo_title', grafana_url: 'http://example.com', grafana_api_path: '/invalidpath', ensure: :present
      end.to raise_error(Puppet::Error, %r{not a valid API path})
    end

    it 'fails if both user and team set' do
      expect do
        described_class.new title: 'foo title', user: 'foo_user', team: 'foo_team'
      end.to raise_error(Puppet::Error, %r{Only user or team can be set, not both})
    end
    it 'accepts valid parameters' do
      expect(gpermission[:user]).to eq('foo_user')
      expect(gpermission[:grafana_api_path]).to eq('/api')
      expect(gpermission[:grafana_url]).to eq('http://example.com/')
      expect(gpermission[:dashboard]).to eq('foo_dashboard')
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'autorequires the grafana-server for proper ordering' do
      catalog = Puppet::Resource::Catalog.new
      service = Puppet::Type.type(:service).new(name: 'grafana-server')
      catalog.add_resource service
      catalog.add_resource gpermission

      relationship = gpermission.autorequire.find do |rel|
        (rel.source.to_s == 'Service[grafana-server]') && (rel.target.to_s == gpermission.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end

    it 'does not autorequire the service it is not managed' do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource gpermission
      expect(gpermission.autorequire).to be_empty
    end
  end
end
