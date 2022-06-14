# frozen_string_literal: true

require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_user).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Manages local Grafana users'

  def initialize(value = {})
    super(value)
    @property_flush = {}
    @org_ids = {}
  end

  # https://grafana.com/docs/grafana/v8.4/http_api/user/#get-single-user-by-usernamelogin-or-email
  def get_user_by_name(username)
    response = send_request('GET', format('%s/users/lookup', resource[:grafana_api_path]), nil, { 'loginOrEmail' => username })

    case response.code
    when '404'
      ret = nil
    when '200'
      user = JSON.parse(response.body)
      ret = {
        id: user['id'],
        name: user['login'],
        full_name: user['name'],
        email: user['email'],
        theme: user['theme'],
        password: nil,
        is_admin: user['isGrafanaAdmin'] ? :true : :false,
        organizations: user_orgs(user['id'])
      }
    else
      raise format('Failed to retrieve user %s (HTTP response: %s/%s)', username, response.code, response.body)
    end

    ret
  end

  def user_orgs(user_id)
    response = send_request('GET', format('%s/users/%d/orgs', resource[:grafana_api_path], user_id))
    raise format('Failed to retrieve organizations for user with id %d (HTTP response: %s/%s)', user_id, response.code, response.body) if response.code != '200'

    JSON.parse(response.body).each_with_object({}) do |org, orgs|
      # Store the mapping of organization name to id so we can skip making an extra API call later
      @org_ids[org['name']] = org['orgId']
      orgs[org['name']] = org['role']
    end
  end

  # Returns the id of an organization
  # If we already have learnt this, and stored it in @org_ids we can just return it.
  # Otherwise, we have to make a separate API call to look it up.
  def org_id(org_name)
    return @org_ids[org_name] if @org_ids[org_name]

    debug("Looking up org_id of #{org_name}")

    response = send_request('GET', format('%s/orgs/name/%s', resource[:grafana_api_path], org_name))
    raise format('Failed to retrieve organization\'s id for %s (HTTP response: %s/%s)', org_name, response.code, response.body) if response.code != '200'

    @org_ids[org_name] = JSON.parse(response.body)['id']
  end

  def user
    @user ||= get_user_by_name(resource[:name])
    @user
  end

  attr_writer :user

  def name
    user[:name]
  end

  def name=(value)
    @property_flush[:login] = value
  end

  def full_name
    user[:full_name]
  end

  def full_name=(value)
    @property_flush[:name] = value
  end

  def email
    user[:email]
  end

  def email=(value)
    @property_flush[:email] = value
  end

  def theme
    user[:theme]
  end

  def theme=(value)
    @property_flush[:theme] = value
  end

  def password
    nil
  end

  def password=(value)
    @property_flush[:password] = value
  end

  # rubocop:disable Naming/PredicateName
  def is_admin
    user[:is_admin]
  end

  def is_admin=(value)
    @property_flush[:is_admin] = value
  end
  # rubocop:enable Naming/PredicateName

  def organizations
    user[:organizations]
  end

  def organizations=(value)
    @property_flush[:organizations] = value
  end

  def flush
    if @property_flush[:ensure] == :absent
      delete_user
      return
    end

    password = @property_flush.delete(:password)
    is_admin = @property_flush.delete(:is_admin)
    organizations = @property_flush.delete(:organizations)

    unless @property_flush.empty?
      debug('Updating user properties')

      # If we don't include the login name, and email is being updated, then login will be reset to match the email address!
      data = @property_flush.merge({ login: resource[:name] })
      response = send_request('PUT', format('%s/users/%s', resource[:grafana_api_path], user[:id]), data)
      raise format('Failed to update properties for user %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'
    end

    if password
      debug('Updating user password')
      response = send_request 'PUT', format('%s/admin/users/%s/password', resource[:grafana_api_path], user[:id]), password: password
      raise format('Failed to update password for user %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'
    end

    update_admin_flag(is_admin) unless is_admin.nil?

    update_organizations(organizations) unless organizations.nil?
  end

  def update_organizations(organizations)
    debug('Updating user organizations')

    # For all orgs that are in `to`, but not in `from`, add the user to the org
    (organizations.keys - user[:organizations].keys).each do |org|
      debug("Adding #{resource[:name]} to #{org} with role #{organizations[org]}")
      add_org_user(org_id(org), resource[:name], organizations[org])
    end

    # For all orgs that are in both, update the role if needed
    (organizations.keys & user[:organizations].keys).each do |org|
      unless organizations[org] == user[:organizations][org]
        debug("Updating #{resource[:name]} #{org} role to #{organizations[org]}")
        update_org_user(org_id(org), user[:id], organizations[org])
      end
    end

    # For all orgs that are in `from`, but not in `to`, delete the user from the org
    (user[:organizations].keys - organizations.keys).each do |org|
      debug("Deleting #{resource[:name]} from #{org}")
      delete_org_user(org_id(org), user[:id])
    end
  end

  def update_org_user(org_id, user_id, role)
    response = send_request 'PATCH', format('%s/orgs/%d/users/%d', resource[:grafana_api_path], org_id, user_id), { 'role' => role }
    raise format('Failed to update organization role for user_id %d and org_id %d to %s (HTTP response: %s/%s)', user_id, org_id, role, response.code, response.body) if response.code != '200'
  end

  def add_org_user(org_id, user_name, role)
    response = send_request 'POST', format('%s/orgs/%d/users', resource[:grafana_api_path], org_id), { 'loginOrEmail' => user_name, 'role' => role }
    raise format('Failed to add user_id %d to organization_id %d with role %s (HTTP response: %s/%s)', user_id, org_id, role, response.code, response.body) if response.code != '200'
  end

  def delete_org_user(org_id, user_id)
    response = send_request 'DELETE', format('%s/orgs/%d/users/%d', resource[:grafana_api_path], org_id, user_id)
    raise format('Failed to delete user_id %d from organization_id %d (HTTP response: %s/%s)', user_id, org_id, response.code, response.body) if response.code != '200'
  end

  def update_admin_flag(is_admin)
    debug("Setting isGrafanaAdmin to #{is_admin}")
    response = send_request 'PUT', format('%s/admin/users/%s/permissions', resource[:grafana_api_path], user[:id]), isGrafanaAdmin: (is_admin == :true)
    raise format('Failed to update isGrafanaAdmin for user %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'
  end

  def check_password
    uri = URI.parse format('%s://%s:%d%s/dashboards/home', grafana_scheme, grafana_host, grafana_port, resource[:grafana_api_path])
    request = Net::HTTP::Get.new(uri.to_s)
    request.content_type = 'application/json'
    request.basic_auth resource[:name], resource[:password]
    response = Net::HTTP.start(grafana_host, grafana_port,
                               use_ssl: grafana_scheme == 'https',
                               verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(request)
    end

    response.code == '200'
  end

  def delete_user
    response = send_request('DELETE', format('%s/admin/users/%s', resource[:grafana_api_path], user[:id]))

    raise format('Failed to delete user %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'

    self.user = nil
  end

  def create
    data = {
      login: resource[:name],
      name: resource[:full_name],
      email: resource[:email],
      theme: resource[:theme],
      password: resource[:password] || random_password,
    }.compact

    debug('Creating user')

    response = send_request('POST', format('%s/admin/users', resource[:grafana_api_path]), data)
    raise format('Failed to create user %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'

    update_admin_flag(resource[:is_admin]) unless resource[:is_admin].nil?
    update_organizations(resource[:organizations]) unless resource[:organizations].nil?
  end

  def random_password
    require 'securerandom'
    SecureRandom.hex(64)
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def exists?
    user
  end
end
