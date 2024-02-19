# frozen_string_literal: true

Puppet::Type.newtype(:grafana_organization) do
  @doc = 'Manage organizations in Grafana'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'The name of the organization.'

    # You can't delete the default organization without first switching the API user (eg. 'admin')
    # to another org first, so implementing this is non trivial.
    validate do |value|
      raise ArgumentError, format('Unable to modify default organization') if value == 'Main Org.'
    end
  end

  newparam(:grafana_api_path) do
    desc 'The absolute path to the API endpoint'
    defaultto '/api'

    validate do |value|
      raise ArgumentError, format('%s is not a valid API path', value) unless value =~ %r{^/.*/?api$}
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
    desc 'The username for the Grafana server'
  end

  newparam(:grafana_password) do
    desc 'The password for the Grafana server'
  end

  autorequire(:service) do
    'grafana-server'
  end

  autorequire(:grafana_conn_validator) do
    'grafana'
  end
end
