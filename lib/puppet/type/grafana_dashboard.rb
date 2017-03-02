#    Copyright 2015 Mirantis, Inc.
#
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
require 'json'

Puppet::Type.newtype(:grafana_dashboard) do
  @doc = 'Manage dashboards in Grafana'

  ensurable

  newparam(:title, namevar: true) do
    desc 'The title of the dashboard.'
  end

  newproperty(:content) do
    desc 'The JSON representation of the dashboard.'

    validate do |value|
      begin
        JSON.parse(value)
      rescue JSON::ParserError
        raise ArgumentError, 'Invalid JSON string for content'
      end
    end

    munge do |value|
      new_value = JSON.parse(value).reject { |k, _| k =~ %r{^id|version|title$} }
      new_value.sort.to_h
    end

    def should_to_s(value)
      if value.length > 12
        "#{value.to_s.slice(0, 12)}..."
      else
        value
      end
    end
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
    desc 'The username for the Grafana server (optional)'
  end

  newparam(:grafana_password) do
    desc 'The password for the Grafana server (optional)'
  end

  # rubocop:disable Style/SignalException
  validate do
    fail('content is required when ensure is present') if self[:ensure] == :present && self[:content].nil?
  end
  autorequire(:service) do
    'grafana-server'
  end
end
