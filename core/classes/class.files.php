<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic'  ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }
if( !trait_exists( 'db_connect'  ) ){ require( CLASSES_DIR.DS.'trait.db_connect.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

class files
{
    use basic, db_connect;

    const KEYREPL = 'abcdefghijklmpnorstuvwxyz1234567890-+=*@${}^&';
    const BLOCKSIZE = 8192;

    public static final function _upload_process( $file, $config )
    {
		$cms_config = config::get();

		foreach (array( 'upload.max.filesize', 'upload.file.ext', 'upload.file.encode' ) as $key)
		{
			if (!isset($config[$key]))
			{
				if( !isset($cms_config[$key]) )
				{
					self::err('' . __CLASS__ . '::' . __METHOD__ . ' >> $config[\'' . $key . '\'] not exist!');
				}
				$config[$key] = $cms_config[$key];
			}
			$config[$key] = self::integer(!isset($config[$key]) ? $config[$key] : $config[$key]);
		}

		$file['fileinfo'] = self::fileinfo( $file['filename'], FILEINFO_MIME_TYPE );
		$file['md5'] = md5_file( $file['filename'] );
		$file = self::file_encode( $file );

        self::ins2db( $file );

        return $file;
    }

    private static final function get_new_keyring()
	{
		$keyring = str_shuffle( self::KEYREPL );

		$key_replace = array();
		$l = strlen($keyring);
		for( $i = 0; $i < $l; $i++ )
		{
			$key_replace[substr( $keyring, $l-$i-1, 1 )] = substr( $keyring, $i, 1 );
		}
		return $key_replace;
	}

    private static final function file_encode( array $file )
	{
		$path2encoded_file = dirname($file['filename']).DS.'encoded:'.basename($file['filename']);
		$original_file = fopen($file['filename'], 'rb');
		$encoded_file  = fopen($path2encoded_file, 'w');

		$keyring = self::get_new_keyring();

		$key_str = implode('', array_keys($keyring)).implode('', array_values($keyring));


		fwrite( $encoded_file, $key_str );

		while (!feof($original_file))
		{
			fwrite( $encoded_file, self::_encode( fread($original_file, self::BLOCKSIZE ), $keyring ) );
		}
		fclose($original_file);
		fclose($encoded_file);

		unlink( $file['filename'] );

		$file['encoded'] = true;
		$file['filename'] = $path2encoded_file;
		$file['keyring'] = array( implode('',array_keys($keyring)), implode('',array_values($keyring)) );

		return $file;
	}

	private static final function _encode( $string, $keyring )
	{
		$string = strtr( $string, $keyring );
		return $string;
	}

	private static final function _decode( $string, $keyring )
	{
		$string = strtr( $string, $keyring );
		return $string;
	}

	private static final function get_keyring_from_file( $path2file )
	{
		$len = self::strlen( self::KEYREPL );

		$_file = fopen( $path2file, 'rb');
		$key = fread($_file, $len * 2 );
		fclose( $_file );

		$rawkey = array
		(
			substr( $key, 0, $len ),
			substr( $key, $len, $len ),
		);

		$keyring = array();
		for( $i = 0; $i < $len; $i++ )
		{
			$keyring[ substr( $rawkey[1], $len-$i-1, 1 ) ] = substr( $rawkey[0], $len-$i-1, 1 );
		}


		return $keyring;
	}

	public static final function download( $file_id = 0 )
	{

        $file_id = self::integer( $file_id );
        if( !$file_id ){ return false; }

        $file = array();

        $file['filename']= ROOT_DIR.'/uploads/files/2018-05-05/encoded:3e09ea85d371004659c1ac15e0f3a2215d7a7dc8.scms';
        $file['mime'] = 'application/pdf';
        $file['size'] = 602783;
        $file['name']= 'Начало жизни вашего ребенка 2008.pdf';

        self::_headers( $file );

		$keyring = self::get_keyring_from_file( $file['filename'] );

		$_file = fopen( $file['filename'], 'rb');

		fseek( $_file, self::strlen( self::KEYREPL )*2 );

		while (!feof($_file))
		{
			echo self::_decode( fread( $_file, self::BLOCKSIZE ), $keyring );
            usleep( 1000 );
		}

		fclose( $_file );

        exit;
	}

    private static final function _headers( array $file )
    {
        header( $_SERVER['SERVER_PROTOCOL'] . " 200 OK" );
		header( "Pragma: public" );
		header( "Expires: 0" );
		header( "Cache-Control: must-revalidate, post-check=0, pre-check=0");
		header( "Cache-Control: private", false);
		header( "Content-Type: " . $file['mime'] );
		header( 'Content-Disposition: attachment; filename="' . $file['name'] . '"' );
		header( "Content-Transfer-Encoding: binary" );
        header( "Content-Length: " . $file['size'] );
        header("Connection: close");
    }

    public static final function update( int $post_id )
    {

    }

    private static final function ins2db( array $array )
    {
        $files = new files;

        $_2db = array();
        $_2db['post_id']        = self::integer( isset($array['post_id'])?$array['post_id']:0 );
        $_2db['user_id']        = self::integer( CURRENT_USER_ID?CURRENT_USER_ID:0 );
        $_2db['size']           = self::integer( $array['size'] );
        $_2db['md5']            = $files->db->safesql( $array['md5'] );
        $_2db['mime']           = $files->db->safesql( $array['type'] );
        $_2db['orig_name']      = $files->db->safesql( $array['name'] );
        $_2db['encoded']        = boolval($array['encoded'])?1:0;
        $_2db['load_time']      = date( 'Y-m-d H:i:s', time() );
        $_2db['keyring']        = ($_2db['encoded'] && isset($array['keyring']) && is_array($array['keyring']))?implode('', $array['keyring']):'';

        var_export($_2db);

        return $array;

    }

}

?>