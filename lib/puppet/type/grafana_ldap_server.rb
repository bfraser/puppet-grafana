require 'puppet/parameter/boolean'

Puppet::Type.newtype(:grafana_ldap_server) do
  @doc = 'Manage Grafana LDAP servers for LDAP authentication.'

  validate do
    raise(_('grafana_ldap_server: name must not be empty')) if self[:name].nil? || self[:name].empty?
    raise(_('grafana_ldap_server: hosts must not be empty')) if self[:hosts].nil? || self[:hosts].empty?
    raise(_('grafana_ldap_server: port must not be empty')) if self[:port].nil?

    raise(_('grafana_ldap_server: root_ca_cert must be set when SSL/TLS is enabled')) \
      if !self[:ssl_skip_verify] && (self[:use_ssl] || self[:start_tls]) && self[:root_ca_cert].empty?

    raise(_('grafana_ldap_server: search_base_dns needs to contain at least one LDAP base-dn')) \
      if self[:search_base_dns].empty?

    raise(_('grafana_ldap_server: group_search_base_dns needs to contain at least one LDAP base-dn')) \
      if !self[:group_search_base_dns].nil? && self[:group_search_base_dns].empty?
  end

  newparam(:title, namevar: true) do
    desc 'A unique identified for this LDAP server.'

    validate do |value|
      raise ArgumentError, _('name/title must be a String') unless value.is_a?(String)
    end
  end

  newparam(:hosts) do
    desc 'The servers to perform LDAP authentication at'

    validate do |value|
      raise ArgumentError, _('hosts must be an Array') unless value.is_a?(Array)
    end
  end

  newparam(:port) do
    desc 'The port to connect at the LDAP servers (389 for TLS/plaintext, 636 for SSL [ldaps], optional)'
    defaultto 389

    validate do |value|
      raise ArgumentError, _('port must be an Integer within the range 1-65535') unless value.is_a?(Integer) && value.between?(1, 65_535) # rubocop wants to have this weirdness
    end
  end

  newparam(:use_ssl, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Set to true if you want to perform LDAP via a SSL-connection (not meant to be for TLS, optional)'
    defaultto false
  end

  newparam(:start_tls, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Set to true if you want to perform LDAP via a TLS-connection (not meant to be for SSL, optional)'
    defaultto true
  end

  newparam(:ssl_skip_verify, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "Set to true to disable verification of the LDAP server's SSL certificate (for TLS and SSL, optional)"
    defaultto false
  end

  newparam(:root_ca_cert) do
    desc "The root ca-certificate to verify the LDAP server's SSL certificate against (for TLS and SSL, optional)"
    defaultto '/etc/ssl/certs/ca-certificates.crt'

    validate do |value|
      raise ArgumentError, _('root_ca_cert must be a String') unless value.is_a?(String)
    end
  end

  newparam(:client_cert) do
    desc "If the LDAP server requires certificate-based authentication, specify the client's certificate (for TLS and SSL, optional)"

    validate do |value|
      raise ArgumentError, _('client_cert must be a String') unless value.is_a?(String)
    end
  end

  newparam(:client_key) do
    desc "If the LDAP server requires certificate-based authentication, specify the client's certificate (for TLS and SSL, optional)"

    validate do |value|
      raise ArgumentError, _('client_key must be a String') unless value.is_a?(String)
    end
  end

  newparam(:bind_dn) do
    desc 'If the LDAP server requires authentication (i.e. non-anonymous), provide the distinguished-name (dn) here (optional)'

    validate do |value|
      raise ArgumentError, _('bind_dn must be a String') unless value.is_a?(String)
    end
  end

  newparam(:bind_password) do
    desc 'If the LDAP server requires authentication (i.e. non-anonymous), provide the password (optional)'

    validate do |value|
      raise ArgumentError, _('bind_password must be a String') unless value.is_a?(String)
    end
  end

  newparam(:search_filter) do
    desc 'A search-filter to be used when querying LDAP for user-accounts (optional)'

    validate do |value|
      raise ArgumentError, _('search_filter must be a String') unless value.is_a?(String)
    end
  end

  newparam(:search_base_dns) do
    desc 'The one or more base-dn to be used when querying LDAP for user-accounts (optional)'
    defaultto []

    validate do |value|
      raise ArgumentError, _('search_base_dns must be an Array') unless value.is_a?(Array)

      value.each { |base_dn| raise ArgumentError, _('search_base_dns elements must be a String') unless base_dn.is_a?(String) }
    end
  end

  newparam(:group_search_filter) do
    desc 'A search-filter to be used when querying LDAP for group-accounts (optional)'

    validate do |value|
      raise ArgumentError, _('group_search_filter must be a String') unless value.is_a?(String)
    end
  end

  newparam(:group_search_filter_user_attribute) do
    desc 'The attribute to be used to locate matching user-accounts in the group (optional)'

    validate do |value|
      raise ArgumentError, _('group_search_filter_user_attribute must be a String') unless value.is_a?(String)
    end
  end

  newparam(:group_search_base_dns) do
    desc 'The base-dn to be used when querying LDAP for group-accounts (optional)'

    validate do |value|
      raise ArgumentError, _('search_base_dns must be an Array') unless value.is_a?(Array)

      value.each { |base_dn| raise ArgumentError, _('search_base_dns elements must be a String') unless base_dn.is_a?(String) }
    end
  end

  newparam(:attributes) do
    desc 'Mapping LDAP attributes to their Grafana user-account-properties (optional)'

    validate do |value|
      valid_attributes = %w[name surname username member_of email]

      raise ArgumentError, _('attributes must be a Hash') unless value.is_a?(Hash)

      value.each { |k, v| raise ArgumentError, _('attributes hash keys and values must be Strings') unless k.is_a?(String) && v.is_a?(String) }

      raise ArgumentError, _("attributes contains an unknown key, allowed: #{valid_attributes.join(', ')}") if value.keys.reject { |key| valid_attributes.include?(key) }.count > 0
    end
  end

  def set_sensitive_parameters(sensitive_parameters) # rubocop:disable Style/AccessorMethodName
    parameter(:bind_password).sensitive = true if parameter(:bind_password)
    super(sensitive_parameters)
  end

  def group_mappings
    catalog.resources.map do |resource|
      next unless resource.is_a?(Puppet::Type.type(:grafana_ldap_group_mapping))
      next unless resource[:ldap_server_name] == self[:name]

      group_mapping = Hash[resource.original_parameters.map { |k, v| [k.to_s, v] }]
      group_mapping.delete('ldap_server_name')

      group_mapping
    end.compact
  end
end
