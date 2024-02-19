# frozen_string_literal: true

require 'json'
require 'erb'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_organization).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana organizations'

  # https://grafana.com/docs/grafana/latest/http_api/org/#get-organization-by-name
  def get_org_by_name(org_name)
    response = send_request('GET', format('%s/orgs/name/%s', resource[:grafana_api_path], ERB::Util.url_encode(org_name)))

    case response.code
    when '404'
      org = nil
    when '200'
      org = JSON.parse(response.body)
    else
      raise format('Failed to retrieve organization %s (HTTP response: %s/%s)', org_name, response.code, response.body)
    end

    org
  end

  def organization
    @organization ||= get_org_by_name(resource[:name])
    @organization
  end

  attr_writer :organization

  def create
    response = send_request('POST', format('%s/orgs', resource[:grafana_api_path]), { name: resource[:name] })

    raise format('Failed to create organization %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'
  end

  def destroy
    response = send_request 'DELETE', format('%s/orgs/%s', resource[:grafana_api_path], organization['id'])

    raise format('Failed to delete organization %s (HTTP response: %s/%s)', resource[:name], response.code, response.body) if response.code != '200'

    self.organization = nil
  end

  def exists?
    organization
  end
end
