# frozen_string_literal: true

require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_user).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Manages local Grafana users'

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def users
    response = send_request('GET', format('%s/users', resource[:grafana_api_path]))
    raise format('Fail to retrieve users (HTTP response: %s/%s)', response.code, response.body) if response.code != '200'

    begin
      users = JSON.parse(response.body)

      users.map { |x| x['id'] }.map do |id|
        response = send_request('GET', format('%s/users/%s', resource[:grafana_api_path], id))
        raise format('Fail to retrieve user %d (HTTP response: %s/%s)', id, response.code, response.body) if response.code != '200'

        user = JSON.parse(response.body)
        {
          id: id,
          name: user['login'],
          full_name: user['name'],
          email: user['email'],
          theme: user['theme'],
          password: nil,
          is_admin: user['isGrafanaAdmin'] ? :true : :false
        }
      end
    rescue JSON::ParserError
      raise format('Fail to parse response: %s', response.body)
    end
  end

  def user
    @user ||= users.find { |x| x[:name] == resource[:name] }
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

  def flush
    if @property_flush[:ensure] == :absent
      delete_user
      return
    end

    password = @property_flush.delete(:password)
    is_admin = @property_flush.delete(:is_admin)

    unless @property_flush.empty?
      debug('Updating user properties')

      # If we don't include the login name, and email is being updated, then login will be reset to match the email address!
      data = @property_flush.merge({ login: resource[:name] })
      response = send_request('PUT', format('%s/users/%s', resource[:grafana_api_path], user[:id]), data)
      raise format('Failed to update properties for user %s (HTTP response: %s/%s', resource[:name], response.code, response.body) if response.code != '200'
    end

    if password
      debug('Updating user password')
      response = send_request 'PUT', format('%s/admin/users/%s/password', resource[:grafana_api_path], user[:id]), password: password
      raise format('Failed to update password for user %s (HTTP response: %s/%s', resource[:name], response.code, response.body) if response.code != '200'
    end

    update_admin_flag(is_admin) unless is_admin.nil?
  end

  def update_admin_flag(is_admin)
    debug("Setting isGrafanaAdmin to #{is_admin}")
    response = send_request 'PUT', format('%s/admin/users/%s/permissions', resource[:grafana_api_path], user[:id]), isGrafanaAdmin: (is_admin == :true)
    raise format('Failed to update isGrafanaAdmin for user %s (HTTP response: %s/%s', resource[:name], response.code, response.body) if response.code != '200'
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

    raise format('Failed to delete user %s (HTTP response: %s/%s', resource[:name], response.code, response.body) if response.code != '200'

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
