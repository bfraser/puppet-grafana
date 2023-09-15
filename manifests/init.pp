#
# @summary Installs and configures Grafana.
#
# @param archive_source
#   Download location of tarball to be used with the 'archive' install method.
#
# @param cfg_location
#   Location of the configuration file.
#
# @param ldap_cfg
#
# @param container_cfg
#   Determines whether a configuration file should be generated when using the 'docker' install method.
#   If true, use the `cfg` and `cfg_location` parameters to control creation of the file.
#
# @param container_params
#   Parameters to use when creating the Docker container. For use with the 'docker' install method.
#   Refer to documentation of the `docker::run` resource in the `garethr-docker` module for details of available parameters.
#
# @param data_dir
#   The directory Grafana will use for storing its data.
#
# @param install_dir
#   Installation directory to be used with the 'archive' install method.
#
# @param install_method
#   Set to 'archive' to install Grafana using the tar archive.
#   Set to 'docker' to install Grafana using the official Docker container.
#   Set to 'package' to install Grafana using .deb or .rpm packages.
#   Set to 'repo' to install Grafana using an apt or yum repository.
#
# @param manage_package_repo
#   If true this will setup the official grafana repositories on your host.
#
# @param package_name
#   The name of the package managed with the 'package' install method.
#
# @param package_source
#   Download location of package to be used with the 'package' install method.
#
# @param service_name
#   The name of the service managed with the 'archive' and 'package' install methods.
#
# @param version
#   The version of Grafana to install and manage.
#
# @param repo_name
#   When using 'repo' install_method, the repo to look for packages in.
#   Set to 'stable' to install only stable versions
#   Set to 'beta' to install beta versions
#   Set to 'custom' to install from custom repo. Use full URL
#
# @param repo_gpg_key_url
#   When using 'repo' install_method, the repo_gpg_key_url to look for the gpg signing key of the repo.
#
# @param repo_key_id
#   When using 'repo' install_method, the repo_key_id of the repo_gpg_key_url key on Debian based systems.
#
# @param repo_release
#   Optional value, needed on Debian based systems.
#   If repo name is set to custom, used to identify the release of the repo. No default value.
#
# @param repo_url
#   When using 'repo' install_method, the repo_url to look for packages in.
#   Set to a custom string value to install from a custom repo.
#
# @param plugins
#   Plugins to be passed to `create_resources`, wraps around the
#   `grafana_plugin` resource.
#
# @param provisioning_dashboards
#   Dashboards to provision into grafana. grafana > v5.0.0
#   required. Will be converted into YAML and used by grafana to
#   provision dashboards.
#
# @param provisioning_datasources
#   Datasources to provision into grafana, grafana > v5.0.0
#   required. Will be converted into YAML and used by granfana to
#   configure datasources.
#
# @param provisioning_dashboards_file
#   Fully qualified path to place the provisioning file
#   for dashboards, only used if provisioning_dashboards is specified.
#
# @param provisioning_datasources_file
#   Fully qualified path to place the provisioning file
#   for datasources, only used if provisioning_datasources is specified.
#
# @param create_subdirs_provisioning
#   If true puppet will create any
#   subdirectories in the given path when provisioning dashboards.
#
# @param sysconfig_location
#   Location of the sysconfig file for the environment of the grafana-server service.
#   This is only used when the install_method is 'package' or 'repo'.
#
# @param sysconfig
#   Environment variables for the grafana-server service
#
#   Example:
#     sysconfig => { 'http_proxy' => 'http://proxy.example.com/' }
#
# @param ldap_servers
#   Servers to be passed to `create_resources`, wraps around the
#   `grafana_ldap_server` resource.
#
# @param ldap_group_mappings
#   ldap_group_mappings
#   Mappings to be passed to `create_resources`, wraps around the
#   `grafana_ldap_group_mapping` resource.
#
# @param toml_manage_package
#   ruby-toml is required to generate the TOML-based LDAP config for Grafana.
#   Set to false if you manage package- or gem-install
#   somewhere else.
#
# @param toml_package_name
#   Name of the software-package providing the TOML parser library.
#
# @param toml_package_ensure
#   Ensure the package-resource - e.g. installed, absent, etc.
#   https://puppet.com/docs/puppet/latest/types/package.html#package-attribute-ensure
#
# @param toml_package_provider
#   The package-provider used to install the TOML parser library.
#
# @param docker_image
#   name of the docker image that provides grafana
#
# @param docker_ports
#   ports docker should expose
#
# @param rpm_iteration
#   explicit Iteration / epoch for the rpm
#
# @param cfg
#   The whole grafana configuration
#
# @example Using the Class
#  class { '::grafana':
#    install_method  => 'docker',
#  }
#
class grafana (
  String $cfg_location,
  Enum['archive', 'docker', 'package', 'repo'] $install_method,
  Boolean $manage_package_repo,
  String $package_name,
  Optional[Stdlib::HTTPUrl] $repo_url,
  String $service_name,
  Optional[String] $sysconfig_location,
  Optional[String] $archive_source = undef,
  Variant[Hash,Sensitive[Hash]] $cfg = {},
  Optional[Variant[Hash,Array[Hash],Sensitive[Hash],Sensitive[Array[Hash]]]] $ldap_cfg = undef,
  Boolean $container_cfg = false,
  Hash $container_params = {},
  String $docker_image = 'grafana/grafana',
  String $docker_ports = '3000:3000',
  String $data_dir = '/var/lib/grafana',
  String $install_dir = '/usr/share/grafana',
  Optional[String] $package_source = undef,
  Enum['stable', 'beta', 'custom'] $repo_name = 'stable',
  String[1] $repo_key_id = 'B53AE77BADB630A683046005963FA27710458545',
  Optional[String[1]] $repo_release = undef,
  String $rpm_iteration = '1',
  String $version = 'installed',
  Hash $plugins = {},
  Hash $provisioning_dashboards = {},
  Hash $provisioning_datasources = {},
  String $provisioning_dashboards_file = '/etc/grafana/provisioning/dashboards/puppetprovisioned.yaml',
  String $provisioning_datasources_file = '/etc/grafana/provisioning/datasources/puppetprovisioned.yaml',
  Boolean $create_subdirs_provisioning = false,
  Optional[Hash] $sysconfig = undef,
  Hash[String[1], Hash] $ldap_servers = {},
  Hash[String[1], Hash] $ldap_group_mappings = {},
  Boolean $toml_manage_package = true,
  String[1] $toml_package_name = 'ruby-toml',
  String[1] $toml_package_ensure = 'present',
  Optional[String[1]] $toml_package_provider = undef,
  Stdlib::HTTPUrl $repo_gpg_key_url = 'https://packages.grafana.com/gpg.key',
) {
  contain grafana::install
  contain grafana::config
  contain grafana::service

  Class['grafana::install']
  -> Class['grafana::config']
  -> Class['grafana::service']

  create_resources(grafana_plugin, $plugins)
  # Dependency added for Grafana_plugins to ensure it runs at the
  # correct time.
  Class['grafana::config'] -> Grafana_Plugin <| |> ~> Class['grafana::service']

  create_resources('grafana_ldap_server', $ldap_servers)
  create_resources('grafana_ldap_group_mapping', $ldap_group_mappings)
}
