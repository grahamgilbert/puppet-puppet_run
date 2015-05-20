class puppet_run (
    $server_name
){
    class {'puppet_run::directories': } ->
    class {'puppet_run::install': } ->
    class {'puppet_run::service': }
}
