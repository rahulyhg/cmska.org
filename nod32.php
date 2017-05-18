<?php

error_reporting ( E_ALL );
ini_set ( 'display_errors', true );
ini_set ( 'html_errors', false );
ini_set ( 'error_reporting', E_ALL );

//////////////////////////////////////////////////////////////////////////////////////////

define ( 'DS', DIRECTORY_SEPARATOR );
define ( 'ROOT_DIR',        dirname ( __FILE__ ) );
define ( 'UPDATES_DIR',     ROOT_DIR.DS.'nod' );

//////////////////////////////////////////////////////////////////////////////////////////

phpinfo();
exit;

header( 'Content-type: text/plain; charset=Windows-1251' );

nod32::load_updates();

class nod32
{
	static public final function load_updates()
	{

		var_export( self::get( 'http://update.eset.com/eset_upd/update.ver' ) );
		
	}
	
	static private final function get( $url )
	{
		$s = curl_init();

		curl_setopt($s, CURLOPT_URL, $url );
		
		curl_setopt($s,CURLOPT_RETURNTRANSFER, true );
		curl_setopt($s,CURLOPT_HEADER, false );

		$data = curl_exec($s);
		$info = curl_getinfo($s,CURLINFO_HTTP_CODE);
		curl_close($s); 
		return array( 'info' => $info, 'data' => $data );
	}
	
	
}





?>