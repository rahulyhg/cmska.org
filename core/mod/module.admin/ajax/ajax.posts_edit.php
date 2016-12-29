<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$_POSTS = new posts;

switch( _SUBACTION_ )
{
  case 1:

      if( !isset($_REQUEST['save']) || !is_array($_REQUEST['save']) || !count($_REQUEST['save']) ){ ajax::set_error( 1, 'Save data not found!' ); }
      $_POSTS->save( $_REQUEST['save'] );

  break;
  default: ajax::set_error( 1, 'Subaction "'._SUBACTION_.'" not defined!' );
}

?>