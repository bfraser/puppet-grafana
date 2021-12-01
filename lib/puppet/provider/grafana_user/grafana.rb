# frozen_string_literal: true

require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_user).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana users'

  defaultfor kernel: 'Linux'

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
    resource[:name] = value
    save_user
  end

  def full_name
    user[:full_name]
  end

  def full_name=(value)
    resource[:full_name] = value
    save_user
  end

  def email
    user[:email]
  end

  def email=(value)
    resource[:email] = value
    save_user
  end

  def theme
    user[:theme]
  end

  def theme=(value)
    resource[:theme] = value
    save_user
  end

  def password
    nil
  end

  def password=(value)
    resource[:password] = value
    save_user
  end

  # rubocop:disable Style/PredicateName
  def is_admin
    user[:is_admin]
  end

  def is_admin=(value)
    resource[:is_admin] = value
    save_user
  end
  # rubocop:enable Style/PredicateName

  def save_user
    data = {
      login: resource[:name],
      name: resource[:full_name],
      email: resource[:email],
      password: resource[:password],
      theme: resource[:theme],
      isGrafanaAdmin: (resource[:is_admin] == :true)
    }

    if user.nil?
      response = send_request('POST', format('%s/admin/users', resource[:grafana_api_path]), data)
    else
      data[:id] = user[:id]
      send_request 'PUT', format('%s/admin/users/%s/password', resource[:grafana_api_path], user[:id]), password: data.delete(:password)
      send_request 'PUT', format('%s/admin/users/%s/permissions', resource[:grafana_api_path], user[:id]), isGrafanaAdmin: data.delete(:isGrafanaAdmin)
      response = send_request('PUT', format('%s/users/%s', resource[:grafana_api_path], user[:id]), data)
    end

    raise format('Failed to create user %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'

    self.user = nil
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
    save_user
  end

  def destroy
    delete_user
  end

  def exists?
    user
  end
end
