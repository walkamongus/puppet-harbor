# @api private
class harbor::service (
  $with_notary,
  $with_clair,
  $with_chartmuseum,
  $harbor_ha,
){

  assert_private()

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

  file { 'harbor_service_unit':
    ensure  => file,
    path    => '/etc/systemd/system/harbor.service',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('harbor/harbor.service.epp', {
      'compose_files' => join($_compose_files.map |$item| { "-f ${item}" }, ' ')
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
