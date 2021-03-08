# @api private
# @summary Runs the Harbor prepare script
class harbor::prepare (
  $with_notary,
  $with_trivy,
  $with_clair,
  $harbor_ha,
  $with_chartmuseum,
){

  assert_private()

  if $with_notary and !$harbor_ha {
    $opts_hash = {
      '--with-notary'      => $with_notary,
      '--with-trivy'       => $with_trivy,
      '--with-clair'       => $with_clair,
      '--ha'               => $harbor_ha,
      '--with-chartmuseum' => $with_chartmuseum,
    }
  } else {
    $opts_hash = {
      '--with-trivy'       => $with_trivy,
      '--with-clair'       => $with_clair,
      '--ha'               => $harbor_ha,
      '--with-chartmuseum' => $with_chartmuseum,
    }
  }

  $opts = join(keys($opts_hash.filter |$key, $value| { $value }), ' ')

  file { '/opt/harbor/prepare.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => join([
      '#!/bin/bash',
      '# File managed by Puppet, do not edit',
      'systemctl stop harbor',
      "/opt/harbor/prepare ${opts}",
      'ret=$?',
      'systemctl start harbor',
      'exit $ret',
      '',
    ], "\n"),
    notify  => Exec['prepare_harbor'],
  }

  exec { 'prepare_harbor':
    cwd         => '/opt/harbor',
    command     => '/opt/harbor/prepare.sh',
    timeout     => 0,
    logoutput   => true,
    refreshonly => true,
  }

  if $harbor::internal_tls {
    exec { 'harbor-gencerts':
      path        => '/usr/local/bin:/usr/bin:bin',
      environment => ['HOME=/root'],
      command     => "docker run -v /:/hostfs goharbor/prepare:v${harbor::version} gencert -p ${harbor::internal_tls_dir} -d ${harbor::internal_tls_days}",
      creates     => "${harbor::internal_tls_dir}/harbor_internal_ca.crt",
      notify      => Exec['prepare_harbor'],
    }
  }

}
