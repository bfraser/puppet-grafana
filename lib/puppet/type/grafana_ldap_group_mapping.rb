require 'puppet/parameter/boolean'

Puppet::Type.newtype(:grafana_ldap_group_mapping) do
  @doc = 'Map an LDAP group to a Grafana role.'

  def initialize(*args)
    @org_roles = %w[Admin Editor Viewer]
    super
  end

  validate do
    raise(_('grafana_ldap_group_mapping: title needs to be a non-empty string')) if self[:name].nil? || self[:name].empty?
    raise(_('grafana_ldap_group_mapping: ldap_server_name needs to be a non-empty string')) if self[:ldap_server_name].nil? || self[:ldap_server_name].empty?
    raise(_('grafana_ldap_group_mapping: group_dn needs to be a non-empty string')) if self[:group_dn].nil? || self[:group_dn].empty?
    raise(_("grafana_ldap_group_mapping: org_role needs to be a string of: #{@org_roles.join(', ')})")) if self[:org_role].nil? || self[:org_role].empty?
  end

  newparam(:title, namevar: true) do
    desc 'A unique identifier of the resource'

    validate do |value|
      raise ArgumentError, _('name/title must be a String') unless value.is_a?(String)
    end
  end

  newparam(:ldap_server_name) do
    desc 'The LDAP server config to apply the group-mappings on'

    validate do |value|
      raise ArgumentError, _('ldap_server_name must be a String') unless value.is_a?(String)
    end
  end

  newparam(:group_dn) do
    desc 'The LDAP distinguished-name of the group'

    validate do |value|
      raise ArgumentError, _('group_dn must be a String') unless value.is_a?(String)
    end
  end

  newparam(:org_role) do
    desc 'The Grafana role the shall be assigned to this group'
    newvalues(:Admin, :Editor, :Viewer)
  end

  newparam(:grafana_admin, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Additonal flag for Grafana > v5.3 to signal admin-role to Grafana'
    defaultto false
  end
end
