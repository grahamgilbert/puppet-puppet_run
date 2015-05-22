class puppet_run::service (
    $server_name = $puppet_run::server_name
){
    case $operatingsystem {
        Darwin:{
            service { 'com.grahamgilbert.puppet_run':
                ensure  => 'running',
                enable  => 'true',
            }
        }

        Ubuntu:{
            service {'puppet':
                ensure  => running,
            }
        }
    }
}
