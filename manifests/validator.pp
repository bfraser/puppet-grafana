# @summary Manage grafana_conn_validator resource
#
# @param grafana_url
#   Grafana URL.
# @param grafana_api_path
#   API path to validate with.
#
class grafana::validator (
  Stdlib::HTTPUrl $grafana_url = 'http://localhost:3000',
  Stdlib::Absolutepath $grafana_api_path = '/api/health',
) {
  grafana_conn_validator { 'grafana':
    grafana_url      => $grafana_url,
    grafana_api_path => $grafana_api_path,
  }
}
