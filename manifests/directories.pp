class puppet_run::directories {

    if $::operatingsystem == "Darwin"{
        if !defined(File['/Library/Management']){
            file { '/Library/Management':
                ensure => directory,
            }
        }

        if !defined(File['/Library/Management/bin']){
            file { '/Library/Management/bin':
                ensure => directory,
            }
        }
    }

}
