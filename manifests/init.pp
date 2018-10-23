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
#   Specifies the Harbor release version to install. See available releases at {https://github.com/goharbor/harbor/releases Harbor Releases}
#
# @param installer
#   Specifies which installer type to use. Note that not every release has both installer types available.
#
# @param with_notary
#   Specifies whether to include Notary functionality in the deployment.
#
# @param with_clair
#   Specifies whether to include Clair functionality in the deployment.
#
# @param with_chartmuseum
#   Specifies whether to include Helm Chart repository functionality in the deployment.
#
# @param harbor_ha
#   Specifies whether to include high availability functionality in the deployment.
#
# @param download_source
#   Specifies download location for the Harbor installation tar file.
#
# @param hostname
#
# @param ui_url_protocol
#
# @param max_job_workers
#
# @param customize_crt
#
# @param ssl_cert
#
# @param ssl_cert_key
#
# @param secretkey_path
#
# @param admiral_url
#
# @param log_rotate_count
#
# @param log_rotate_size
#
# @param http_proxy
#
# @param https_proxy
#
# @param no_proxy
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
#
# @param db_password
#
# @param db_port
#
# @param db_user
#
# @param redis_host
#
# @param redis_port
#
# @param redis_password
#
# @param redis_db_index
#
# @param clair_db_host
#
# @param clair_db_password
#
# @param clair_db_port
#
# @param clair_db_username
#
# @param clair_db
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
class harbor (
  Pattern[/\d+\.\d+\.\d+.*/] $version,
  Enum['offline','online'] $installer,
  Boolean $with_notary,
  Boolean $with_clair,
  Boolean $with_chartmuseum,
  Boolean $harbor_ha,
  Stdlib::Host $hostname,
  Enum['http','https'] $ui_url_protocol,
  Integer $max_job_workers,
  Enum['on','off'] $customize_crt,
  Stdlib::Absolutepath $ssl_cert,
  Stdlib::Absolutepath $ssl_cert_key,
  Stdlib::Absolutepath $secretkey_path,
  Variant[Enum['NA'],Stdlib::Httpurl] $admiral_url,
  Integer $log_rotate_count,
  String $log_rotate_size,
  Variant[Stdlib::Httpurl,String[0,0]] $http_proxy,
  Variant[Stdlib::Httpurl,String[0,0]] $https_proxy,
  String $no_proxy,
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
  Pattern[/^[0-3](,[0-3])*$/] $redis_db_index,
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
  Stdlib::Absolutepath $uaa_ca_cert,
  Enum['filesystem','s3','gcs','azure','swift','oss'] $registry_storage_provider_name,
  String $registry_storage_provider_config,
  Variant[Stdlib::Absolutepath,String[0,0]] $registry_custom_ca_bundle,
  Variant[Boolean,String[0,0]] $reload_config,
  String $skip_reload_env_pattern,
  Stdlib::Httpurl $download_source = "https://storage.googleapis.com/harbor-releases/release-${version}/harbor-${installer}-installer-v${version}.tgz",
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
    download_source => $download_source,
    proxy_server    => $_proxy_server,
  }
  contain 'harbor::install'

  class { 'harbor::config':
    cfg_version                      => $_cfg_version,
    hostname                         => $hostname,
    ui_url_protocol                  => $ui_url_protocol,
    max_job_workers                  => $max_job_workers,
    customize_crt                    => $customize_crt,
    ssl_cert                         => $ssl_cert,
    ssl_cert_key                     => $ssl_cert_key,
    secretkey_path                   => $secretkey_path,
    admiral_url                      => $admiral_url,
    log_rotate_count                 => $log_rotate_count,
    log_rotate_size                  => $log_rotate_size,
    http_proxy                       => $http_proxy,
    https_proxy                      => $https_proxy,
    no_proxy                         => $no_proxy,
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
    redis_host                       => $redis_host,
    redis_port                       => $redis_port,
    redis_password                   => $redis_password,
    redis_db_index                   => $redis_db_index,
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
