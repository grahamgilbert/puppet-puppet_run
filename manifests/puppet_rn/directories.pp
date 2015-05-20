class customer::puppet_conf::directories {
    
    if $::operatingsystem == "Darwin"{
        if !defined(File['/Library/Management']){
            file { '/Library/Management':
                ensure => directory,
            }
        }
    
        if !defined(File['/Library/Management/Puppet']){
            file { '/Library/Management/Puppet':
                ensure => directory,
            }
        }
    }

}