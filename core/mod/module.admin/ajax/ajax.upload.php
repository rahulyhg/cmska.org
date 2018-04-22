<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$tpl->load( 'bbcode/upload' );

// SET CONFIG ITEMS //////////////////////////////////////////////////////////////////////
foreach( config::get() as $k => $v )
{
    if( strpos( $k, 'upload.' ) === false ){ continue; }
    $tpl->set( '{'.$k.'}', $v );
}
//////////////////////////////////////////////////////////////////////////////////////////

$tpl->set( '{upload_max_filesize}', common::iniBytes2normalBytes( ini_get( 'upload_max_filesize' ) ) );
$tpl->set( '{max_file_uploads}', ini_get( 'max_file_uploads' ) );

//////////////////////////////////////////////////////////////////////////////////////////

$tpl->compile( 'bbcode/upload' );

ajax::set_data( 'template', $tpl->result( 'bbcode/upload' ) );

?>