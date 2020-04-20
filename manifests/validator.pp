# == Class: grafana::validator
#
# Includes `` resource
#
# === Parameters
# [*grafana_url*]
# Grafana URL.
#
# [*grafana_api_path*]
# API path to validate with.
#
# === Examples
#
#  include grafana::validator
#
class grafana::validator (
  String[1] $grafana_url = 'http://localhost:3000',
  String[1] $grafana_api_path = '/api/health',
) {

  grafana_conn_validator { 'grafana':
    grafana_url      => $grafana_url,
    grafana_api_path => $grafana_api_path,
  }
}
