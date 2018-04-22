<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$files = upload::process( $_FILES, isset($_REQUEST['config'])?$_REQUEST['config']:array() );
var_export( $files );

exit;



?>