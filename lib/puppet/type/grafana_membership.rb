# frozen_string_literal: true

Puppet::Type.newtype(:grafana_membership) do
  @doc = 'Manage resource memberships in Grafana'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the membership.'
  end

  newparam(:user_name) do
    desc 'The name of the user to add membership for'
  end

  newparam(:target_name) do
    desc 'The name of the target to add membership for'
  end

  newparam(:organization) do
    desc 'The name of the organization to add membership for (team only)'
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

  newparam(:membership_type) do
    desc 'The underlying type of the membership (organization, team)'
    newvalues(:organization, :team)
  end

  newproperty(:role) do
    desc 'The role to apply to the membership (Admin, Editor, Viewer)'
    newvalues(:Admin, :Editor, :Viewer)
  end

  autorequire(:service) do
    'grafana-server'
  end

  autorequire(:grafana_organization) do
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:grafana_organization)) }
  end

  autorequire(:grafana_team) do
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:grafana_team)) }
  end

  autorequire(:grafana_membership) do
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:grafana_membership)) && r['membership_type'] == :organization } if self[:membership_type] == :team
  end

  autorequire(:grafana_conn_validator) do
    'grafana'
  end
end
