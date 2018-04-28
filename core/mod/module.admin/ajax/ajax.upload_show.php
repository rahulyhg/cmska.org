<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$POST_ID = isset($_REQUEST['post_id'])?common::integer( $_REQUEST['post_id'] ):0;

$data = images::get( $POST_ID );

foreach( $data as $image )
{
    $tpl->load( 'bbcode/show_uploaded_file' );

    $file = UPL_DIR.DS.'images'.DS.common::en_date($image['load_time'],'Y-m-d').DS.$image['serv_name'];

    $tpl->set( '{SRC}', str_replace( ROOT_DIR, '', $file ) );

    $tpl->compile( 'bbcode/show_uploaded_file' );
}



ajax::set_data( 'template', $tpl->result( 'bbcode/show_uploaded_file' ) );

?>