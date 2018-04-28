<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$POST_ID = common::integer( isset($_REQUEST['post_id'])?$_REQUEST['post_id']:0 );

$files = upload::process( $_FILES, isset($_REQUEST['config'])?$_REQUEST['config']:array(), $POST_ID );
var_export( $files );

exit;



?>