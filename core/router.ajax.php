<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

$rfile = MODS_DIR.DS.'module.'._MOD_.''.DS.'ajax'.DS.'main.php';
if( !file_exists($rfile) )
{
  fclose( fopen($rfile,'w') );
  ajax::set_error( 1, 'File "'.$rfile.'" not exist!' );
}
else
{
  require( $rfile );
}

echo ajax::result();
exit;

?>