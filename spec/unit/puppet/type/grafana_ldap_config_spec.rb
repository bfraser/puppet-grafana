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
describe Puppet::Type.type(:grafana_ldap_config) do
  # resource title
  context 'validate resource title' do
    it 'fails if title is not set' do
      expect do
        described_class.new name: nil
      end.to raise_error(Puppet::Error, %r{Title or name must be provided})
    end

    it 'fails if title is not a string' do
      expect do
        described_class.new name: 123
      end.to raise_error(Puppet::ResourceError, %r{must be a String})
    end
  end

  # owner
  context 'validate owner' do
    it 'fails if owner is wrong type' do
      expect do
        described_class.new name: 'foo_bar', owner: true
      end.to raise_error(Puppet::ResourceError, %r{must be a String or Integer})
    end

    it 'succeeds if owner is string' do
      expect do
        described_class.new name: 'foo_bar', owner: 'foo'
      end
    end

    it 'succeeds if owner is numeric' do
      expect do
        described_class.new name: 'foo_bar', owner: 111
      end
    end
  end

  # group
  context 'validate group' do
    it 'fails if group is wrong type' do
      expect do
        described_class.new name: 'foo_bar', group: true
      end.to raise_error(Puppet::ResourceError, %r{must be a String or Integer})
    end

    it 'succeeds if group is string' do
      expect do
        described_class.new name: 'foo_bar', group: 'foo'
      end
    end

    it 'succeeds if group is numeric' do
      expect do
        described_class.new name: 'foo_bar', owner: 111
      end
    end
  end

  # mode
  context 'validate mode' do
    it 'fails if mode is wrong type' do
      expect do
        described_class.new name: 'foo_bar', mode: 123
      end.to raise_error(Puppet::ResourceError, %r{must be a String})
    end

    it 'fails if mode is empty' do
      expect do
        described_class.new name: 'foo_bar', mode: ''
      end.to raise_error(Puppet::ResourceError, %r{must be a String})
    end

    # currently disabled
    # it 'fails if mode is invalid' do
    #   expect do
    #     described_class.new name: 'foo_bar', mode: 'abcd'
    #   end.to raise_error(Puppet::ResourceError, %r{is not valid})
    # end

    it 'succeeds if mode is string' do
      expect do
        described_class.new name: 'foo_bar', mode: '0755'
      end
    end
  end

  # replace
  context 'validate replace' do
    it 'fails if replace is not a boolean' do
      expect do
        described_class.new name: 'foo_bar', replace: 'bla'
      end.to raise_error(Puppet::ResourceError, %r{Valid values are})
    end

    it 'succeeds if replace' do
      expect do
        described_class.new name: 'foo_bar', replace: true
      end
    end
  end

  # backup
  context 'validate backup' do
    it 'fails if backup is not a boolean' do
      expect do
        described_class.new name: 'foo_bar', backup: 'bla'
      end.to raise_error(Puppet::ResourceError, %r{Valid values are})
    end

    it 'succeeds if backup' do
      expect do
        described_class.new name: 'foo_bar', backup: true
      end
    end
  end

  # validate_cmd
  context 'validate validate_cmd' do
    it 'fails if validate_cmd is wrong type' do
      expect do
        described_class.new name: 'foo_bar', validate_cmd: 123
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'succeeds if group is string' do
      expect do
        described_class.new name: 'foo_bar', validate_cmd: '0755'
      end
    end
  end

  # ldap_servers
  context 'validate ldap_servers' do
    it 'correctly returns the declared LDAP servers' do
      catalog = Puppet::Resource::Catalog.new
      server = Puppet::Type.type(:grafana_ldap_server).new(
        name: 'ldap.example.com',
        hosts: ['ldap.example.com'],
        search_base_dns: ['ou=auth']
      )
      config = Puppet::Type.type(:grafana_ldap_config).new name: 'ldap1'

      catalog.add_resource server
      catalog.add_resource config

      expect(config.ldap_servers.keys).to include('ldap.example.com')
    end
  end
end
