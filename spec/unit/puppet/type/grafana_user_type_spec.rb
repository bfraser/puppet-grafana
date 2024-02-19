# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'spec_helper'

describe Puppet::Type.type(:grafana_user) do
  let(:guser) do
    described_class.new name: 'test', full_name: 'Mr tester', password: 't3st', grafana_url: 'http://example.com/'
  end

  context 'when setting parameters' do
    it "fails if grafana_url isn't HTTP-based" do
      expect do
        described_class.new name: 'test', grafana_url: 'example.com'
      end.to raise_error(Puppet::Error, %r{not a valid URL})
    end

    it 'accepts valid parameters' do
      expect(guser[:name]).to eq('test')
      expect(guser[:full_name]).to eq('Mr tester')
      expect(guser[:password]).to eq('t3st')
      expect(guser[:grafana_url]).to eq('http://example.com/')
    end

    describe 'organizations' do
      it 'has an `organizations` property' do
        expect(described_class.attrtype(:organizations)).to eq(:property)
      end

      [
        { 'org1' => 'viewer', 'org2' => 'admin', 'org3' => 'editor' },
        { 'org1' => 'Viewer', 'org2' => 'Admin', 'org3' => 'Editor' },
        {},
      ].each do |value|
        it "supports #{value} as a value for `organizations`" do
          expect { described_class.new(name: 'test', grafana_url: 'http://example.com/', organizations: value) }.not_to raise_error
        end
      end

      [
        'org1',
        42,
        false,
        true,
      ].each do |value|
        it "does not support #{value} as a value for `organizations`" do
          expect { described_class.new(name: 'test', grafana_url: 'http://example.com/', organizations: value) }.to raise_error(Puppet::Error, %r{organizations must be a Hash})
        end
      end

      it 'does not accept unknown roles' do
        expect { described_class.new(name: 'test', grafana_url: 'http://example.com/', organizations: { 'org1' => 'superuser' }) }.to raise_error(Puppet::Error, %r{organizations contains unrecognised roles})
      end

      it 'capitalizes role names' do
        expect(described_class.new(name: 'test', grafana_url: 'http://example.com/', organizations: { 'org1' => 'admin' })[:organizations]).to eq({ 'org1' => 'Admin' })
      end
    end

    it 'autorequires the grafana-server for proper ordering' do
      catalog = Puppet::Resource::Catalog.new
      service = Puppet::Type.type(:service).new(name: 'grafana-server')
      catalog.add_resource service
      catalog.add_resource guser

      relationship = guser.autorequire.find do |rel|
        (rel.source.to_s == 'Service[grafana-server]') && (rel.target.to_s == guser.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end

    it 'does not autorequire the service it is not managed' do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource guser
      expect(guser.autorequire).to be_empty
    end

    it 'autorequires grafana_conn_validator' do
      catalog = Puppet::Resource::Catalog.new
      validator = Puppet::Type.type(:grafana_conn_validator).new(name: 'grafana')
      catalog.add_resource validator
      catalog.add_resource guser

      relationship = guser.autorequire.find do |rel|
        (rel.source.to_s == 'Grafana_conn_validator[grafana]') && (rel.target.to_s == guser.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end

    it 'autorequires the grafana_organizations for proper ordering' do
      catalog = Puppet::Resource::Catalog.new
      organization = Puppet::Type.type(:grafana_organization).new(name: 'testorg', grafana_url: 'http://example.com/')
      user = described_class.new(name: 'test', grafana_url: 'http://example.com/', organizations: { 'testorg' => 'Admin' })
      catalog.add_resource organization
      catalog.add_resource user

      relationship = user.autorequire.find do |rel|
        (rel.source.to_s == 'Grafana_organization[testorg]') && (rel.target.to_s == user.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end
  end
end
