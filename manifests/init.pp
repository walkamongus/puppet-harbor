# Harbor Puppet module main class
#
# @summary This class installs and configures Harbor (https://goharbor.io).
#
# @example
#   include harbor
#
# @note For full configuration parameter documentation, see the {https://github.com/goharbor/harbor/blob/master/docs/installation_guide.md Harbor Installation Guide}.
#
# @param version
#   Specifies the Harbor version to install. See available releases at {https://github.com/goharbor/harbor/releases Harbor Releases}
#
# @param installer
#   Specifies which installer type to use. Note that not every release has both installer types available.
#
# @param with_notary
#   Specifies whether to include Notary functionality in the deployment.
#   Defaults to false
#
# @param with_trivy
#   Specifies whether to include Trivy functionality in the deployment.
#   Defaults to false
#
# @param with_clair
#   Specifies whether to include Clair functionality in the deployment.
#   Defaults to false
#
# @param with_chartmuseum
#   Specifies whether to include Helm Chart repository functionality in the deployment.
#   Defaults to false
#
# @param harbor_ha
#   Specifies whether to include high availability functionality in the deployment.
#   Defaults to false
#
# @param download_source
#   Specifies download location for the Harbor installation tar file.
#
# @param checksum
#   Specifies the MD5 checksum for downloaded Harbor installation tar file.
#
# @param hostname
#   The target host's hostname, which is used to access the Portal and the registry service.
#   It should be the IP address or the fully qualified domain name (FQDN) of your target machine.
#   Defaults to facts.fqdn
#
# @param ui_url_protocol
#   http or https.
#   Defaults to http
#
# @param max_job_workers
#   The maximum number of replication workers in job service
#   Defaults to 10
#
# @param absolute_url
#  Change the value of absolute_url to enabled can enable absolute url in chart
#  Defaults to disabled
#
# @param customize_crt
#   When this attribute is on, the prepare script creates private key and root certificate
#   for the generation/verification of the registry's token.
#   Defaults to on
#
# @param ssl_cert
#   The path of SSL certificate,
#
# @param ssl_cert_key
#   The path of SSL key
#
# @param internal_tls
#   Enable internal TLS
#
# @param internal_tls_dir
#   Internal TLS directory
#
# @param internal_tls_days
#   Number of days for internal SSL certificates
#
# @param secretkey_path
#   The path of key for encrypt or decrypt the password of a remote registry in a replication policy.
#
# @param external_url
#
# @param log_level
#  Defaults to 'info'
#
# @param log_rotate_count
#  Defaults to 50
#
# @param log_rotate_size
#  Defaults to 200M
#
# @param log_location
#  Defaults to /var/log/harbor
#
# @param log_external_endpoint
#   Enable external logging
#
# @param log_external_endpoint_protocol
#   External logging protocol
#
# @param log_external_endpoint_host
#   External logging host
#
# @param log_external_endpoint_port
#   External logging port
#
# @param http_proxy
#  Defaults to None
#
# @param https_proxy
#  Defaults to None
#
# @param no_proxy
#  Defaults to None
#
# @param data_volume
#  Defaults to '/data'
#
# @param harbor_admin_password
#   Defaults to Harbor12345
#
# @param db_host
#  Defaults to postgresql
#
# @param db_password
#   Defaults to root123
#
# @param db_port
#   Defaults to 5432
#
# @param db_user
#   Defaults to postgres
#
# @param db_max_idle_connections
#   Defaults to 50
#
# @param db_max_open_conns
#   Defaults to 100
#
# @param external_redis
#   Defaults to false
#
# @param redis_host
#   Defaults to redis
#
# @param redis_port
#   Defaults to 6379
#
# @param redis_password
#   Defaults to None
#
# @param redis_registry_db_index
#
# @param redis_jobservice_db_index
#
# @param redis_chartmuseum_db_index
#
# @param redis_clair_db_index
#
# @param trivy_ignore_unfixed
#
# @param trivy_skip_update
#
# @param trivy_insecure
#
# @param trivy_github_token
#
# @param clair_db_host
#   Defaults to postgresql
#
# @param clair_db_password
#   Defaults to root123
#
# @param clair_db_port
#   Defaults to 5432
#
# @param clair_db_username
#   Defaults to postgres
#
# @param clair_db
#   Defaults to postgres
#
# @param clair_updaters_interval
#
# @param uaa_ca_cert
#
# @param registry_storage_provider_name
#
# @param registry_storage_provider_config
#
# @param registry_custom_ca_bundle
#
# @param reload_config
#
# @param skip_reload_env_pattern
#
# @param webhook_job_max_retry
#
# @param metrics
#   Enable metrics
#
# @param metrics_port
#   Metrics port
#
# @param metrics_path
#   Metrics path
#
# @param backup_enabled
#   Specifies whether to create a backup tar file of the Harbor database if an upgrade is detected
#   Defaults to false
#
# @param backup_directory
#   Specifies the directory in which to store Harbor backup files
#   Defaults to '/tmp'
#
class harbor (
  Pattern[/\d+\.\d+\.\d+.*/] $version,
  Enum['offline','online'] $installer,
  String  $checksum,
  Boolean $external_redis,
  Boolean $with_notary,
  Boolean $with_trivy,
  Boolean $with_clair,
  Boolean $with_chartmuseum,
  Boolean $harbor_ha,
  Stdlib::Host $hostname,
  Enum['http','https'] $ui_url_protocol,
  Integer $max_job_workers,
  Enum['enabled','disabled'] $absolute_url,
  Enum['on','off'] $customize_crt,
  Stdlib::Absolutepath $ssl_cert,
  Stdlib::Absolutepath $ssl_cert_key,
  Boolean $internal_tls,
  Stdlib::Absolutepath $internal_tls_dir,
  Integer $internal_tls_days,
  Stdlib::Absolutepath $secretkey_path,
  Variant[Stdlib::Httpurl,String[0,0]] $external_url,
  Enum['debug','info','warning','error','fatal'] $log_level,
  Integer $log_rotate_count,
  String $log_rotate_size,
  String $log_location,
  Boolean $log_external_endpoint,
  Enum['tcp','udp'] $log_external_endpoint_protocol,
  Stdlib::Host $log_external_endpoint_host,
  Stdlib::Port $log_external_endpoint_port,
  Variant[Stdlib::Httpurl,String[0,0]] $http_proxy,
  Variant[Stdlib::Httpurl,String[0,0]] $https_proxy,
  String $no_proxy,
  String $data_volume,
  String $harbor_admin_password,
  Stdlib::Host $db_host,
  String $db_password,
  Stdlib::Port $db_port,
  String $db_user,
  Integer $db_max_idle_connections,
  Integer $db_max_open_conns,
  Stdlib::Host $redis_host,
  Stdlib::Port $redis_port,
  String $redis_password,
  Integer $redis_registry_db_index,
  Integer $redis_jobservice_db_index,
  Integer $redis_chartmuseum_db_index,
  Integer $redis_clair_db_index,
  Boolean $trivy_ignore_unfixed,
  Boolean $trivy_skip_update,
  Boolean $trivy_insecure,
  Stdlib::Host $clair_db_host,
  String $clair_db_password,
  Stdlib::Port $clair_db_port,
  String $clair_db_username,
  String $clair_db,
  Integer $clair_updaters_interval,
  String $uaa_ca_cert,
  Enum['filesystem','s3','gcs','azure','swift','oss'] $registry_storage_provider_name,
  String $registry_storage_provider_config,
  Variant[Stdlib::Absolutepath,String[0,0]] $registry_custom_ca_bundle,
  Variant[Boolean,String[0,0]] $reload_config,
  String $skip_reload_env_pattern,
  Integer $webhook_job_max_retry,
  Boolean $metrics,
  Stdlib::Port $metrics_port,
  String $metrics_path,
  Boolean $backup_enabled,
  Stdlib::Absolutepath $backup_directory,
  Optional[String] $trivy_github_token = undef,
  Optional[Stdlib::Httpurl] $download_source = undef,
){

  include 'docker'
  include 'docker::compose'

  $_download_source = pick($download_source, "https://github.com/goharbor/harbor/releases/download/v${version}/harbor-${installer}-installer-v${version}.tgz")

  if ! empty($https_proxy) or ! empty($http_proxy) {
    $_proxy_server = pick($https_proxy, $http_proxy)
  } else {
    $_proxy_server = undef
  }

  $_default_no_proxy = '127.0.0.1,localhost,.local,.internal,log,db,redis,nginx,core,portal,postgresql,jobservice,registry,registryctl,clair'
  if ! empty($no_proxy) {
    $_no_proxy = "${_default_no_proxy},${no_proxy}"
  } else {
    $_no_proxy = $_default_no_proxy
  }

  $_versions    = split($version, '\.')
  $_cfg_version = "${_versions[0]}.${_versions[1]}.0"
  if versioncmp($_cfg_version, '1.9.0') < 0 {
    fail('Only Harbor versions >= 1.9.0 are supported by this module')
  }

  if $backup_enabled {
    $harbor_systeminfo = $facts['harbor_systeminfo']
    if !$harbor_systeminfo {
      fail("Backup failed because fact['harbor_systeminfo'] is not available.")
    }

    $complete_running_version = $harbor_systeminfo['harbor_version']
    if !$complete_running_version or empty($complete_running_version) {
      fail("Backup failed because fact['harbor_systeminfo']['harbor_version'] is not available.")
    }

    $shortened_running_version = $complete_running_version.match(/^v(\d+\.\d+\.\d+)/)[1]
    if versioncmp($version, $shortened_running_version) > 0 {
      class { 'harbor::backup':
        version          => $shortened_running_version,
        data_volume      => $data_volume,
        backup_directory => $backup_directory,
        before           => Class['harbor::install'],
      }
      contain 'harbor::backup'
    }
  }

  class { 'harbor::install':
    installer       => $installer,
    version         => $version,
    checksum        => $checksum,
    download_source => $_download_source,
    proxy_server    => $_proxy_server,
  }
  contain 'harbor::install'

  class { 'harbor::config':
    cfg_version                      => $_cfg_version,
    hostname                         => $hostname,
    ui_url_protocol                  => $ui_url_protocol,
    max_job_workers                  => $max_job_workers,
    absolute_url                     => $absolute_url,
    customize_crt                    => $customize_crt,
    ssl_cert                         => $ssl_cert,
    ssl_cert_key                     => $ssl_cert_key,
    internal_tls                     => $internal_tls,
    internal_tls_dir                 => $internal_tls_dir,
    secretkey_path                   => $secretkey_path,
    external_url                     => $external_url,
    log_level                        => $log_level,
    log_rotate_count                 => $log_rotate_count,
    log_rotate_size                  => $log_rotate_size,
    log_location                     => $log_location,
    log_external_endpoint            => $log_external_endpoint,
    log_external_endpoint_protocol   => $log_external_endpoint_protocol,
    log_external_endpoint_host       => $log_external_endpoint_host,
    log_external_endpoint_port       => $log_external_endpoint_port,
    http_proxy                       => $http_proxy,
    https_proxy                      => $https_proxy,
    no_proxy                         => $_no_proxy,
    data_volume                      => $data_volume,
    harbor_admin_password            => $harbor_admin_password,
    db_host                          => $db_host,
    db_password                      => $db_password,
    db_port                          => $db_port,
    db_user                          => $db_user,
    db_max_idle_connections          => $db_max_idle_connections,
    db_max_open_conns                => $db_max_open_conns,
    external_redis                   => $external_redis,
    redis_host                       => $redis_host,
    redis_port                       => $redis_port,
    redis_password                   => $redis_password,
    redis_registry_db_index          => $redis_registry_db_index,
    redis_jobservice_db_index        => $redis_jobservice_db_index,
    redis_chartmuseum_db_index       => $redis_chartmuseum_db_index,
    redis_clair_db_index             => $redis_clair_db_index,
    trivy_ignore_unfixed             => $trivy_ignore_unfixed,
    trivy_skip_update                => $trivy_skip_update,
    trivy_insecure                   => $trivy_insecure,
    trivy_github_token               => $trivy_github_token,
    clair_db_host                    => $clair_db_host,
    clair_db_password                => $clair_db_password,
    clair_db_port                    => $clair_db_port,
    clair_db_username                => $clair_db_username,
    clair_db                         => $clair_db,
    clair_updaters_interval          => $clair_updaters_interval,
    uaa_ca_cert                      => $uaa_ca_cert,
    registry_storage_provider_name   => $registry_storage_provider_name,
    registry_storage_provider_config => $registry_storage_provider_config,
    registry_custom_ca_bundle        => $registry_custom_ca_bundle,
    reload_config                    => $reload_config,
    skip_reload_env_pattern          => $skip_reload_env_pattern,
    webhook_job_max_retry            => $webhook_job_max_retry,
    metrics                          => $metrics,
    metrics_port                     => $metrics_port,
    metrics_path                     => $metrics_path,
  }
  contain 'harbor::config'

  class { 'harbor::prepare':
    with_notary      => $with_notary,
    with_trivy       => $with_trivy,
    with_clair       => $with_clair,
    with_chartmuseum => $with_chartmuseum,
    harbor_ha        => $harbor_ha,
  }
  contain 'harbor::prepare'

  class { 'harbor::service':
    cfg_version          => $_cfg_version,
    with_notary          => $with_notary,
    with_clair           => $with_clair,
    with_chartmuseum     => $with_chartmuseum,
    harbor_ha            => $harbor_ha,
    compose_install_path => $docker::compose::install_path,
  }
  contain 'harbor::service'

  Class['docker'] -> Class['harbor::prepare']
  Class['docker::compose'] -> Class['harbor::prepare']
  Class['harbor::install']
  ~> Class['harbor::config']
  ~> Class['harbor::prepare']
  ~> Class['harbor::service']

}
