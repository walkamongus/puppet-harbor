# @api private
# @summary Runs the Harbor prepare script
class harbor::prepare (
  $with_notary,
  $with_clair,
  $harbor_ha,
  $with_chartmuseum,
){

  assert_private()

  if $with_notary and !$harbor_ha {
    $opts_hash = {
      '--with-notary'      => $with_notary,
      '--with-clair'       => $with_clair,
      '--ha'               => $harbor_ha,
      '--with-chartmuseum' => $with_chartmuseum,
    }
  } else {
    $opts_hash = {
      '--with-clair'       => $with_clair,
      '--ha'               => $harbor_ha,
      '--with-chartmuseum' => $with_chartmuseum,
    }
  }

  $opts = join(keys($opts_hash.filter |$key, $value| { $value }), ' ')

  exec { 'prepare_harbor':
    cwd         => '/opt/harbor',
    command     => "/opt/harbor/prepare ${opts}",
    logoutput   => true,
    refreshonly => true,
  }

}
