# frozen_string_literal: true

Puppet::Type.newtype(:grafana_team) do
  @doc = 'Manage teams in Grafana'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the team'
  end

  newparam(:grafana_api_path) do
    desc 'The absolute path to the API endpoint'
    defaultto '/api'

    validate do |value|
      unless value =~ %r{^/.*/?api$}
        raise ArgumentError, format('%s is not a valid API path', value)
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
    desc 'The username for the Grafana server'
  end

  newparam(:grafana_password) do
    desc 'The password for the Grafana server'
  end

  newparam(:organization) do
    desc 'The organization the team belongs to'
    defaultto 'Main Org.'
  end

  newparam(:email) do
    desc 'The email for the team'
    defaultto ''
  end

  newproperty(:home_dashboard_folder) do
    desc 'The UID or name of the home dashboard folder'
  end

  newproperty(:home_dashboard) do
    desc 'The id or name of the home dashboard'
    defaultto 'Default'
  end

  newproperty(:theme) do
    desc 'The theme to use for the team'
  end

  newproperty(:timezone) do
    desc 'The timezone to use for the team'
  end

  autorequire(:service) do
    'grafana-server'
  end

  autorequire(:grafana_dashboard) do
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:grafana_dashboard)) }
  end

  autorequire(:grafana_organization) do
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:grafana_organization)) }
  end

  autorequire(:grafana_conn_validator) do
    'grafana'
  end
end
