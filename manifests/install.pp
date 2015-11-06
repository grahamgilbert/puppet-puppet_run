class puppet_run::install (
    $server_name = $puppet_run::server_name
){
    case $operatingsystem {
        Darwin:{
          if versioncmp($::clientversion, '4') > 0 {
                file { mac_puppet_conf:
                    path    => "/etc/puppetlabs/puppet/puppet.conf",
                    owner   => root,
                    group   => wheel,
                    mode    => '0644',
                    ensure  => present,
                    content => template("puppet_run/mac_puppet_conf.erb"),
                }
                file { '/etc/paths.d/puppet':
                    ensure => present,
                    group  => 0,
                    owner  => 0,
                    mode   => '0755',
                    source => 'puppet:///modules/puppet_run/puppet'
                }
            }

            if versioncmp($::clientversion, '4') < 0 {

                file { mac_puppet_conf:
                    path    => "/etc/puppet/puppet.conf",
                    owner   => root,
                    group   => wheel,
                    mode    => '0644',
                    ensure  => present,
                    content => template("puppet_run/mac_puppet_conf.erb"),
                }
                file {'/Library/LaunchDaemons/com.grahamgilbert.puppet_run.plist':
                    owner   => root,
                    group   => wheel,
                    mode    => '0644',
                    ensure  => present,
                    source  => 'puppet:///modules/puppet_run/com.grahamgilbert.puppet_run.plist',
                    notify  => Exec['load_puppet_run'],
                }

                file {'/Library/Management/bin/puppet_run.py':
                    owner   => root,
                    group   => wheel,
                    mode    => '0755',
                    ensure  => present,
                    source  => 'puppet:///modules/puppet_run/puppet_run.py',
                }

                exec {'load_puppet_run':
                    command     => '/bin/launchctl -w load /Library/LaunchDaemons/com.grahamgilbert.puppet_run.plist',
                    refreshonly => true,
                }
            }
                
            

        }

        Ubuntu:{
            $default_content = '# Defaults for puppet - sourced by /etc/init.d/puppet

# Enable puppet agent service?
# Setting this to "yes" allows the puppet agent service to run.
# Setting this to "no" keeps the puppet agent service from running.
START=yes

# Startup options
DAEMON_OPTS=""
'
            file {'/etc/default/puppet':
                content => $default_content,
                owner   => 0,
                group   => 0,
                mode    => 0644,
            }
        }

    }

}
