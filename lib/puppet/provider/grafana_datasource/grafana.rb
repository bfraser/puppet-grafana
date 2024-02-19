# frozen_string_literal: true

#    Copyright 2015 Mirantis, Inc.
#
require 'json'
require 'erb'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_datasource).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana datasources'

  defaultfor kernel: 'Linux'

  def organization
    resource[:organization]
  end

  def grafana_api_path
    resource[:grafana_api_path]
  end

  def fetch_organizations
    response = send_request('GET', format('%s/orgs', resource[:grafana_api_path]))
    raise format('Fail to retrieve organizations (HTTP response: %s/%s)', response.code, response.body) if response.code != '200'

    begin
      fetch_organizations = JSON.parse(response.body)
      fetch_organizations.map { |x| x['id'] }.map do |id|
        response = send_request 'GET', format('%s/orgs/%s', resource[:grafana_api_path], id)
        raise format('Failed to retrieve organization %d (HTTP response: %s/%s)', id, response.code, response.body) if response.code != '200'

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
    @fetch_organization ||= if resource[:organization].is_a?(Numeric) || resource[:organization].match(%r{^[0-9]*$})
                              fetch_organizations.find { |x| x[:id] == resource[:organization] }
                            else
                              fetch_organizations.find { |x| x[:name] == resource[:organization] }
                            end
    @fetch_organization
  end

  def datasource_by_name
    response = send_request('GET', format('%s/datasources/name/%s', resource[:grafana_api_path], ERB::Util.url_encode(resource[:name])))
    return nil if response.code == '404'

    raise Puppet::Error, format('Failed to retrieve datasource %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'

    begin
      JSON.parse(response.body).transform_values do |v|
        case v
        when true
          :true
        when false
          :false
        else
          v
        end
      end
    rescue JSON::ParserError
      raise format('Failed to parse response: %s', response.body)
    end
  end

  def datasource
    @datasource ||= datasource_by_name
    @datasource
  end

  attr_writer :datasource

  # Create setters for all properties just so they exist
  mk_resource_methods # Creates setters for all properties

  # Then override all of the getters
  def type
    datasource['type']
  end

  def url
    datasource['url']
  end

  def access_mode
    datasource['access']
  end

  def database
    datasource['database']
  end

  def user
    datasource['user']
  end

  def password
    datasource['password']
  end

  # rubocop:disable Naming/PredicateName
  def is_default
    datasource['isDefault']
  end

  # rubocop:enable Naming/PredicateName

  def basic_auth
    datasource['basicAuth']
  end

  def basic_auth_user
    datasource['basicAuthUser']
  end

  def basic_auth_password
    datasource['basicAuthPassword']
  end

  def with_credentials
    datasource['withCredentials']
  end

  def json_data
    datasource['jsonData']
  end

  def id
    datasource['id']
  end

  def uid
    datasource['uid']
  end

  def secure_json_data
    # The API never returns `secure` data, so we won't ever be able to tell if the current state is correct.
    # TODO: Figure this out!!
    {}
  end

  def flush
    return if resource['ensure'] == :absent

    # change organizations
    response = send_request 'POST', format('%s/user/using/%s', resource[:grafana_api_path], fetch_organization[:id])
    raise format('Failed to switch to org %s (HTTP response: %s/%s)', fetch_organization[:id], response.code, response.body) unless response.code == '200'

    # Build the `data` to POST/PUT by first creating a hash with some defaults which will be used if we're _creating_ a datasource
    data = {
      access: :direct,
      isDefault: false,
      basicAuth: false,
      withCredentials: false,
    }

    # If we're updating a datasource, merge in the current state (overwriting the defaults above)
    unless datasource.nil?
      data.merge!(datasource.transform_keys(&:to_sym).slice(
                    :access,
                    :basicAuth,
                    :basicAuthUser,
                    :basicAuthPassword,
                    :database,
                    :isDefault,
                    :jsonData,
                    :type,
                    :url,
                    :user,
                    :password,
                    :withCredentials,
                    :uid
                  ))
    end

    # Finally, merge in the properies the user has specified
    data.merge!(
      {
        name: resource['name'],
        access: resource['access_mode'],
        basicAuth: resource['basic_auth'],
        basicAuthUser: resource['basic_auth_user'],
        basicAuthPassword: resource['basic_auth_password'],
        database: resource['database'],
        isDefault: resource['is_default'],
        jsonData: resource['json_data'],
        type: resource['type'],
        url: resource['url'],
        user: resource['user'],
        password: resource['password'],
        withCredentials: resource['with_credentials'],
        secureJsonData: resource['secure_json_data'],
        uid: resource['uid']
      }.compact
    )

    # Puppet properties need to work with symbols, but the Grafana API will want to receive actual Booleans
    data.transform_values! do |v|
      case v
      when :true
        true
      when :false
        false
      else
        v
      end
    end

    if datasource.nil?
      Puppet.debug 'Creating datasource'
      response = send_request('POST', format('%s/datasources', resource[:grafana_api_path]), data)
    elsif uid.nil?
      # This API call is deprecated in Grafana 9 so we only use it if our datasource doesn't have a uid (eg Grafana 6)
      Puppet.debug 'Updating datasource by id'
      response = send_request 'PUT', format('%s/datasources/%s', resource[:grafana_api_path], id), data
    else
      Puppet.debug 'Updating datasource by uid'
      response = send_request 'PUT', format('%s/datasources/uid/%s', resource[:grafana_api_path], uid), data
    end

    raise format('Failed to create/update %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'

    self.datasource = nil
  end

  def delete_datasource
    response = send_request 'DELETE', format('%s/datasources/name/%s', resource[:grafana_api_path], ERB::Util.url_encode(resource[:name]))

    raise format('Failed to delete datasource %s (HTTP response: %s/%s', resource[:name], response.code, response.body) if response.code != '200'

    self.datasource = nil
  end

  def create
    # There's no sensible default for `type` when creating a new datasource so perform some validation here
    # The actual creation happens when `flush` gets called.
    raise Puppet::Error, 'type is required when creating a new datasource' if resource[:type].nil?
  end

  def destroy
    delete_datasource
  end

  def exists?
    datasource
  end
end
