# frozen_string_literal: true

#    Copyright 2015 Mirantis, Inc.
#
require 'json'

Puppet::Type.newtype(:grafana_dashboard) do
  @doc = 'Manage dashboards in Grafana'

  ensurable

  newparam(:title, namevar: true) do
    desc 'The title of the dashboard.'
  end

  newparam(:folder) do
    desc 'The folder to place the dashboard in (optional)'
  end

  newproperty(:content) do
    desc 'The JSON representation of the dashboard.'

    validate do |value|
      JSON.parse(value)
    rescue JSON::ParserError
      raise ArgumentError, 'Invalid JSON string for content'
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
      raise ArgumentError, format('%s is not a valid URL', value) unless value =~ %r{^https?://}
    end
  end

  newparam(:grafana_user) do
    desc 'The username for the Grafana server (optional)'
  end

  newparam(:grafana_password) do
    desc 'The password for the Grafana server (optional)'
  end

  newparam(:grafana_api_path) do
    desc 'The absolute path to the API endpoint'
    defaultto '/api'

    validate do |value|
      raise ArgumentError, format('%s is not a valid API path', value) unless value =~ %r{^/.*/?api$}
    end
  end

  newparam(:organization) do
    desc 'The organization name to create the datasource on'
    defaultto 1
  end

  validate do
    fail('content is required when ensure is present') if self[:ensure] == :present && self[:content].nil? # rubocop:disable Style/SignalException
  end
  autorequire(:service) do
    'grafana-server'
  end

  autorequire(:grafana_conn_validator) do
    'grafana'
  end
end
