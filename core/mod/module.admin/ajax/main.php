<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$_action_file = false;
switch( _ACTION_ )
{

  case 2: //SAVE CONFIG
    $_action_file = 'save_config';
  break;

  case 100:
    $_action_file = 'posts_edit';
  break;

  case 10: //UPLOAD
    $_action_file = 'upload';
  break;

  case 11: //SHOW UPLOADED
    $_action_file = 'upload_show';
  break;

  case 12: //UPLOAD
    $_action_file = 'upload_process';
  break;

  case 13: //UPLOAD
    $_action_file = 'upload_delete';
  break;

  default:
    ajax::set_error( 1, 'Action "'._ACTION_.'" not defined!' );
}

if( $_action_file )
{
    $_action_file = dirname(__FILE__).DS.'ajax.'.$_action_file.'.php';

    if( !file_exists($_action_file) )
    {
        //fclose( fopen($_action_file,'w') );
        ajax::set_error( 1, 'Action file "'.basename($_action_file).'" not found!' );
    }
    else
    {
        require( $_action_file );
    }
}
else
{
    ajax::set_error( 1, 'Action file not found!' );
}


?>