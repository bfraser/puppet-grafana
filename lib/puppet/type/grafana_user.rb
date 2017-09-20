#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
Puppet::Type.newtype(:grafana_user) do
  @doc = 'Manage users in Grafana'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The username of the user.'
  end

  newparam(:grafana_url) do
    desc 'The URL of the Grafana server'
    defaultto ''

    validate do |value|
      unless value =~ %r{^https?://}
        raise ArgumentError, format('%s is not a valid URL', value)
      end
    end
  end

  newparam(:grafana_user) do
    desc 'The username for the Grafana server'
  end

  newparam(:grafana_password) do
    desc 'The password for the Grafana server'
  end

  newparam(:full_name) do
    desc 'The full name of the user.'
  end

  newproperty(:password) do
    desc 'The password for the user'
  end

  newproperty(:email) do
    desc 'The email for the user'
  end

  newproperty(:theme) do
    desc 'The theme for the user'
  end

  newproperty(:is_admin) do
    desc 'Whether the user is a grafana admin'
    newvalues(:true, :false)
    defaultto :false
  end

  autorequire(:service) do
    'grafana-server'
  end
end
