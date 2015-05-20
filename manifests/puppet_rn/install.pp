class customer::puppet_conf::install (
    $server_name = $customer::puppet_conf::server_name
){
    case $operatingsystem {
        Darwin:{
            include customer::all::mac_folders
            
            file { mac_puppet_conf:
                path    => "/etc/puppet/puppet.conf",
                owner   => root,
                group   => wheel,
                mode    => 644,
                ensure  => present,
                content => template("customer/mac_puppet_conf.erb"),
            }
            
            file {'/usr/local/pebbleit/puppetfix':
                owner   => root,
                group   => wheel,
                mode    => 755,
                ensure  => present,
                source  => 'puppet:///modules/customer/puppet_conf/puppetfix',
            }
            
            file {'/Library/LaunchDaemons/com.pebbleit.puppet_run.plist':
                owner   => root,
                group   => wheel,
                mode    => 644,
                ensure  => present,
                source  => 'puppet:///modules/customer/puppet_conf/com.pebbleit.puppet_run.plist',
                notify  => Exec['load_puppet_run'],
            }
            
            file {'/Library/Management/Puppet/puppet_run.py':
                owner   => root,
                group   => wheel,
                mode    => 755,
                ensure  => present,
                source  => 'puppet:///modules/customer/puppet_conf/puppet_run.py',
            }
            
            exec {'load_puppet_run':
                command     => '/bin/launchctl -w load /Library/LaunchDaemons/com.pebbleit.puppet_run.plist',
                refreshonly => true,
            }
        
        }
        
        #We manage facter and puppet versions with Munki on Darwin, but we need to specify it for the rest
        Ubuntu:{
            package {'facter':
                ensure  => latest,
                require => File['/etc/apt/preferences.d/00-facter.pref'],
            }

            package {'puppet':
                ensure  => latest,
                require => File['/etc/apt/preferences.d/00-puppet.pref'],
            }
            
            package {'puppet-common':
                ensure  => latest,
                require => File['/etc/apt/preferences.d/00-puppet.pref'],
            }
            
            file {'/etc/apt/preferences.d/00-puppet.pref':
                ensure  => present,
                source  => 'puppet:///modules/customer/puppet_conf/00-puppet.pref',
            }
            
            file {'/etc/apt/preferences.d/00-facter.pref':
                ensure  => present,
                source  => 'puppet:///modules/customer/puppet_conf/00-facter.pref',
            }
        }
        Windows:{
            package { 'puppet':
                ensure => installed,
                enable => true,
                source => 'http://downloads.puppetlabs.com/windows/puppet-3.1.1.msi',
            }

            file { win_puppet_conf:
                path    => "C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf",
                ensure  => present,
                content => template("customer/win_puppet_conf.erb"),
            }
        }
    }

}
