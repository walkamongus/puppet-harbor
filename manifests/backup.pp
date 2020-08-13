# @api private
# @summary Backs up Harbor database to a known location if a version change is detected
class harbor::backup (
  Pattern[/\d+\.\d+\.\d+.*/] $version,
  String $data_volume,
  Stdlib::Absolutepath $backup_directory,
){

  assert_private()

  exec { 'stop_harbor':
    path      => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command   => 'systemctl stop harbor.service',
    logoutput => true,
  }

  exec { 'back_up_harbor_database':
    path      => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command   => "tar -cvzf ${backup_directory}/harbor_v${version}_db_backup.tar.gz ${data_volume}/database",
    creates   => "${backup_directory}/harbor_v${version}_db_backup.tar.gz",
    logoutput => true,
    require   => Exec['stop_harbor'],
  }

}
