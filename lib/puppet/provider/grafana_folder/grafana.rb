require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_folder).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana folders stored into Grafana'

  defaultfor kernel: 'Linux'

  def organization
    resource[:organization]
  end

  def grafana_api_path
    resource[:grafana_api_path]
  end

  def permissions
    find_folder unless @folder
    response = send_request('GET', format('%s/folders/%s/permissions', resource[:grafana_api_path], @folder['uid']))

    if response.code != '200'
      raise format('Failed to retrieve permissions %s (HTTP response: %s/%s)', resource[:title], response.code, response.body)
    end
    begin
      permissions = JSON.parse(response.body)
    rescue JSON::ParserError
      raise format('Fail to parse permissions (HTTP response: %s/%s)', response.code, response.body)
    end
    parsed_permissions = []
    # These are the only configurable keys, many others are returned
    keep_keys = %w[permission role teamId userId]
    permissions.each do |permission|
      parsed_permission = {}
      permission.each_pair do |key, value|
        parsed_permission[key] = value if keep_keys.include?(key) && value != 0
      end
      parsed_permissions << parsed_permission unless parsed_permission.empty?
    end
    parsed_permissions
  end

  def permissions=(value)
    save_permissions(value)
  end

  def fetch_organizations
    response = send_request('GET', format('%s/orgs', resource[:grafana_api_path]))
    if response.code != '200'
      raise format('Fail to retrieve organizations (HTTP response: %s/%s)', response.code, response.body)
    end

    begin
      fetch_organizations = JSON.parse(response.body)

      fetch_organizations.map { |x| x['id'] }.map do |id|
        response = send_request 'GET', format('%s/orgs/%s', resource[:grafana_api_path], id)
        if response.code != '200'
          raise format('Failed to retrieve organization %d (HTTP response: %s/%s)', id, response.code, response.body)
        end

        fetch_organization = JSON.parse(response.body)

        {
          id: fetch_organization['id'],
          name: fetch_organization['name']
        }
      end
    rescue JSON::ParserError
      raise format('Failed to parse response: %s', response.body)
    end
  end

  def fetch_organization
    unless @fetch_organization
      @fetch_organization =
        if resource[:organization].is_a?(Numeric) || resource[:organization].match(%r{^[0-9]*$})
          fetch_organizations.find { |x| x[:id] == resource[:organization] }
        else
          fetch_organizations.find { |x| x[:name] == resource[:organization] }
        end
    end
    @fetch_organization
  end

  def folders
    response = send_request('GET', format('%s/folders', resource[:grafana_api_path]))
    if response.code != '200'
      raise format('Fail to retrieve the folders (HTTP response: %s/%s)', response.code, response.body)
    end

    begin
      @folders = JSON.parse(response.body)
    rescue JSON::ParserError
      raise format('Fail to parse folders (HTTP response: %s/%s)', response.code, response.body)
    end
  end

  def find_folder
    folders unless @folders

    @folders.each do |folder|
      @folder = folder if folder['title'] == resource[:title]
    end
  end

  def save_folder(folder)
    response = send_request 'POST', format('%s/user/using/%s', resource[:grafana_api_path], fetch_organization[:id])
    unless response.code == '200'
      raise format('Failed to switch to org %s (HTTP response: %s/%s)', fetch_organization[:id], response.code, response.body)
    end

    # if folder exists, update object based on uid
    # else, create object
    if @folder.nil?
      data = {
        title: resource[:title],
        uid: resource[:uid]
      }

      response = send_request('POST', format('%s/folders', resource[:grafana_api_path]), data)
      if (response.code != '200') && (response.code != '412')
        raise format('Failed to create folder %s (HTTP response: %s/%s)', resource[:title], response.code, response.body)
      end
      folders
      find_folder
      save_permissions(resource[:permissions])
    else
      data = {
        folder: folder.merge('title' => resource[:title],
                             'uid' => @folder['uid']),
        overwrite: !@folder.nil?
      }

      response = send_request('POST', format('%s/folders/%s', resource[:grafana_api_path], @folder['uid']), data)
      return unless (response.code != '200') && (response.code != '412')
      raise format('Failed to update folder %s (HTTP response: %s/%s)', resource[:title], response.code, response.body)
    end
  end

  def save_permissions(value)
    return if value.nil?
    response = send_request 'POST', format('%s/user/using/%s', resource[:grafana_api_path], fetch_organization[:id])
    unless response.code == '200'
      raise format('Failed to switch to org %s (HTTP response: %s/%s)', fetch_organization[:id], response.code, response.body)
    end
    find_folder unless @folder
    data = { 'items' => value }
    response = send_request 'POST', format('%s/folders/%s/permissions', resource[:grafana_api_path], @folder['uid']), data
    return if response.code == '200'
    raise format('Failed to update permissions %s (HTTP response: %s/%s)', fetch_organization[:id], response.code, response.body)
  end

  def slug
    resource[:title].downcase.gsub(%r{[ \+]+}, '-').gsub(%r{[^\w\- ]}, '')
  end

  def create
    save_folder(resource)
  end

  def destroy
    find_folder unless @folder

    response = send_request('DELETE', format('%s/folders/%s', resource[:grafana_api_path], @folder['uid']))

    return unless response.code != '200'
    raise Puppet::Error, format('Failed to delete folder %s (HTTP response: %s/%s)', resource[:title], response.code, response.body)
  end

  def exists?
    folders unless @folders

    @folders.each do |folder|
      return true if folder['title'] == resource[:title]
    end
    false
  end
end
