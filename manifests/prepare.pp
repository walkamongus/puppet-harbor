# @api private
# @summary Runs the Harbor prepare script
class harbor::prepare (
  $version,
  $with_notary,
  $with_trivy,
){

  assert_private()

  $opts_hash = {
    '--with-notary'      => $with_notary,
    '--with-trivy'       => $with_trivy,
  }.filter |$key, $value| { $value }

  $opts = join(keys($opts_hash), ' ')

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
