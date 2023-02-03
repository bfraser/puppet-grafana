#
# @summary Installs and configures Grafana.
#
# @param archive_source Download location of tarball to be used with the 'archive' install method.
#   Defaults to the URL of the latest version of Grafana available at the time of module release.
#
# @param container_cfg Determines whether a configuration file should be generated when using the 'docker' install method.
#   If true, use the `cfg` and `cfg_location` parameters to control creation of the file.
#   Defaults to false.
#
# @param container_params Hash of parameters to use when creating the Docker container. For use with the 'docker' install method.
#   Refer to documentation of the `docker::run` resource in the `garethr-docker` module for details of available parameters.
#   Defaults to:
#
#   container_params => {
#     'image' => 'grafana/grafana:latest',
#     'ports' => '3000'
#   }
#
# @param data_dir The directory Grafana will use for storing its data.
#   Defaults to '/var/lib/grafana'.
#
# @param install_dir Installation directory to be used with the 'archive' install method.
#   Defaults to '/usr/share/grafana'.
#
# @param install_method Set to 'archive' to install Grafana using the tar archive.
#   Set to 'docker' to install Grafana using the official Docker container.
#   Set to 'package' to install Grafana using .deb or .rpm packages.
#   Set to 'repo' to install Grafana using an apt or yum repository.
#   Defaults to 'package'.
#
# @param manage_package_repo If true this will setup the official grafana repositories on your host. Defaults to true.
#
# @param package_name The name of the package managed with the 'package' install method.
#   Defaults to 'grafana'.
#
# @param package_source Download location of package to be used with the 'package' install method.
#   Defaults to the URL of the latest version of Grafana available at the time of module release.
#
# @param service_name The name of the service managed with the 'archive' and 'package' install methods.
#   Defaults to 'grafana-server'.
#
# @param version The version of Grafana to install and manage.
#   Defaults to 'installed'
#
# @param repo_name When using 'repo' install_method, the repo to look for packages in.
#   Set to 'stable' to install only stable versions
#   Set to 'beta' to install beta versions
#   Set to 'custom' to install from custom repo. Use full URL
#   Defaults to stable.
#
# @param repo_gpg_key_url When using 'repo' install_method, the repo_gpg_key_url to look for the gpg signing key of the repo.
#   Defaults to https://packages.grafana.com/gpg.key.
#
# @param repo_key_id When using 'repo' install_method, the repo_key_id of the repo_gpg_key_url key on Debian based systems.
#   Defaults to 0E22EB88E39E12277A7760AE9E439B102CF3C0C6.
#
# @param repo_release Optional value, needed on Debian based systems.
#   If repo name is set to custom, used to identify the release of the repo. No default value.
# @param repo_url When using 'repo' install_method, the repo_url to look for packages in.
#   Set to a custom string value to install from a custom repo. Defaults to https://packages.grafana.com/oss/OS_SPECIFIC_SLUG_HERE.
#
# @param plugins A hash of plugins to be passed to `create_resources`, wraps around the
#   `grafana_plugin` resource.
#
# @param provisioning_dashboards Hash of dashboards to provision into grafana. grafana > v5.0.0
#   required. Hash will be converted into YAML and used by grafana to
#   provision dashboards.
#
# @param provisioning_datasources Hash of datasources to provision into grafana, grafana > v5.0.0
#   required. Hash will be converted into YAML and used by granfana to
#   configure datasources.
#
# @param provisioning_dashboards_file String with the fully qualified path to place the provisioning file
#   for dashboards, only used if provisioning_dashboards is specified.
#   Defaults to '/etc/grafana/provisioning/dashboards/puppetprovisioned.yaml'
#
# @param provisioning_datasources_file String with the fully qualified path to place the provisioning file
#   for datasources, only used if provisioning_datasources is specified.
#   Default to '/etc/grafana/provisioning/datasources/puppetprovisioned.yaml'
#
# @param create_subdirs_provisioning Boolean, defaults to false. If true puppet will create any
#   subdirectories in the given path when provisioning dashboards.
#
# @param sysconfig_location Location of the sysconfig file for the environment of the grafana-server service.
#   This is only used when the install_method is 'package' or 'repo'.
#
# @param sysconfig A hash of environment variables for the grafana-server service
#
#   Example:
#     sysconfig => { 'http_proxy' => 'http://proxy.example.com/' }
#
# @param ldap_servers A hash of ldap_servers to be passed to `create_resources`, wraps around the
#   `grafana_ldap_server` resource.
#
# @param ldap_group_mappings A hash of ldap_servers to be passed to `create_resources`, wraps around the
#   `grafana_ldap_group_mapping` resource.
#
# @param toml_manage_package ruby-toml is required to generate the TOML-based LDAP config for Grafana.
#   Defaults to true. Set to false if you manage package- or gem-install
#   somewhere else.
#
# @param toml_package_name Name of the software-package providing the TOML parser library.
#   Defaults to ruby-toml.
#
# @param toml_package_ensure Ensure the package-resource - e.g. installed, absent, etc.
#   https://puppet.com/docs/puppet/latest/types/package.html#package-attribute-ensure
#   Defaults to present
#
# @param toml_package_provider The package-provider used to install the TOML parser library.
#   Defaults to undef, to let Puppet decide. See
#   https://puppet.com/docs/puppet/latest/types/package.html#package-attribute-provider
#
# @example Using the Class
#  class { '::grafana':
#    install_method  => 'docker',
#  }
#
class grafana (
  Optional[String] $archive_source,
  String $cfg_location,
  Variant[Hash,Sensitive[Hash]] $cfg,
  Optional[Variant[Hash,Array[Hash],Sensitive[Hash],Sensitive[Array[Hash]]]] $ldap_cfg,
  Boolean $container_cfg,
  Hash $container_params,
  String $docker_image,
  String $docker_ports,
  String $data_dir,
  String $install_dir,
  String $install_method,
  Boolean $manage_package_repo,
  String $package_name,
  Optional[String] $package_source,
  Enum['stable', 'beta', 'custom'] $repo_name,
  Optional[String[1]] $repo_key_id,
  Optional[String[1]] $repo_release,
  Optional[Stdlib::HTTPUrl] $repo_url,
  String $rpm_iteration,
  String $service_name,
  String $version,
  Hash $plugins,
  Hash $provisioning_dashboards,
  Hash $provisioning_datasources,
  String $provisioning_dashboards_file,
  String $provisioning_datasources_file,
  Boolean $create_subdirs_provisioning,
  Optional[String] $sysconfig_location,
  Optional[Hash] $sysconfig,
  Hash[String[1], Hash] $ldap_servers,
  Hash[String[1], Hash] $ldap_group_mappings,
  Boolean $toml_manage_package,
  String[1] $toml_package_name,
  String[1] $toml_package_ensure,
  Optional[String[1]] $toml_package_provider,
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
