<?php

error_reporting ( E_ALL );
ini_set ( 'display_errors', true );
ini_set ( 'html_errors', false );
ini_set ( 'error_reporting', E_ALL );

//////////////////////////////////////////////////////////////////////////////////////////

define ( 'DOMAIN',      'cmska.org' );
define ( 'HOME',        '/' );
define ( 'HOMEURL',        'https://'.DOMAIN.HOME );
define ( 'GAUSS_CMS', true );
define ( 'DS', DIRECTORY_SEPARATOR );
define ( 'ROOT_DIR',        dirname ( __FILE__ ) );
define ( 'CORE_DIR',        ROOT_DIR.DS.'core' );
define ( 'CLASSES_DIR',     CORE_DIR.DS.'classes' );
define ( 'CACHE_DIR',       ROOT_DIR.DS.'cache' );
define ( 'MODS_DIR',        CORE_DIR.DS.'mod' );
define ( 'TPL_DIR',         ROOT_DIR.DS.'tpl' );
define ( 'USER_IP',         $_SERVER['REMOTE_ADDR'] );
define ( 'CHARSET',         'CP1251' );

//////////////////////////////////////////////////////////////////////////////////////////

header( 'Content-type: text/html; charset='.CHARSET );
ob_start();

//////////////////////////////////////////////////////////////////////////////////////////

require( CLASSES_DIR.DS.'class.err_handler.php' );
err_handler::start();

//////////////////////////////////////////////////////////////////////////////////////////

require( CORE_DIR.DS.'init.php' );

//////////////////////////////////////////////////////////////////////////////////////////

        $tpl->load( 'content' );
        $tpl->compile( 'content' );
echo    $tpl->result( 'content' )."\n".'<!-- Used memory: '.round(memory_get_peak_usage()/1024,2).' kb -->';

//////////////////////////////////////////////////////////////////////////////////////////

exit;

?>