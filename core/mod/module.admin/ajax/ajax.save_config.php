<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }


foreach( (isset($_REQUEST['save'])?$_REQUEST['save']:array()) as $k => $v )
{
    $k = admin::filter( $k );
    $v = admin::filter( $v );
    $_config[$k] = $v;
}

config::set($_config);

?>