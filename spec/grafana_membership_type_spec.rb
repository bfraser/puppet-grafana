require 'spec_helper'

describe Puppet::Type.type(:grafana_membership) do
  let(:gmembership) do
    described_class.new(
      title: 'foo_title',
      user_name: 'foo_user',
      target_name: 'foo_target',
      grafana_url: 'http://example.com/',
      grafana_api_path: '/api',
      membership_type: 'organization',
      role: 'Viewer',
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

    it 'fails if membership type not valid' do
      expect do
        described_class.new title: 'foo title', membership_type: 'foo'
      end.to raise_error(Puppet::Error, %r{Invalid value "foo"})
    end
    it 'accepts valid parameters' do
      expect(gmembership[:user_name]).to eq('foo_user')
      expect(gmembership[:target_name]).to eq('foo_target')
      expect(gmembership[:grafana_api_path]).to eq('/api')
      expect(gmembership[:grafana_url]).to eq('http://example.com/')
      expect(gmembership[:membership_type]).to eq(:organization)
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'autorequires the grafana-server for proper ordering' do
      catalog = Puppet::Resource::Catalog.new
      service = Puppet::Type.type(:service).new(name: 'grafana-server')
      catalog.add_resource service
      catalog.add_resource gmembership

      relationship = gmembership.autorequire.find do |rel|
        (rel.source.to_s == 'Service[grafana-server]') && (rel.target.to_s == gmembership.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end

    it 'does not autorequire the service it is not managed' do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource gmembership
      expect(gmembership.autorequire).to be_empty
    end
  end
end
