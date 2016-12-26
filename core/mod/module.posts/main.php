<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

$filter = array();

//////////////////////////////////////////////////////////////////////////////////////////

$_POSTS = new posts;
$posts_count = 0;
$skin = 'postshort';
$filter = array();

if( _CATEG_ID ){    $filter['post.categ'] = _CATEG_ID; }
if( _TAG_ID ){      $filter['tag.id'] = _TAG_ID; }
if( _POST_ID )
{
    $filter['post.id'] = _POST_ID;
    $filter['full_data'] = 1;
    $skin = 'postfull';
}

foreach( $_POSTS->get( $filter, $posts_count ) as $id => $row )
{
    $_POSTS->html( $row, $tpl, $skin );
}

$tpl->load( 'posts' );
$tpl->set( '{posts}', $tpl->result( $skin ) );
$tpl->compile( 'posts' );

//////////////////////////////////////////////////////////////////////////////////////////








?>