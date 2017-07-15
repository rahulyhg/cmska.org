<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$tpl->load( 'bbcode/upload' );

$tpl->compile( 'bbcode/upload' );

ajax::set_data( 'template', $tpl->result( 'bbcode/upload' ) );

?>