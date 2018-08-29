<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$POST_ID = common::integer( isset($_REQUEST['post_id'])?$_REQUEST['post_id']:0 );

$files = upload::process( $_FILES, isset($_REQUEST['config'])?$_REQUEST['config']:array(), $POST_ID );

if( is_array($files) && count($files) )
{
    foreach( $files as $file )
    {
        ajax::set_data( 'result', isset($file['status'])?$file['status']:0 );
    }
}
else
{
    ajax::set_data( 'result', 0 );
}

?>