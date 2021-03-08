# @api private
# @summary Sets up a systemd unit file and service for Harbor
class harbor::service (
  $cfg_version,
  $with_notary,
  $with_clair,
  $with_chartmuseum,
  $harbor_ha,
  $compose_install_path,
){

  assert_private()

  if versioncmp($cfg_version, '2.0.0') >= 0 {
    $_compose_files_final = '-f /opt/harbor/docker-compose.yml'
  } elsif versioncmp($cfg_version, '1.8.0') >= 0 {
    if $harbor_ha {
      $_compose_files = '/opt/harbor/ha/docker-compose.yml'
    } else {
      $_compose_files = '/opt/harbor/docker-compose.yml'
    }
    $_compose_files_final = "-f ${_compose_files}"
  } else {
    if $harbor_ha {
      $_compose       = '/opt/harbor/ha/docker-compose.yml'
      $_clair_compose = '/opt/harbor/ha/docker-compose.clair.yml'
    } else {
      $_compose       = '/opt/harbor/docker-compose.yml'
      $_clair_compose = '/opt/harbor/docker-compose.clair.yml'
    }

    $_optional_compose_files = {
      'clair'       => $_clair_compose,
      'notary'      => '/opt/harbor/docker-compose.notary.yml',
      'chartmuseum' => '/opt/harbor/docker-compose.chartmuseum.yml',
    }

    $_extra_files = $_optional_compose_files.map |$key, $value| {
      if getvar("with_${key}") { $value }
    }

    $_compose_files = delete_undef_values([ $_compose ] + $_extra_files)
    $_compose_files_final = join($_compose_files.map |$item| { "-f ${item}" }, ' ')
  }

  file { 'harbor_service_unit':
    ensure  => file,
    path    => '/etc/systemd/system/harbor.service',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('harbor/harbor.service.epp', {
      'compose_install_path' => $compose_install_path,
      'compose_files'        => $_compose_files_final,
    }),
    notify  => Exec['harbor_systemd_daemon-reload'],
  }

  exec { 'harbor_systemd_daemon-reload':
    path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command     => 'systemctl daemon-reload > /dev/null',
    refreshonly => true,
  }

  service { 'harbor':
    ensure    => running,
    enable    => true,
    subscribe => Exec['harbor_systemd_daemon-reload'],
  }

}
