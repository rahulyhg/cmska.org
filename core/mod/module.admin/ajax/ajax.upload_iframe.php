<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$tpl->load( 'bbcode/upload_frame' );
$tpl->compile( 'bbcode/upload_frame' );
echo $tpl->result( 'bbcode/upload_frame' );
exit;

?>