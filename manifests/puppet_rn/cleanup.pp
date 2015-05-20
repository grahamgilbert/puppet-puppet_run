class customer::puppet_conf::cleanup (
    $server_name = $customer::puppet_conf::server_name
){
    case $operatingsystem {
        Darwin:{
            exec { 'stop_old_puppet':
              command => '/bin/launchctl unload -w /Library/LaunchDaemons/com.reductivelabs.puppet.plist',
              onlyif  => '/bin/test -f /Library/LaunchDaemons/com.reductivelabs.puppet.plist',
            }
            
            file {'/Library/LaunchDaemons/com.reductivelabs.puppet.plist':
                ensure   => 'absent',
                require => Exec['stop_old_puppet'],
            }
        }
    }
}