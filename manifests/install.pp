# @api private
class harbor::install (
  $installer,
  $version,
  $checksum,
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
    ensure        => present,
    extract       => true,
    extract_path  => "/opt/harbor-v${version}",
    source        => $download_source,
    checksum      => $checksum,
    checksum_type => 'md5',
    creates       => "/opt/harbor-v${version}/harbor",
    cleanup       => true,
    proxy_server  => $proxy_server,
    require       => File["/opt/harbor-v${version}"],
  }

  file { '/opt/harbor':
    ensure    => link,
    target    => "/opt/harbor-v${version}/harbor",
    subscribe => Archive["/tmp/harbor-${installer}-installer-v${version}.tgz"],
  }

  if $installer == 'offline' {
    # The harbor image tar contains all Harbor images in a single archive.
    # The title below is used to locate a single existing image name to
    # prevent the docker::image resource from executing each puppet run.
    # goharbor/harbor-log exists in both the 1.6.x and 1.7.x releases.
    docker::image { 'goharbor/harbor-log':
      docker_tar => '/opt/harbor/harbor*.tar.gz',
      subscribe  => File['/opt/harbor'],
    }
  }

}
