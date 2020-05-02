require 'net/http'

module Puppet
  module Util
    # Validator class, for testing that Grafana is alive
    class GrafanaConnValidator
      attr_reader :grafana_url
      attr_reader :grafana_api_path

      def initialize(grafana_url, grafana_api_path)
        @grafana_url      = grafana_url
        @grafana_api_path = grafana_api_path
      end

      # Utility method; attempts to make an http/https connection to the Grafana server.
      # This is abstracted out into a method so that it can be called multiple times
      # for retry attempts.
      #
      # @return true if the connection is successful, false otherwise.
      def attempt_connection
        # All that we care about is that we are able to connect successfully via
        # http(s), so here we're simpling hitting a somewhat arbitrary low-impact URL
        # on the Grafana server.
        grafana_host = URI.parse(@grafana_url).host
        grafana_port = URI.parse(@grafana_url).port
        grafana_scheme = URI.parse(@grafana_url).scheme
        http = Net::HTTP.new(grafana_host, grafana_port)
        http.use_ssl = (grafana_scheme == 'https')
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(@grafana_api_path)
        request.add_field('Accept', 'application/json')
        response = http.request(request)

        unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPUnauthorized)
          Puppet.notice "Unable to connect to Grafana server (#{grafana_scheme}://#{grafana_host}:#{grafana_port}): [#{response.code}] #{response.msg}"
          return false
        end
        return true
      rescue Exception => e # rubocop:disable Lint/RescueException
        Puppet.notice "Unable to connect to Grafana server (#{grafana_scheme}://#{grafana_host}:#{grafana_port}): #{e.message}"
        return false
      end
    end
  end
end
