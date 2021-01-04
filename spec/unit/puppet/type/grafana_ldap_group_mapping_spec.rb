#
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
#
require 'spec_helper'
# rubocop:disable RSpec/VoidExpect
describe Puppet::Type.type(:grafana_ldap_group_mapping) do
  # resource title
  context 'validate resource title' do
    it 'fails if title is not set' do
      expect do
        described_class.new name: nil
      end.to raise_error(Puppet::Error, %r{Title or name must be provided})
    end

    it 'fails if title is empty' do
      expect do
        described_class.new name: ''
      end.to raise_error(RuntimeError, %r{needs to be a non-empty string})
    end

    it 'fails if title is not a string' do
      expect do
        described_class.new name: 123
      end.to raise_error(Puppet::ResourceError, %r{must be a String})
    end
  end

  # ldap_server_name
  context 'validate ldap_server_name' do
    it 'fails if ldap_server_name is not set' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: nil, group_dn: 'bar'
      end.to raise_error(Puppet::Error, %r{Got nil value for})
    end

    it 'fails if ldap_server_name is empty' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: '', group_dn: 'bar'
      end.to raise_error(RuntimeError, %r{needs to be a non-empty string})
    end

    it 'fails if ldap_server_name is not a string' do
      expect do
        described_class.new name: '123_bar', ldap_server_name: 123, group_dn: 'bar'
      end.to raise_error(Puppet::ResourceError, %r{must be a String})
    end
  end

  # group_dn
  context 'validate group_dn' do
    it 'fails if group_dn is not set' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: nil
      end.to raise_error(Puppet::Error, %r{Got nil value for})
    end

    it 'fails if group_dn is empty' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: ''
      end.to raise_error(RuntimeError, %r{needs to be a non-empty string})
    end

    it 'fails if group_dn is not a string' do
      expect do
        described_class.new name: 'foo_123', ldap_server_name: 'foo', group_dn: 123
      end.to raise_error(Puppet::ResourceError, %r{must be a String})
    end
  end

  # org_role
  context 'validate org_role' do
    it 'fails if org_role is not set' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: 'bar', org_role: nil
      end.to raise_error(Puppet::Error, %r{Got nil value for})
    end

    it 'fails if org_role is not a string' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: 'bar', org_role: 123
      end.to raise_error(Puppet::ResourceError, %r{Valid values are})
    end

    it 'fails if org_role is an unknown role' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: 'bar', org_role: 'bla'
      end.to raise_error(Puppet::Error, %r{Valid values are})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: 'bar', org_role: 'Editor'
      end
    end
  end

  # grafana_admin
  context 'validate grafana_admin' do
    it 'fails if org_role is not a boolean' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: 'bar', org_role: 'Admin', grafana_admin: 'bla'
      end.to raise_error(Puppet::ResourceError, %r{Valid values are})
    end

    it 'succeeds if grafana_admin' do
      expect do
        described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: 'bar', org_role: 'Admin', grafana_admin: true
      end
    end
  end

  context 'valid viewer' do
    let(:group_mapping) do
      described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: 'bar', org_role: 'Viewer', grafana_admin: false
    end

    it 'given all parameters' do
      expect(group_mapping[:org_role]).to eq(:Viewer)
    end
  end

  context 'valid editor' do
    let(:group_mapping) do
      described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: 'bar', org_role: 'Editor', grafana_admin: false
    end

    it 'given all parameters' do
      expect(group_mapping[:org_role]).to eq(:Editor)
    end
  end

  context 'valid admin' do
    let(:group_mapping) do
      described_class.new name: 'foo_bar', ldap_server_name: 'foo', group_dn: 'bar', org_role: 'Admin', grafana_admin: true
    end

    it 'given all parameters' do
      expect(group_mapping[:org_role]).to eq(:Admin)
    end
  end
end
