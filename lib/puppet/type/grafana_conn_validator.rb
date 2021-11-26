# frozen_string_literal: true

Puppet::Type.newtype(:grafana_conn_validator) do
  desc <<-DESC
  Verify connectivity to the Grafana API
  DESC

  ensurable

  newparam(:name, namevar: true) do
    desc 'Arbitrary name of this resource'
  end

  newparam(:grafana_url) do
    desc 'The URL of the Grafana server'
    defaultto 'http://localhost:3000'

    validate do |value|
      raise ArgumentError, format('%s is not a valid URL', value) unless value =~ %r{^https?://}
    end
  end

  newparam(:grafana_api_path) do
    desc 'The absolute path to the API endpoint'
    defaultto '/api/health'

    validate do |value|
      raise ArgumentError, format('%s is not a valid API path', value) unless value =~ %r{^/.*/?api/.*$}
    end
  end

  newparam(:timeout) do
    desc 'How long to wait for the API to be available'
    defaultto(20)
  end

  autorequire(:service) do
    'grafana-server'
  end
end
