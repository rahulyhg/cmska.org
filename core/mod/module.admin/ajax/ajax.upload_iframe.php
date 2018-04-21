<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$tpl->load( 'bbcode/upload_frame' );

// SET CONFIG ITEMS //////////////////////////////////////////////////////////////////////
foreach( config::get() as $k => $v )
{
    if( strpos( $k, 'upload.' ) === false ){ continue; }
    $tpl->set( '{'.$k.'}', $v );
}
//////////////////////////////////////////////////////////////////////////////////////////

// INI CONF TO BYTES /////////////////////////////////////////////////////////////////////
$_mfs = ini_get( 'upload_max_filesize' );
if( strpos($_mfs,'G') !== false ){ $_mfs = intval(str_replace('G','',$_mfs)) * 1024 * 1024 * 1024; }
if( strpos($_mfs,'M') !== false ){ $_mfs = intval(str_replace('M','',$_mfs)) * 1024 * 1024; }
if( strpos($_mfs,'K') !== false ){ $_mfs = intval(str_replace('K','',$_mfs)) * 1024; }
//////////////////////////////////////////////////////////////////////////////////////////

$tpl->set( '{upload_max_filesize}', $_mfs );
$tpl->set( '{max_file_uploads}', ini_get( 'max_file_uploads' ) );


$tpl->compile( 'bbcode/upload_frame' );
echo $tpl->result( 'bbcode/upload_frame' );
exit;

?>