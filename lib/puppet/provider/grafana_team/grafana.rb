# frozen_string_literal: true

require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_team).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana permissions'

  defaultfor kernel: 'Linux'

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
    return [] unless organization

    set_current_organization
    response = send_request('GET', format('%s/teams/search', resource[:grafana_api_path]))
    raise_on_error(response.code, format('Fail to retrieve teams (HTTP response: %s/%s)', response.code, response.body))
    teams = parse_response(response.body)
    map_teams(teams)
  end

  def team
    @team ||= teams.find { |x| x[:name] == resource[:name] }
  end

  def map_preferences(preferences)
    {
      theme: preferences['theme'],
      home_dashboard: preferences['homeDashboardId'],
      timezone: preferences['timezone']
    }
  end

  def preferences
    team unless @team
    return if @preferences

    response = send_request('GET', format('%s/teams/%s/preferences', resource[:grafana_api_path], @team[:id]))
    raise_on_error(response.code, format('Fail to retrieve teams (HTTP response: %s/%s)', response.code, response.body))
    preferences = parse_response(response.body)
    @preferences = map_preferences(preferences)
  end

  def setup_save_preferences_data
    endpoint = format('%s/teams/%s/preferences', resource[:grafana_api_path], @team[:id])
    dash = get_dashboard(resource[:home_dashboard], resource[:home_dashboard_folder])
    request_data = {
      theme: resource[:theme],
      homeDashboardId: dash[:id],
      timezone: resource[:timezone]
    }
    ['PUT', endpoint, request_data]
  end

  def save_preferences
    team unless @team
    set_current_organization
    setup_save_preferences_data
    response = send_request(*setup_save_preferences_data)
    # TODO: Raise on error?
    return if response.code == '200' || response.code == '412'

    raise format('Failed to update team %s, (HTTP response: %s/%s)', resource, response.code, response.body)
  end

  def set_current_organization
    response = send_request 'POST', format('%s/user/using/%s', resource[:grafana_api_path], organization[:id])
    return if response.code == '200'

    raise format('Failed to switch to org %s (HTTP response: %s/%s)', organization[:id], response.code, response.body)
  end

  def home_dashboard_folder
    preferences unless @preferences
    dash = get_dashboard(@preferences[:home_dashboard])
    return dash[:folder_name] if dash

    nil
  end

  def home_dashboard_folder=(value)
    resource[:home_dashboard_folder] = value
    save_preferences
  end

  def home_dashboard
    preferences unless @preferences
    dash = get_dashboard(@preferences[:home_dashboard])
    return dash[:name] if dash

    nil
  end

  def home_dashboard=(value)
    resource[:home_dashboard] = value
    save_preferences
  end

  def setup_search_path(ident, folder_id = nil)
    query = if ident.is_a?(Numeric) || ident.match(%r{/^[0-9]*$/})
              {
                dashboardIds: ident,
                type: 'dash-db'
              }
            else
              {
                query: ident,
                type: 'dash-db'
              }
            end
    query[:folderIds] = folder_id unless folder_id.nil?
    query
  end

  def get_dashboard(ident, folder = nil)
    set_current_organization
    return { id: 0, name: 'Default' } if ident == 0 # rubocop:disable Style/NumericPredicate

    folder_id = nil
    folder_id = get_dashboard_folder_id(folder) unless folder.nil?

    search_path = setup_search_path(ident, folder_id)
    response = send_request('GET', format('%s/search', resource[:grafana_api_path]), nil, search_path)
    raise_on_error(response.code, format('Fail to retrieve dashboars (HTTP response: %s/%s)', response.code, response.body))

    dashboard = parse_response(response.body)
    format_dashboard(dashboard)
  end

  def format_dashboard(dashboard)
    return { id: 0, name: 'Default' } unless dashboard.first

    {
      id: dashboard.first['id'],
      name: dashboard.first['title'],
      folder_uid: dashboard.first['folderUid'],
      folder_name: dashboard.first['folderTitle'],
    }
  end

  def setup_folder_search_path(ident)
    if ident.is_a?(Numeric) || ident.match(%r{/^[0-9]*$/})
      {
        folderIds: ident,
        type: 'dash-folder'
      }
    else
      {
        query: ident,
        type: 'dash-folder'
      }
    end
  end

  def get_dashboard_folder_id(ident)
    return nil if ident.nil?

    set_current_organization
    search_path = setup_folder_search_path(ident)
    response = send_request('GET', format('%s/search', resource[:grafana_api_path]), nil, search_path)
    raise_on_error(response.code, format('Fail to retrieve dashboars (HTTP response: %s/%s)', response.code, response.body))

    dashboard = parse_response(response.body)
    return nil unless dashboard.first

    dashboard.first['id']
  end

  def theme
    preferences unless @preferences
    return @preferences[:theme] if @preferences

    nil
  end

  def theme=(value)
    resource[:theme] = value
    save_preferences
  end

  def timezone
    preferences unless @preferences
    return @preferences[:timezone] if @preferences

    nil
  end

  def timezone=(value)
    resource[:timezone] = value
    save_preferences
  end

  def setup_save_team_data
    verb = 'POST'
    endpoint = format('%s/teams', resource[:grafana_api_path])
    request_data = { name: resource[:name], email: resource[:email] }
    if exists?
      verb = 'PUT'
      endpoint = format('%s/teams/%s', resource[:grafana_api_path], @team[:id])
    end
    [verb, endpoint, request_data]
  end

  def save_team
    set_current_organization
    response = send_request(*setup_save_team_data)
    raise_on_error(response.code, format('Failed to update team %s, (HTTP response: %s/%s)', resource, response.code, response.body))
  end

  def create
    save_team
    save_preferences
  end

  def destroy
    return unless team

    response = send_request('DELETE', format('%s/teams/%s', resource[:grafana_api_path], @team[:id]))
    raise_on_error(response.code, format('Failed to delete team %s (HTTP response: %s/%s)', resource, response.code, response.body))
  end

  def exists?
    team
    return true if @team && @team[:name] == resource[:name]

    false
  end
end
