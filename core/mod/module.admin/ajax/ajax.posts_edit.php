<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$_POSTS = new posts;

switch( _SUBACTION_ )
{
  case 1:

      if( !isset($_REQUEST['save']) || !is_array($_REQUEST['save']) || !count($_REQUEST['save']) ){ ajax::set_error( 1, 'Save data not found!' ); }
      if( ( $_ID = $_POSTS->save( $_REQUEST['save'] ) ) != false )
      {
          ajax::set_data( 'post_id', common::integer($_ID) );
      }
      else
      {
          ajax::set_error( 1, 'Post save failed!' );
      }

  break;
  default: ajax::set_error( 1, 'Subaction "'._SUBACTION_.'" not defined!' );
}

?>