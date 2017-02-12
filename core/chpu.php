<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

if( preg_match( '!^\/index\.(htm|html)$!i', $_SERVER['REQUEST_URI'], $data ) )
{
    header( 'Location: '.HOME.'' ); exit;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////

if( preg_match( '!\/tag:(.+)(\/|)$!i', $_SERVER['REQUEST_URI'], $data ) )
{
    $_REQUEST['mod'] =  'posts';
    $data = isset($data[1])?tags::tag_decode($data[1]):false;

    if( $data )
    {
        if( !isset($GLOBALS['_TAGS']) || !is_object($GLOBALS['_TAGS']) ){ $GLOBALS['_TAGS'] = new tags; }
        $data = common::integer( $GLOBALS['_TAGS']->get_id( $data, true ) );
        $data = $data?$data:false;
        if( $data )
        {
            $_SERVER['REQUEST_URI'] = preg_replace( '!/tag:(.+)(\/|)$!i', '', $_SERVER['REQUEST_URI'] );
        }
    }else{ $data = false; }
}
define( '_TAG_ID', common::integer( $data ) );

////////////////////////////////////////////////////////////////////////////////////////////////////////////

$data = false;
if( preg_match( '!\/(\d+)-(\w+)\.html$!i', $_SERVER['REQUEST_URI'], $data ) )
{
    $_REQUEST['mod'] =  'posts';
    $data = common::integer( isset($data[1])?$data[1]:false );
}
define( '_POST_ID', common::integer( $data ) );

////////////////////////////////////////////////////////////////////////////////////////////////////////////

$data = false;
if( preg_match( '!^\/([a-z0-9_\/]+?)(\/|)$!i', $_SERVER['REQUEST_URI'], $data ) )
{
    $_REQUEST['mod'] =  'posts';
    $data = isset($data[1])?$data[1]:false;
    $data = explode( '/', $data );

    if( $data && is_array($data) && count($data) )
    {
        if( !isset($GLOBALS['_CATEG']) || !is_object($GLOBALS['_CATEG']) ){ $GLOBALS['_CATEG'] = new categ; }
        $data = common::totranslit( common::filter( end( $data ) ) );
        $data = common::integer( $GLOBALS['_CATEG']->get_id( $data ) );
        $data = $data?$data:false;
    }else{ $data = false; }
}
define( '_CATEG_ID', common::integer( $data ) );

?>