<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }
if( !trait_exists( 'db_connect' ) ){ require( CLASSES_DIR.DS.'trait.db_connect.php' ); }
if( !trait_exists( 'admin_build_panel' ) ){ require( CLASSES_DIR.DS.'admin'.DS.'trait.admin.build_panel.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

class admin
{
    use basic, db_connect, admin_build_panel;

}

?>