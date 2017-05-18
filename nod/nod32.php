<?php

error_reporting ( E_ALL );
ini_set ( 'display_errors', true );
ini_set ( 'html_errors', false );
ini_set ( 'error_reporting', E_ALL );
ini_set ( 'max_execution_time', 60 );
set_time_limit( 60 );

//////////////////////////////////////////////////////////////////////////////////////////

define ( 'DS', DIRECTORY_SEPARATOR );
define ( 'ROOT_DIR',        dirname ( __FILE__ ) );
define ( 'UPDATES_DIR',     ROOT_DIR.DS.'nod' );
define ( 'UPD_SERVER',     'http://update.eset.com/' );

//////////////////////////////////////////////////////////////////////////////////////////

header( 'Content-type: text/plain; charset=Windows-1251' );

if( !file_exists(ROOT_DIR.DS.'keys.txt') || !filesize(ROOT_DIR.DS.'keys.txt') || filemtime(ROOT_DIR.DS.'keys.txt') > time()-60*60*24 )
{
    //nod32::load_pass( 'http://keynod.blogsky.com/' );
}

nod32::get_pass();


class nod32
{
	static public final function get_pass()
    {
      if( !file_exists(ROOT_DIR.DS.'keys.txt') ){ exit; }
      $keys = explode( "\n", trim(file_get_contents(ROOT_DIR.DS.'keys.txt')) );
      $keys = array_map( 'trim', $keys );

      foreach( $keys as $id=>$line )
      {
        unset($keys[$id]);
        $line = explode( ':', $line );
        $keys[$line[0]] = $line[1];
      }

      $_active = false;
      $login    = false;
      $pass     = false;

      while( $_active == false )
      {
        $login    = array_keys($keys);
        shuffle( $login );
        $login    = $login[0];
        $pass     = $keys[$login];

        $url = preg_replace( '!^(.+?)(:\/\/)(.+?)$!is', '$1$2'.$login.':'.$pass.'@$3', UPD_SERVER );
        $url = $url.'v3-rel-sta/mod_041_w10upgrade_1018/em041_32_l2.nup';
        echo $url."\n";
        //$_active = self::get( $url, true );
        //var_export($_active);
        //exit;
        break;
      }

      //self::load_updates( $login, $pass );
    }

	static public final function load_pass( $url )
    {
      $data = strip_tags( self::get( $url )['data'] );
      $data = str_replace( ' ', '', $data );

      preg_match_all( '!((TRIAL|EAV)-(\d{10}))(.+?)([a-z0-9]{10})!is', $data, $data );
      $data = array_combine( $data[1], $data[5] );

      foreach( $data as $k=>$v )
      {
        $data[$k] = trim($k.':'.$v);
      }
      $data = implode( "\n", $data );

      $fopen = fopen( ROOT_DIR.DS.'keys.txt', 'w' );
               fwrite( $fopen, $data );
               fclose( $fopen );
      return true;
    }

	static public final function load_updates( $login, $pass )
	{
	  $data = self::get( UPD_SERVER.'eset_upd/update.ver' );
	  if( abs(intval($data['info'])) == 200 )
      {
        $fopen = fopen( ROOT_DIR.DS.'update.rar', 'w' );
                 fwrite( $fopen, $data['data'] );
                 fclose( $fopen );
        $data = true;
      }else{ $data = false; }

      $data = self::get( UPD_SERVER.'eset_upd/expire.rar' );
      if( abs(intval($data['info'])) == 200 )
      {
        $fopen = fopen( ROOT_DIR.DS.'expire.rar', 'w' );
                 fwrite( $fopen, $data['data'] );
                 fclose( $fopen );
        $data = true;
      }else{ $data = false; }

      if( $data === true && file_exists(ROOT_DIR.DS.'update.rar') )
      {
        if( file_exists(ROOT_DIR.DS.'update.ver') ){ unlink(ROOT_DIR.DS.'update.ver'); }
            exec( '7z e \''. ROOT_DIR.DS.'update.rar' .'\'' );

        if( !file_exists(ROOT_DIR.DS.'update.ver') ){ $data = false; }
      }


      if( file_exists(ROOT_DIR.DS.'update.ver') )
      {
        $data = file_get_contents( ROOT_DIR.DS.'update.ver' );
        preg_match_all( '!file\=(.{2,})!', $data, $data );

        $data = array_map( 'trim', $data[1] );

      }

	}
	
	static private final function make_copy( $url )
    {
      if( substr( $url, 0, 1 ) == '/' ){ $url = substr( $url, 1 ); }
      echo UPD_SERVER.$url;
      exit;

    }

	static private final function get( $url, $headers_only = false )
	{
		$s = curl_init();

		curl_setopt($s, CURLOPT_URL, $url );
		
		curl_setopt($s,CURLOPT_CONNECTTIMEOUT, 15 );
		curl_setopt($s,CURLOPT_TIMEOUT, 20 );
		curl_setopt($s,CURLOPT_RETURNTRANSFER, true );
		curl_setopt($s,CURLOPT_HEADER, $headers_only );

        if( $headers_only )
        {
            curl_setopt($s,CURLOPT_NOBODY, true );
        }

		$data = curl_exec($s);
		$info = curl_getinfo($s,CURLINFO_HTTP_CODE);
		curl_close($s); 
		return array( 'info' => $info, 'data' => $data );
	}
	
	
}





?>