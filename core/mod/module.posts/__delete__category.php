<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$_POSTS = new posts;
$posts_count = 0;
$skin = 'postshort';

$category = explode( '/', preg_replace( '!\/$!', '', $_SERVER['REQUEST_URI'] ) );
$category = end( $category );
$category = common::totranslit( $category );

if( !isset($GLOBALS['_CATEG']) || !is_object($GLOBALS['_CATEG']) ){ $GLOBALS['_CATEG'] = new categ; }

$category = common::integer( $GLOBALS['_CATEG']->get_id( $category ) );

if( $category )
{
    $filter = array();
    $filter['post.categ'] = $category;

    if( isset($GLOBALS['_CATEG']->get_categories()[$category]) )
    {
        $tpl->head_tags['title'] = common::htmlspecialchars( $GLOBALS['_CATEG']->get_categories()[$category]['name'] );
        $url = $GLOBALS['_CATEG']->get_url( $category );
        if( $url != $_SERVER['REQUEST_URI']  )
        {
            header('HTTP/1.1 301 Moved Permanently');
            header('Location: '.$url);
            exit;
        }
    }

    foreach( $_POSTS->get( $filter, $posts_count ) as $id => $row )
    {
        $_POSTS->html( $row, $tpl, $skin );
    }
}

$tpl->load( 'posts' );
$tpl->set( '{posts}', $posts_count?$tpl->result( $skin ):'' );
$tpl->compile( 'posts' );

if( !$posts_count && isset($GLOBALS['_CATEG']->get_categories()[$category]) )
{
    header("HTTP/1.0 404 Not Found");
    $tpl->info( 'Публікацій не знайдено!', 'В даній категорії публікації відсутні.', 'notice' );
}
elseif( !$posts_count )
{
    header("HTTP/1.0 404 Not Found");
    $tpl->info( 'Публікацій не знайдено!', 'В процесі обробки запиту не вдалося встановити унікальний ідентифікатор категорії.', 'warn' );
}

?>