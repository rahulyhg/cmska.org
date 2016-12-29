<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

$_POSTS = new posts;
$_POSTS->editpost_html( $_POSTS->get( array( 'nullpost' => true ) ), $tpl, 'post_edit' );

$tpl->load( 'page_item' );
$tpl->set( '{data}', $tpl->result( 'post_edit' ) );
$tpl->compile( 'page_item' );

?>