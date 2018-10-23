# @api private
class harbor::install (
  $installer,
  $version,
  $download_source,
  $proxy_server = undef,
){

  assert_private()

  file { "/opt/harbor-v${version}":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   =>  '0755',
  }

  archive { "/tmp/harbor-${installer}-installer-v${version}.tgz":
    ensure       => present,
    extract      => true,
    extract_path => "/opt/harbor-v${version}",
    source       => $download_source,
    creates      => "/opt/harbor-v${version}/harbor",
    cleanup      => true,
    proxy_server => $proxy_server,
    require      => File["/opt/harbor-v${version}"],
  }

  file { '/opt/harbor':
    ensure    => link,
    target    => "/opt/harbor-v${version}/harbor",
    subscribe => Archive["/tmp/harbor-${installer}-installer-v${version}.tgz"],
  }

  if $installer == 'offline' {
    docker::image { 'goharbor/harbor-ui':
      docker_tar => '/opt/harbor/harbor*.tar.gz',
      subscribe  => File['/opt/harbor'],
    }
  }

}
