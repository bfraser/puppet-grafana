# frozen_string_literal: true

require 'json'

Puppet::Type.newtype(:grafana_folder) do
  @doc = 'Manage folders in Grafana'

  ensurable

  newparam(:title, namevar: true) do
    desc 'The title of the folder'
  end

  newparam(:uid) do
    desc 'UID of the folder'
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
    desc 'The organization name to create the folder on'
    defaultto 1
  end

  newproperty(:permissions, array_matching: :all) do
    desc 'The permissions of the folder'
    def insync?(is)
      is.sort_by { |k| k['permission'] } == should.sort_by { |k| k['permission'] }
    end
  end

  autorequire(:service) do
    'grafana-server'
  end

  autorequire(:grafana_conn_validator) do
    'grafana'
  end
end
