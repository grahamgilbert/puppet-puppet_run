class puppet_run::install (
    $server_name = $puppet_run::server_name
){
    case $operatingsystem {
        Darwin:{

            file { mac_puppet_conf:
                path    => "/etc/puppet/puppet.conf",
                owner   => root,
                group   => wheel,
                mode    => 644,
                ensure  => present,
                content => template("customer/mac_puppet_conf.erb"),
            }


            file {'/Library/LaunchDaemons/com.grahamgilbert.puppet_run.plist':
                owner   => root,
                group   => wheel,
                mode    => 644,
                ensure  => present,
                source  => 'puppet:///modules/puppet_run/com.grahamgilbert.puppet_run.plist',
                notify  => Exec['load_puppet_run'],
            }

            file {'/Library/Management/bin/puppet_run.py':
                owner   => root,
                group   => wheel,
                mode    => 755,
                ensure  => present,
                source  => 'puppet:///modules/puppet_run/puppet_run.py',
            }

            exec {'load_puppet_run':
                command     => '/bin/launchctl -w load /Library/LaunchDaemons/com.pebbleit.puppet_run.plist',
                refreshonly => true,
            }

        }

    }

}
