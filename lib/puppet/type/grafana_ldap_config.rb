# frozen_string_literal: true

require 'toml'
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:grafana_ldap_config) do
  @doc = 'Manage Grafana LDAP configuration'
  @toml_header = <<~EOF
    #
    # Grafana LDAP configuration
    #
    # generated by Puppet module puppet-grafana
    #   https://github.com/voxpupuli/puppet-grafana
    #
    # *** Edit at your own peril ***
    #
    # ############################################# #
  EOF

  # currently not ensurable as we are not parsing the LDAP toml config.
  # ensurable

  newparam(:title, namevar: true) do
    desc 'Path to ldap.toml'

    validate do |value|
      raise ArgumentError, _('name/title must be a String') unless value.is_a?(String)
    end
  end

  newparam(:owner) do
    desc 'Owner of the LDAP configuration-file either as String or Integer (default: root)'
    defaultto 'root'

    validate do |value|
      raise ArgumentError, _('owner must be a String or Integer') unless value.is_a?(String) || value.is_a?(Integer)
    end
  end

  newparam(:group) do
    desc 'Group of the LDAP configuration file either as String or Integer (default: grafana)'
    defaultto 'grafana'

    validate do |value|
      raise ArgumentError, _('group must be a String or Integer') unless value.is_a?(String) || value.is_a?(Integer)
    end
  end

  newparam(:mode) do
    desc 'File-permissions mode of the LDAP configuration file as String'
    defaultto '0440'

    validate do |value|
      raise ArgumentError, _('file-permissions must be a String') unless value.is_a?(String)
      raise ArgumentError, _('file-permissions must be a String') if value.empty?
      # regex-pattern stolen from here - all credis to them!
      # https://github.com/puppetlabs/puppetlabs-stdlib/blob/master/types/filemode.pp
      # currently disabled, as it fails when implicitly called.
      #
      # raise ArgumentError, _('file-permissions is not valid') unless value.to_s.match(%r{/\A(([0-7]{1,4})|(([ugoa]*([-+=]([rwxXst]*|[ugo]))+|[-+=][0-7]+)(,([ugoa]*([-+=]([rwxXst]*|[ugo]))+|[-+=][0-7]+))*))\z/})
    end
  end

  newparam(:replace, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Replace existing files'
    defaultto true
  end

  newparam(:backup, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Backup existing files before replacing them into the file-bucket'
    defaultto false
  end

  newparam(:validate_cmd) do
    desc 'A command to validate the new Grafana LDAP configuration before actually replacing it'

    validate do |value|
      raise ArgumentError, _('validate_cmd must be a String or undef') unless value.nil? || value.is_a?(String)
    end
  end

  def ldap_servers
    catalog.resources.each_with_object({}) do |resource, memo|
      next unless resource.is_a?(Puppet::Type.type(:grafana_ldap_server))
      next unless resource[:name].is_a?(String)

      memo[resource[:name]] = resource
      memo
    end
  end

  def should_content
    return @generated_config if @generated_config

    @generated_config = {}

    ldap_servers.each do |server_k, server_v|
      # convert symbols to strings
      server_params = server_v.original_parameters.transform_keys(&:to_s)

      server_attributes = server_params['attributes']
      server_params.delete('attributes')

      # grafana-syntax for multiple hosts is a space-separate list.
      server_params['host'] = server_params['hosts'].join(' ')
      server_params.delete('hosts')

      server_group_mappings = server_v.group_mappings

      server_block = {
        'servers' => [server_params],
        'servers.attributes' => server_attributes,
        'servers.group_mappings' => server_group_mappings
      }.compact

      @generated_config[server_k] = server_block
    end

    @generated_config.compact
  end

  def generate
    file_opts = {}
    # currently not ensurable
    # file_opts = {
    #  ensure: (self[:ensure] == :absent) ? :absent : :file,
    # }

    [:name,
     :owner,
     :group,
     :mode,
     :replace,
     :backup,
     # this we have currently not implemented
     #     :selinux_ignore_defaults,
     #     :selrange,
     #     :selrole,
     #     :seltype,
     #     :seluser,
     #     :show_diff,
     :validate_cmd].each do |param|
      file_opts[param] = self[param] unless self[param].nil?
    end

    metaparams = Puppet::Type.metaparams
    excluded_metaparams = %w[before notify require subscribe tag]

    metaparams.reject! { |param| excluded_metaparams.include? param }

    metaparams.each do |metaparam|
      file_opts[metaparam] = self[metaparam] unless self[metaparam].nil?
    end

    [Puppet::Type.type(:file).new(file_opts)]
  end

  def eval_generate
    ldap_servers = should_content

    if !ldap_servers.nil? && !ldap_servers.empty?

      toml_contents = []
      toml_contents << @toml_header

      toml_contents << ldap_servers.map do |k, v|
        str = []
        str << "\n\n"
        str << <<~EOF
          #
          # #{k}
          #
        EOF
        str << TOML::Generator.new(v).body
        str.join
      end

      catalog.resource("File[#{self[:name]}]")[:content] = toml_contents.join
    end

    [catalog.resource("File[#{self[:name]}]")]
  end

  autonotify(:class) do
    'grafana::service'
  end
end
