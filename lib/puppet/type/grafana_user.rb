# frozen_string_literal: true

Puppet::Type.newtype(:grafana_user) do
  @doc = 'Manage users in Grafana'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The username of the user.'
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

  newproperty(:full_name) do
    desc 'The full name of the user.'
  end

  newproperty(:password) do
    desc 'The password for the user'
    def insync?(_is)
      provider.check_password
    end
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
  end

  newproperty(:organizations) do
    desc 'A hash of organizations and roles'

    validate do |value|
      raise ArgumentError, 'organizations must be a Hash!' unless value.nil? || value.is_a?(Hash)
      raise ArgumentError, 'organizations contains unrecognised roles' unless (value.values.map(&:downcase) - %w[viewer editor admin]).empty?
    end

    munge do |value|
      value.transform_values(&:capitalize)
    end
  end

  def set_sensitive_parameters(sensitive_parameters) # rubocop:disable Naming/AccessorMethodName
    parameter(:password).sensitive = true if parameter(:password)
    super(sensitive_parameters)
  end

  autorequire(:service) do
    'grafana-server'
  end

  autorequire(:grafana_conn_validator) do
    'grafana'
  end

  autorequire(:grafana_organization) do
    if self[:organizations]
      self[:organizations].keys
    else
      []
    end
  end
end
