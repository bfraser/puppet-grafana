# frozen_string_literal: true

require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_membership).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana memberships'

  defaultfor kernel: 'Linux'

  def map_organizations(ids)
    ids.map do |id|
      response = send_request 'GET', format('%s/orgs/%s', resource[:grafana_api_path], id)
      raise_on_error(response.code, format('Failed to retrieve organization %d (HTTP response: %s/%s)', id, response.code, response.body))

      organization = parse_response(response.body)
      {
        id: organization['id'],
        name: organization['name']
      }
    end
  end

  def organizations
    response = send_request('GET', format('%s/orgs', resource[:grafana_api_path]))
    raise_on_error(response.code, format('Fail to retrieve organizations (HTTP response: %s/%s)', response.code, response.body))
    organizations = JSON.parse(response.body)
    map_organizations(organizations.map { |x| x['id'] })
  end

  def organization
    return @organization if @organization

    org = resource[:membership_type] == :organization ? resource[:target_name] : resource[:organization]
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
    return {} unless organization

    set_current_organization
    response = send_request('GET', format('%s/teams/search', resource[:grafana_api_path]))
    raise_on_error(response.code, format('Fail to retrieve teams (HTTP response: %s/%s)', response.code, response.body))
    teams = parse_response(response.body)
    map_teams(teams)
  end

  def team
    @team ||= teams.find { |x| x[:name] == resource[:target_name] }
  end

  def map_team_members(members)
    members.map do |member|
      {
        id: member['userId'],
        target_name: member['teamId'],
        organization: member['orgId']
      }
    end
  end

  def team_members
    response = send_request('GET', format('%s/teams/%s/members', resource[:grafana_api_path], @team[:id]))
    raise_on_error(response.code, format('Fail to retrieve teams (HTTP response: %s/%s)', response.code, response.body))
    members = parse_response(response.body)
    members ? map_team_members(members) : []
  end

  def team_member
    @team_member ||= team_members.find { |x| x[:id] == @user[:id] }
  end

  def raise_on_error(code, message)
    raise message if code != '200'
  end

  def grafana_api_path
    resource[:grafana_api_path]
  end

  def parse_response(data)
    JSON.parse(data)
  rescue JSON::ParserError
    raise format('Fail to parse response: %s', response.body)
  end

  def send_users_request
    return '[]' unless organization

    set_current_organization
    response = send_request('GET', format('%s/org/users', grafana_api_path))
    raise_on_error(response.code, format('Fail to retrieve users (HTTP response: %s/%s)', response.code, response.body))
    response.body
  end

  def map_users(users)
    users.map do |user|
      {
        id: user['userId'],
        name: user['login'],
        organization: user['orgId'],
        role: user['role']
      }
    end
  end

  def users
    users = parse_response(send_users_request)
    map_users(users)
  end

  def user
    @user ||= users.find { |x| x[:name] == resource[:user_name] }
  end

  def set_current_organization
    response = send_request 'POST', format('%s/user/using/%s', resource[:grafana_api_path], organization[:id])
    return if response.code == '200'

    raise format('Failed to switch to org %s (HTTP response: %s/%s)', organization[:id], response.code, response.body)
  end

  def role
    user unless @user
    return @user[:role] if @user

    nil
  end

  def role=(value)
    resource[:role] = value
    save_membership
  end

  def save_membership
    send(format('save_membership_%s', resource[:membership_type]))
  end

  def check_org_team_and_user_exist
    raise(format('Unknown organization: %s', resource[:organization])) unless organization

    set_current_organization
    raise('Unknown team or user') unless team && user
  end

  def save_membership_team
    check_org_team_and_user_exist
    endpoint = format('%s/teams/%s/members', resource[:grafana_api_path], @team[:id])
    response = send_request('POST', endpoint, userId: @user[:id])
    raise_on_error(response.code, format('Failed to update membership %s, (HTTP response: %s/%s)', resource, response.code, response.body))
  end

  def setup_save_mem_org_data
    verb = 'POST'
    endpoint = format('%s/org/users', resource[:grafana_api_path])
    request_data = {
      role: resource[:role],
      loginOrEmail: resource[:user_name]
    }
    if exists?
      verb = 'PATCH'
      endpoint = format('%s/org/users/%s', resource[:grafana_api_path], @user[:id])
    end
    [verb, endpoint, request_data]
  end

  def save_membership_organization
    set_current_organization
    response = send_request(*setup_save_mem_org_data)
    raise_on_error(response.code, format('Failed to update membership %s, (HTTP response: %s/%s)', resource, response.code, response.body))
  end

  def create
    save_membership
  end

  def setup_destroy_data
    if resource[:membership_type] == :organization
      endpoint = format('%s/org/users/%s', resource[:grafana_api_path], @user[:id])
    else # team
      team unless @team
      endpoint = format('%s/teams/%s/members/%s', resource[:grafana_api_path], @team[:id], @user[:id])
    end
    ['DELETE', endpoint]
  end

  def destroy_team_membership
    return unless user && organization && team

    endpoint = format('%s/teams/%s/members/%s', resource[:grafana_api_path], @team[:id], @user[:id])
    response = send_request('DELETE', endpoint)
    raise_on_error(response.code, format('Failed to delete team membership (HTTP response: %s/%s)', response.code, response.body))
  end

  def destroy_organization_membership
    return unless user && organization

    endpoint = format('%s/org/users/%s', resource[:grafana_api_path], @user[:id])
    response = send_request('DELETE', endpoint)
    raise_on_error(response.code, format('Failed to delete organization membership (HTTP response: %s/%s)', response.code, response.body))
  end

  def destroy
    set_current_organization
    resource[:membership_type] == :organization ? destroy_organization_membership : destroy_team_membership
  end

  def user_in_organization?
    organization
    return true if @user && @organization && @user[:organization] == @organization[:id]

    false
  end

  def user_in_team?
    team_member if team
    return true if @user && @team && @team_member

    false
  end

  def exists?
    user
    resource[:membership_type] == :organization ? user_in_organization? : user_in_team?
  end
end
