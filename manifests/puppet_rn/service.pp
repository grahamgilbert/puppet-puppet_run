class customer::puppet_conf::service (
    $server_name = $customer::puppet_conf::server_name
){
    case $operatingsystem {
        Darwin:{
            service { 'com.pebbleit.puppet_run':
                ensure  => 'running',
                enable  => 'true',
            }
        }
        
        Ubuntu:{
            service {'puppet':
                ensure  => running,
            }
            
            file {'/etc/default/puppet':
                ensure  => present,
                source  => 'puppet:///modules/customer/puppet_conf/defaults_puppet_ubuntu12',
            }
        }
    }
}