#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
require 'cgi'
require 'json'
require 'net/http'

class Puppet::Provider::Grafana < Puppet::Provider
    # Helper methods
    def grafana_host
        unless @grafana_host
            @grafana_host = URI.parse(resource[:grafana_url]).host
        end
        @grafana_host
    end

    def grafana_port
        unless @grafana_port
            @grafana_port = URI.parse(resource[:grafana_url]).port
        end
        @grafana_port
    end

    def grafana_scheme
        unless @grafana_scheme
            @grafana_scheme = URI.parse(resource[:grafana_url]).scheme
        end
        @grafana_scheme
    end

    # Return a Net::HTTP::Response object
    def send_request(operation="GET", path="", data=nil, search_path={})
        request = nil
        encoded_search = ""

        if URI.respond_to?(:encode_www_form)
            encoded_search = URI.encode_www_form(search_path)
        else
            # Ideally we would have use URI.encode_www_form but it isn't
            # available with Ruby 1.8.x that ships with CentOS 6.5.
            encoded_search = search_path.to_a.map do |x|
                x.map{|y| CGI.escape(y.to_s)}.join('=')
            end
            encoded_search = encoded_search.join('&')
        end
        uri = URI.parse("%s://%s:%d%s?%s" % [
            self.grafana_scheme, self.grafana_host, self.grafana_port,
            path, encoded_search])

        case operation.upcase
        when 'POST'
            request = Net::HTTP::Post.new(uri.request_uri)
            request.body = data.to_json()
        when 'PUT'
            request = Net::HTTP::Put.new(uri.request_uri)
            request.body = data.to_json()
        when 'GET'
            request = Net::HTTP::Get.new(uri.request_uri)
        when 'DELETE'
            request = Net::HTTP::Delete.new(uri.request_uri)
        else
            raise Puppet::Error, "Unsupported HTTP operation '%s'" % operation
        end

        request.content_type = 'application/json'
        if resource[:grafana_user] and resource[:grafana_user]
            request.basic_auth resource[:grafana_user], resource[:grafana_password]
        end

        return Net::HTTP.start(self.grafana_host, self.grafana_port) do |http|
            http.request(request)
        end
    end
end

