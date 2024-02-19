# frozen_string_literal: true

#    Copyright 2015 Mirantis, Inc.
#
Puppet::Type.newtype(:grafana_datasource) do
  @doc = 'Manage datasources in Grafana'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the datasource.'
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

  newproperty(:uid) do
    desc 'An optional unique identifier for the datasource. Supported by grafana 7.3 onwards. If you do not specify this parameter, grafana will assign a uid for you'
  end

  newproperty(:url) do
    desc 'The URL/Endpoint of the datasource'
  end

  newproperty(:type) do
    desc 'The datasource type'
  end

  newparam(:organization) do
    desc 'The organization name to create the datasource on'
    defaultto 1
  end

  newproperty(:user) do
    desc 'The username for the datasource (optional)'
  end

  newproperty(:password) do
    desc 'The password for the datasource (optional)'
    sensitive true
  end

  newproperty(:database) do
    desc 'The name of the database (optional)'
  end

  newproperty(:access_mode) do
    desc 'Whether the datasource is accessed directly or not by the clients'
    newvalues(:direct, :proxy)
  end

  newproperty(:is_default) do
    desc 'Whether the datasource is the default one'
    newvalues(:true, :false)
  end

  newproperty(:basic_auth) do
    desc 'Whether basic auth is enabled or not'
    newvalues(:true, :false)
  end

  newproperty(:basic_auth_user) do
    desc 'The username for basic auth if enabled'
  end

  newproperty(:basic_auth_password) do
    desc 'The password for basic auth if enabled'
  end

  newproperty(:with_credentials) do
    desc 'Whether credentials such as cookies or auth headers should be sent with cross-site requests'
    newvalues(:true, :false)
  end

  newproperty(:json_data) do
    desc 'Additional JSON data to configure the datasource (optional)'

    validate do |value|
      raise ArgumentError, 'json_data should be a Hash!' unless value.nil? || value.is_a?(Hash)
    end
  end

  newproperty(:secure_json_data) do
    desc 'Additional secure JSON data to configure the datasource (optional)'
    sensitive true

    validate do |value|
      raise ArgumentError, 'secure_json_data should be a Hash!' unless value.nil? || value.is_a?(Hash)
    end

    # Unwrap any sensitive values _in_ the hash. For instance those created by
    # node_encrypt. The whole property is automatically marked as `sensitive`
    # anyway and puppet won't unwrap the nested sensitive data for us.
    munge do |hash|
      hash.transform_values do |v|
        if v.instance_of?(Puppet::Pops::Types::PSensitiveType::Sensitive)
          v.unwrap
        else
          v
        end
      end
    end
  end

  def set_sensitive_parameters(sensitive_parameters) # rubocop:disable Naming/AccessorMethodName
    parameter(:password).sensitive = true if parameter(:password)
    parameter(:basic_auth_password).sensitive = true if parameter(:basic_auth_password)
    super(sensitive_parameters)
  end

  autorequire(:service) do
    'grafana-server'
  end

  autorequire(:grafana_conn_validator) do
    'grafana'
  end
end
