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
# @param release
#   Specifies the Harbor release for the download URL.
#
# @param installer
#   Specifies which installer type to use. Note that not every release has both installer types available.
#
# @param with_notary
#   Specifies whether to include Notary functionality in the deployment.
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
# @param secretkey_path
#   The path of key for encrypt or decrypt the password of a remote registry in a replication policy.
#
# @param admiral_url
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
# @param http_proxy
#  Defaults to None
#
# @param https_proxy
#  Defaults to None
#
# @param no_proxy
#  Defaults to '127.0.0.1,localhost,ui,registry'
#
# @param data_volume
#  Defaults to '/data'
#
# @param email_identity
#
# @param email_server
#
# @param email_server_port
#
# @param email_username
#
# @param email_password
#
# @param email_from
#
# @param email_ssl
#
# @param email_insecure
#
# @param harbor_admin_password
#   Defaults to Harbor12345
#
# @param auth_mode
#
# @param ldap_url
#
# @param ldap_searchdn
#
# @param ldap_search_pwd
#
# @param ldap_basedn
#
# @param ldap_filter
#
# @param ldap_uid
#
# @param ldap_scope
#
# @param ldap_timeout
#
# @param ldap_verify_cert
#
# @param ldap_group_basedn
#
# @param ldap_group_filter
#
# @param ldap_group_gid
#
# @param ldap_group_scope
#
# @param ldap_group_admin_dn
#
# @param self_registration
#
# @param token_expiration
#
# @param project_creation_restriction
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
# @param uaa_endpoint
#
# @param uaa_clientid
#
# @param uaa_clientsecret
#
# @param uaa_verify_cert
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
# @param $webhook_job_max_rety
#
class harbor (
  Pattern[/\d+\.\d+\.\d+.*/] $version,
  Pattern[/\d+\.\d+\.\d+.*/] $release,
  Enum['offline','online'] $installer,
  String  $checksum,
  Boolean $external_redis,
  Boolean $with_notary,
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
  Stdlib::Absolutepath $secretkey_path,
  Variant[Enum['NA'],Stdlib::Httpurl] $admiral_url,
  Variant[Stdlib::Httpurl,String[0,0]] $external_url,
  Enum['debug','info','warning','error','fatal'] $log_level,
  Integer $log_rotate_count,
  String $log_rotate_size,
  String $log_location,
  Variant[Stdlib::Httpurl,String[0,0]] $http_proxy,
  Variant[Stdlib::Httpurl,String[0,0]] $https_proxy,
  String $no_proxy,
  String $data_volume,
  String $email_identity,
  Stdlib::Host $email_server,
  Integer $email_server_port,
  String $email_username,
  String $email_password,
  String $email_from,
  Boolean $email_ssl,
  Boolean $email_insecure,
  String $harbor_admin_password,
  Enum['ldap_auth','db_auth'] $auth_mode,
  Pattern[/^ldap(s)?:\/\/.*/] $ldap_url,
  String $ldap_searchdn,
  String $ldap_search_pwd,
  String $ldap_basedn,
  String $ldap_filter,
  String $ldap_uid,
  Integer[0,2] $ldap_scope,
  Integer $ldap_timeout,
  Boolean $ldap_verify_cert,
  String $ldap_group_basedn,
  String $ldap_group_filter,
  String $ldap_group_gid,
  Integer[0,2] $ldap_group_scope,
  String $ldap_group_admin_dn,
  Enum['on','off'] $self_registration,
  Integer $token_expiration,
  Enum['everyone','adminonly'] $project_creation_restriction,
  Stdlib::Host $db_host,
  String $db_password,
  Stdlib::Port $db_port,
  String $db_user,
  Stdlib::Host $redis_host,
  Stdlib::Port $redis_port,
  String $redis_password,
  Integer $redis_registry_db_index,
  Integer $redis_jobservice_db_index,
  Integer $redis_chartmuseum_db_index,
  Stdlib::Host $clair_db_host,
  String $clair_db_password,
  Stdlib::Port $clair_db_port,
  String $clair_db_username,
  String $clair_db,
  Integer $clair_updaters_interval,
  Stdlib::Host $uaa_endpoint,
  String $uaa_clientid,
  String $uaa_clientsecret,
  Boolean $uaa_verify_cert,
  String $uaa_ca_cert,
  Enum['filesystem','s3','gcs','azure','swift','oss'] $registry_storage_provider_name,
  String $registry_storage_provider_config,
  Variant[Stdlib::Absolutepath,String[0,0]] $registry_custom_ca_bundle,
  Variant[Boolean,String[0,0]] $reload_config,
  String $skip_reload_env_pattern,
  Integer $webhook_job_max_rety,
  Stdlib::Httpurl $download_source = "https://storage.googleapis.com/harbor-releases/release-${release}/harbor-${installer}-installer-v${version}.tgz",
){

  include 'docker'
  include 'docker::compose'

  if ! empty($https_proxy) or ! empty($http_proxy) {
    $_proxy_server = pick($https_proxy, $http_proxy)
  } else {
    $_proxy_server = undef
  }

  $_versions    = split($version, '\.')
  $_cfg_version = "${_versions[0]}.${_versions[1]}.0"

  class { 'harbor::install':
    installer       => $installer,
    version         => $version,
    checksum        => $checksum,
    download_source => $download_source,
    proxy_server    => $_proxy_server,
  }
  contain 'harbor::install'

  $redis_db_index = "${redis_registry_db_index},${redis_jobservice_db_index},${redis_chartmuseum_db_index}"

  class { 'harbor::config':
    cfg_version                      => $_cfg_version,
    hostname                         => $hostname,
    ui_url_protocol                  => $ui_url_protocol,
    max_job_workers                  => $max_job_workers,
    absolute_url                     => $absolute_url,
    customize_crt                    => $customize_crt,
    ssl_cert                         => $ssl_cert,
    ssl_cert_key                     => $ssl_cert_key,
    secretkey_path                   => $secretkey_path,
    admiral_url                      => $admiral_url,
    external_url                     => $external_url,
    log_level                        => $log_level,
    log_rotate_count                 => $log_rotate_count,
    log_rotate_size                  => $log_rotate_size,
    log_location                     => $log_location,
    http_proxy                       => $http_proxy,
    https_proxy                      => $https_proxy,
    no_proxy                         => $no_proxy,
    data_volume                      => $data_volume,
    email_identity                   => $email_identity,
    email_server                     => $email_server,
    email_server_port                => $email_server_port,
    email_username                   => $email_username,
    email_password                   => $email_password,
    email_from                       => $email_from,
    email_ssl                        => $email_ssl,
    email_insecure                   => $email_insecure,
    harbor_admin_password            => $harbor_admin_password,
    auth_mode                        => $auth_mode,
    ldap_url                         => $ldap_url,
    ldap_searchdn                    => $ldap_searchdn,
    ldap_search_pwd                  => $ldap_search_pwd,
    ldap_basedn                      => $ldap_basedn,
    ldap_filter                      => $ldap_filter,
    ldap_uid                         => $ldap_uid,
    ldap_scope                       => $ldap_scope,
    ldap_timeout                     => $ldap_timeout,
    ldap_verify_cert                 => $ldap_verify_cert,
    ldap_group_basedn                => $ldap_group_basedn,
    ldap_group_filter                => $ldap_group_filter,
    ldap_group_gid                   => $ldap_group_gid,
    ldap_group_scope                 => $ldap_group_scope,
    ldap_group_admin_dn              => $ldap_group_admin_dn,
    self_registration                => $self_registration,
    token_expiration                 => $token_expiration,
    project_creation_restriction     => $project_creation_restriction,
    db_host                          => $db_host,
    db_password                      => $db_password,
    db_port                          => $db_port,
    db_user                          => $db_user,
    external_redis                   => $external_redis,
    redis_host                       => $redis_host,
    redis_port                       => $redis_port,
    redis_password                   => $redis_password,
    redis_db_index                   => $redis_db_index,
    redis_registry_db_index          => $redis_registry_db_index,
    redis_jobservice_db_index        => $redis_jobservice_db_index,
    redis_chartmuseum_db_index       => $redis_chartmuseum_db_index,
    clair_db_host                    => $clair_db_host,
    clair_db_password                => $clair_db_password,
    clair_db_port                    => $clair_db_port,
    clair_db_username                => $clair_db_username,
    clair_db                         => $clair_db,
    clair_updaters_interval          => $clair_updaters_interval,
    uaa_endpoint                     => $uaa_endpoint,
    uaa_clientid                     => $uaa_clientid,
    uaa_clientsecret                 => $uaa_clientsecret,
    uaa_verify_cert                  => $uaa_verify_cert,
    uaa_ca_cert                      => $uaa_ca_cert,
    registry_storage_provider_name   => $registry_storage_provider_name,
    registry_storage_provider_config => $registry_storage_provider_config,
    registry_custom_ca_bundle        => $registry_custom_ca_bundle,
    reload_config                    => $reload_config,
    skip_reload_env_pattern          => $skip_reload_env_pattern,
    webhook_job_max_rety             => $webhook_job_max_rety,
  }
  contain 'harbor::config'

  class { 'harbor::prepare':
    with_notary      => $with_notary,
    with_clair       => $with_clair,
    with_chartmuseum => $with_chartmuseum,
    harbor_ha        => $harbor_ha,
  }
  contain 'harbor::prepare'

  class { 'harbor::service':
    cfg_version      => $_cfg_version,
    with_notary      => $with_notary,
    with_clair       => $with_clair,
    with_chartmuseum => $with_chartmuseum,
    harbor_ha        => $harbor_ha,
  }
  contain 'harbor::service'

  Class['harbor::install']
  -> Class['harbor::config']
  ~> Class['harbor::prepare']
  ~> Class['harbor::service']

}
