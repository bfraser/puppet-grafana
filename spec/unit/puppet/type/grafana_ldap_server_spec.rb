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
describe Puppet::Type.type(:grafana_ldap_server) do
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
      end.to raise_error(RuntimeError, %r{must not be empty})
    end

    it 'fails if title is not a string' do
      expect do
        described_class.new name: 123
      end.to raise_error(Puppet::ResourceError, %r{must be a String})
    end
  end

  # hosts
  context 'validate hosts' do
    it 'fails if hosts is not set' do
      expect do
        described_class.new name: 'server1', hosts: nil
      end.to raise_error(Puppet::Error, %r{Got nil value for})
    end

    it 'fails if hosts is not an array' do
      expect do
        described_class.new name: 'server1', hosts: ''
      end.to raise_error(RuntimeError, %r{must be an Array})
    end

    it 'fails if hosts is empty' do
      expect do
        described_class.new name: 'server1', hosts: []
      end.to raise_error(RuntimeError, %r{must not be empty})
    end
  end

  # port
  context 'validate port' do
    it 'fails if port is empty' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], port: 0
      end.to raise_error(RuntimeError, %r{must be an Integer within})
    end

    it 'fails if port is a string' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], port: '123'
      end.to raise_error(Puppet::ResourceError, %r{must be an Integer within})
    end

    it 'fails if port is greater than 65535' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], port: 123_456
      end.to raise_error(Puppet::ResourceError, %r{must be an Integer within})
    end
  end

  # use_ssl
  context 'validate use_ssl' do
    it 'fails if use_ssl is not boolean' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], use_ssl: 'foobar'
      end.to raise_error(Puppet::Error, %r{Valid values are true})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], use_ssl: true
      end
    end
  end

  # start_tls
  context 'validate start_tls' do
    it 'fails if start_tls is not boolean' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], start_tls: 'foobar'
      end.to raise_error(Puppet::Error, %r{Valid values are true})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], start_tls: true
      end
    end
  end

  # ssl_skip_verify
  context 'validate ssl_skip_verify' do
    it 'fails if ssl_skip_verify is not boolean' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], ssl_skip_verify: 'foobar'
      end.to raise_error(Puppet::Error, %r{Valid values are true})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], ssl_skip_verify: true
      end
    end
  end

  # root_ca_cert
  context 'validate root_ca_cert' do
    it 'fails if root_ca_cert is empty' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], root_ca_cert: ''
      end.to raise_error(RuntimeError, %r{must be set when SSL})
    end

    it 'fails if root_ca_cert is not a string' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], root_ca_cert: 12_345
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], root_ca_cert: '/etc/ssl/certs/ca-certificate.crt'
      end
    end
  end

  # client_cert
  context 'validate client_cert' do
    it 'fails if client_cert is not a string' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], client_cert: 12_345
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], client_cert: '/etc/ssl/host.crt'
      end
    end
  end

  # client_key
  context 'validate client_key' do
    it 'fails if client_key is not a string' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], client_key: 12_345
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], client_key: '/etc/ssl/certs/ca-certificate.crt'
      end
    end
  end

  # bind_dn
  context 'validate bind_dn' do
    it 'fails if bind_dn is not a string' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], bind_dn: 12_345
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], bind_dn: 'cn=Admin', search_base_dns: ['ou=users']
      end
    end
  end

  # bind_password
  context 'validate bind_password' do
    it 'fails if bind_password is not a string' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], bind_password: 12_345
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], bind_password: 'foobar', search_base_dns: ['ou=users']
      end
    end
  end

  # search_filter
  context 'validate search_filter' do
    it 'fails if search_filter is not a string' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], search_filter: 12_345
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], search_filter: 'uid=%u', search_base_dns: ['ou=users']
      end
    end
  end

  # search_base_dns
  context 'validate search_base_dns' do
    it 'fails if search_base_dns is not an array' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], search_base_dns: 12_345
      end.to raise_error(Puppet::Error, %r{must be an Array})
    end

    it 'fails if search_base_dns array members are not strings' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], search_base_dns: [12_345]
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'fails if search_base_dns array is empty' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], search_base_dns: []
      end.to raise_error(RuntimeError, %r{needs to contain at least one LDAP base-dn})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], search_base_dns: ['ou=users']
      end
    end
  end

  # group_search_filter
  context 'validate group_search_filter' do
    it 'fails if group_search_filter is not a string' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], group_search_filter: 12_345
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], group_search_filter: 'cn=adminsgroup', search_base_dns: ['ou=users']
      end
    end
  end

  # group_search_filter_user_attribute
  context 'validate group_search_filter_user_attribute' do
    it 'fails if group_search_filter_user_attribute is not a string' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], group_search_filter_user_attribute: 12_345
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], group_search_filter_user_attribute: 'dn', search_base_dns: ['ou=users']
      end
    end
  end

  # group_search_base_dns
  context 'validate group_search_base_dns' do
    it 'fails if group_search_base_dns is not an array' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], group_search_base_dns: 12_345
      end.to raise_error(Puppet::Error, %r{must be an Array})
    end

    it 'fails if group_search_base_dns array members are not strings' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], group_search_base_dns: [12_345]
      end.to raise_error(Puppet::Error, %r{must be a String})
    end

    it 'fails if group_search_base_dns array is empty' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], group_search_base_dns: [], search_base_dns: ['ou=auth']
      end.to raise_error(RuntimeError, %r{needs to contain at least one LDAP base-dn})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], group_search_base_dns: ['ou=users']
      end
    end
  end

  # attributes
  context 'validate attributes' do
    it 'fails if attributes is not a hash' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], attributes: [12_345]
      end.to raise_error(Puppet::Error, %r{must be a Hash})
    end

    it 'fails if unknown attribute' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], attributes: { 'foo' => 'bar' }
      end.to raise_error(Puppet::Error, %r{contains an unknown key})
    end

    it 'fails if wrong key type' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], attributes: { 12_345 => 'bar' }
      end.to raise_error(Puppet::Error, %r{must be Strings})
    end

    it 'fails if wrong value type' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], attributes: { 'surname' => {} }
      end.to raise_error(Puppet::Error, %r{must be Strings})
    end

    it 'succeeds if all is correct' do
      expect do
        described_class.new name: 'server1', hosts: ['server1'], attributes: { 'username' => 'uid' }
      end
    end
  end
end
