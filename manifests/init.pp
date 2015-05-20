class puppet_run (
    $server_name
){
    class {'customer::puppet_conf::directories': } ->
    class {'customer::puppet_conf::install': } ->
    class {'customer::puppet_conf::service': } ->
    class {'customer::puppet_conf::cleanup': }
}
