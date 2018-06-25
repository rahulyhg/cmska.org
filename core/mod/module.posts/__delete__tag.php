<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$_POSTS = new posts;
$posts_count = 0;
$skin = 'postshort';

$tag = explode( 'tag-', preg_replace( '!\/$!i', '', $_SERVER['REQUEST_URI'] ), 2 );
$tag = isset($tag[1])?$tag[1]:false;

if( !isset($GLOBALS['_TAGS']) || !is_object($GLOBALS['_TAGS']) ){ $GLOBALS['_TAGS'] = new tags; }
$tag = common::integer( $GLOBALS['_TAGS']->get_id( $tag ) );

if( $tag )
{
    $filter = array();
    $filter['tag.id'] = $tag;

    foreach( $_POSTS->get( $filter, $posts_count ) as $id => $row )
    {
        $_POSTS->html( $row, $tpl, $skin );
    }

    if( isset($GLOBALS['_TAGS']->get_tags()[$tag]) )
    {
        $tpl->head_tags['title'] = common::htmlspecialchars( $GLOBALS['_TAGS']->get_tags()[$tag]['name'] );
    }
}

$tpl->load( 'posts' );
$tpl->set( '{posts}', $posts_count?$tpl->result( $skin ):'' );
$tpl->compile( 'posts' );

if( !$posts_count )
{
    header("HTTP/1.0 404 Not Found");
    $tpl->info( 'Публікації за даним тегом не знайдені!', 'В процесі обробки запиту не вдалося встановити унікальний ідентифікатор тегу.', 'warn' );
}

?>