# frozen_string_literal: true

Puppet::Type.newtype(:grafana_dashboard_permission) do
  @doc = 'Manage dashboard permissions in Grafana'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the permission.'
  end

  newparam(:user) do
    desc 'User to add the permission for'

    validate do |value|
      raise ArgumentError, 'Only user or team can be set, not both' if value && @resource[:team]
    end
  end

  newparam(:team) do
    desc 'Team to add the permission for'

    validate do |value|
      raise ArgumentError, 'Only user or team can be set, not both' if value && @resource[:user]
    end
  end

  newparam(:dashboard) do
    desc 'Dashboard to modify permissions for'
  end

  newparam(:organization) do
    desc 'The name of the organization to add permission for'
    defaultto 'Main Org.'
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

  newproperty(:permission) do
    desc 'The role to apply'
    newvalues(:Admin, :Edit, :View)
  end

  autorequire(:service) do
    'grafana-server'
  end

  autorequire(:grafana_organization) do
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:grafana_organization)) }
  end

  autorequire(:grafana_user) do
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:grafana_user)) }
  end

  autorequire(:grafana_team) do
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:grafana_team)) }
  end

  autorequire(:grafana_dashboard) do
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:grafana_dashboard)) }
  end

  autorequire(:grafana_conn_validator) do
    'grafana'
  end
end
