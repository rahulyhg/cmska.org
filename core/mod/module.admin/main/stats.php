<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////


$tpl->load( 'page_item' );
$tpl->set( '{data}', stats::get_html_stats() );
$tpl->compile( 'page_item' );

?>