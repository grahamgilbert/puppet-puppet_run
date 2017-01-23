class puppet_run::service (
    $server_name = $puppet_run::server_name
){
    case $operatingsystem {
        'Darwin':{
        	# puppet has its own service since version 4.0
        	if versioncmp($::clientversion, '4') < 0 {
				service { 'com.grahamgilbert.puppet_run':
					ensure  => 'running',
					enable  => 'true',
				}
			}
        }

        'Ubuntu':{
            service {'puppet':
                ensure  => running,
            }
        }
    }
}
