<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

$load_module = MODS_DIR.DS.'module.'._MOD_.DS.'main.php';

if( !file_exists( $load_module ) )
{
    common::err( 'loading module failed - file "'.str_replace( ROOT_DIR, '', $load_module ).'" not found' );
    exit;
}

require( $load_module );

?>