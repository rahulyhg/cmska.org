<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$_POSTS = new posts;
$posts_count = 0;
$skin = 'postfull';

$post_id = common::integer(preg_replace( '!^(.+?)\/(\d+?)-(.+?)$!', '$2', $_SERVER['REQUEST_URI'] ));

if( $post_id )
{
    $filter = array();
    $filter['post.id'] = $post_id;
    $filter['full_data'] = 1;

    foreach( $_POSTS->get( $filter, $posts_count ) as $id => $row )
    {
        $_POSTS->html( $row, $tpl, $skin );
        $tpl->head_tags['title'] = common::htmlspecialchars( $row['post']['title'] );

        $url = $_POSTS->get_url( $row );
        if( $url != $_SERVER['REQUEST_URI']  )
        {
            header('HTTP/1.1 301 Moved Permanently');
            header('Location: '.$url);
            exit;
        }

        break;
    }
}

$tpl->load( 'posts' );
$tpl->set( '{posts}', $posts_count?$tpl->result( $skin ):'' );
$tpl->compile( 'posts' );

if( !$posts_count )
{
    header('HTTP/1.0 404 Not Found');
    header('HTTP/1.1 404 Not Found');
    header('Status: 404 Not Found');

    $tpl->info( 'Публікацію не знайдено!', 'В процесі обробки запиту не вдалося встановити унікальний ідентифікатор публікацї.', 'warn' );
}

?>