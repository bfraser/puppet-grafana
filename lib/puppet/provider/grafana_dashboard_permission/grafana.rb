# frozen_string_literal: true

require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_dashboard_permission).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana dashboard permissions'

  defaultfor kernel: 'Linux'

  def grafana_api_path
    resource[:grafana_api_path]
  end

  def set_current_organization
    response = send_request 'POST', format('%s/user/using/%s', grafana_api_path, organization[:id])
    return if response.code == '200'

    raise format('Failed to switch to org %s (HTTP response: %s/%s)', organization[:id], response.code, response.body)
  end

  def raise_on_error(code, message)
    raise message if code != '200'
  end

  def parse_response(data)
    JSON.parse(data)
  rescue JSON::ParserError
    raise format('Fail to parse response: %s', response.body)
  end

  def map_organizations(ids)
    ids.map do |id|
      response = send_request 'GET', format('%s/orgs/%s', grafana_api_path, id)
      raise_on_error(response.code, format('Failed to retrieve organization %d (HTTP response: %s/%s)', id, response.code, response.body))

      organization = parse_response(response.body)
      {
        id: organization['id'],
        name: organization['name']
      }
    end
  end

  def organizations
    response = send_request('GET', format('%s/orgs', grafana_api_path))
    raise_on_error(response.code, format('Fail to retrieve organizations (HTTP response: %s/%s)', response.code, response.body))
    organizations = JSON.parse(response.body)
    map_organizations(organizations.map { |x| x['id'] })
  end

  def organization
    return @organization if @organization

    org = resource[:organization]
    key = org.is_a?(Numeric) || org.match(%r{/^[0-9]*$/}) ? :id : :name
    @organization = organizations.find { |x| x[key] == org }
  end

  def map_teams(teams)
    teams['teams'].map do |team|
      {
        id: team['id'],
        name: team['name'],
        organization: team['orgId'],
        membercount: team['membercount'],
        permission: team['permission'],
        email: team['email']
      }
    end
  end

  def teams
    raise(format('Unknown Organization: %s', resource[:organization])) unless organization

    set_current_organization
    response = send_request('GET', format('%s/teams/search', grafana_api_path))
    raise_on_error(response.code, format('Fail to retrieve teams (HTTP response: %s/%s)', response.code, response.body))
    teams = parse_response(response.body)
    map_teams(teams)
  end

  def team
    @team ||= teams.find { |x| x[:name] == resource[:team] }
  end

  def send_users_request
    raise(format('Unknown Organization: %s', resource[:organization])) unless organization

    set_current_organization
    response = send_request('GET', format('%s/org/users', grafana_api_path))
    raise_on_error(response.code, format('Fail to retrieve users (HTTP response: %s/%s)', response.code, response.body))
    response.body
  end

  def users
    users = parse_response(send_users_request)
    users.map do |user|
      {
        id: user['userId'],
        name: user['login'],
        organization: user['orgId'],
        role: user['role']
      }
    end
  end

  def user
    @user ||= users.find { |x| x[:name] == resource[:user] }
  end

  def dashboards
    set_current_organization
    search_path = { query: resource[:dashboard], type: 'dash-db' }
    response = send_request('GET', format('%s/search', grafana_api_path), nil, search_path)
    raise_on_error(response.code, format('Fail to retrieve dashboards (HTTP response: %s/%s)', response.code, response.body))
    dashboards = parse_response(response.body)
    dashboards.map do |dashboard|
      {
        id: dashboard['id'],
        name: dashboard['title']
      }
    end
  end

  def dashboard
    @dashboard ||= dashboards.find { |x| x[:name] == resource[:dashboard] }
  end

  def permissions
    return @permissions if @permissions
    raise(format('Unknown dashboard: %s', resource[:dashboard])) unless dashboard

    response = send_request('GET', format('%s/dashboards/id/%s/permissions', grafana_api_path, dashboard[:id]))
    raise_on_error(response.code, format('Failed to retrieve permissions on dashboard (HTTP response: %s/%s)', response.code, response.body))
    permissions = parse_response(response.body)
    @permissions = permissions.map do |permission|
      {
        dashboardId: permission['dashboardId'],
        userId: permission['userId'],
        user: permission['userLogin'],
        teamId: permission['teamId'],
        team: permission['team'],
        permissionId: permission['permission'],
        permission: permission['permissionName'],
        dashboard: permission['title'],
        isFolder: permission['isFolder'],
        inherited: permission['inherited']
      }
    end
  end

  def team_permission
    raise(format('Unknown team: %s for organaization: %s', resource[:team], resource[:organization])) unless team

    @team_permission ||= permissions.find { |x| x[:teamId] == team[:id] }
  end

  def user_permission
    raise(format('Unknown user: %s for organaization: %s', resource[:user], resource[:organization])) unless user

    @user_permission ||= permissions.find { |x| x[:userId] == user[:id] }
  end

  def permission
    resource[:user] ? user_permission[:permission] : team_permission[:permission]
  end

  def permission=(value)
    case value
    when 'View'
      resource[:permission] = 1
    when 'Edit'
      resource[:permission] = 2
    when 'Admin'
      resource[:permission] = 4
    end
    save_permission
  end

  def new_permission
    key = resource[:user] ? :userId : :teamId
    subject_id = resource[:user] ? user[:id] : team[:id]
    permission = case resource[:permission] # rubocop:disable Style/HashLikeCase
                 when :View
                   1
                 when :Edit
                   2
                 when :Admin
                   4
                 end
    raise(format('User or Team must exist')) unless subject_id

    {
      key => subject_id,
      'permission' => permission
    }
  end

  def remove_unneeded_permissions(obj)
    obj.delete_if { |k| k['dashboardId'] == -1 }
    new_target = resource[:user] || resource[:team]
    new_type = resource[:user] ? :user : :team
    obj.delete_if { |k| k[new_type] == new_target }
    obj.delete_if { |k| k[:teamId].zero? && k[:userId].zero? }
  end

  def existing_permissions
    perms = remove_unneeded_permissions(permissions)
    perms.map do |perm|
      target = perm[:userId].zero? ? perm[:teamId] : perm[:userId]
      type = perm[:userId].zero? ? :teamId : :userId
      {
        type => target,
        :permission => perm[:permissionId]
      }
    end
  end

  def permission_data(destroy = false)
    raise format('Unknown dashboard: %s', resource[:dashboard]) unless dashboard

    endpoint = format('%s/dashboards/id/%s/permissions', grafana_api_path, dashboard[:id])

    final_permissions = destroy ? { items: existing_permissions } : { items: existing_permissions + [new_permission] }
    ['POST', endpoint, final_permissions]
  end

  def save_permission
    response = send_request(*permission_data)
    raise_on_error(response.code, format('Failed to update membership %s, (HTTP response: %s/%s)', resource, response.code, response.body))
  end

  def create
    save_permission
  end

  def destroy
    response = send_request(*permission_data(true))
    raise_on_error(response.code, format('Failed to update membership %s, (HTTP response: %s/%s)', resource, response.code, response.body))
  end

  def exists?
    raise('user or team parameter must be present') unless resource[:user] || resource[:team]

    resource[:user] ? user_permission : team_permission
  end
end
