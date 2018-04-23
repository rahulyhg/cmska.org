<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

$_POSTS = new posts;

$posts_count = 0;
$skin = 'postshort';
$filter = array();
$url = '/index.php';

$filter['post.posted']  = 1;

if( _CATEG_ID ){    $filter['post.categ'] = _CATEG_ID; }
if( _TAG_ID ){      $filter['tag.id'] = _TAG_ID; }
if( _POST_ID )
{
    $filter['post.id']      = _POST_ID;
    $filter['full_data']    = 1;
    $skin = 'postfull';
}

foreach( $_POSTS->get( $filter, $posts_count ) as $id => $row )
{
    $_POSTS->html( $row, $tpl, $skin );

    if( _POST_ID )
    {
        $tpl->head_tags['title'] = common::htmlspecialchars( $row['post']['title'] );
        $url = $_POSTS->get_url( $row );
    }
}

if( _CATEG_ID && $posts_count )
{
    $tpl->head_tags['title'] = common::htmlspecialchars( $GLOBALS['_CATEG']->get_categories()[_CATEG_ID]['name'] );
    $url = $GLOBALS['_CATEG']->get_url( _CATEG_ID );
}

if( _TAG_ID && $posts_count )
{
    $tpl->head_tags['title'] = common::htmlspecialchars( $GLOBALS['_TAGS']->get_tags()[_TAG_ID]['name'] );
}

if( !$posts_count )
{
    header('HTTP/1.0 404 Not Found');
    header('HTTP/1.1 404 Not Found');
    header('Status: 404 Not Found');

    $tpl->info( 'Матеріал не знайдено!', 'В процесі обробки запиту не вдалося знайти запис.', 'warn' );
}

if( $posts_count && $url != $_SERVER['REQUEST_URI']  )
{
    header('HTTP/1.1 301 Moved Permanently');
    header('Location: '.$url);
    exit;
}

$tpl->load( 'posts' );
$tpl->set( '{posts}', $tpl->result( $skin ) );
$tpl->compile( 'posts' );

//////////////////////////////////////////////////////////////////////////////////////////








?>