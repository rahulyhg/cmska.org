<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$_action_file = false;
switch( _ACTION_ )
{
  case 1:
    $_action_file = 'posts_edit';
  break;

  default:
    ajax::set_error( 1, 'Action "'._ACTION_.'" not defined!' );
}

?>