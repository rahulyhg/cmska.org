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
		$file['md5']      = self::md5_file( $file['filename'] );
		$file             = self::file_encode( $file );

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

	public static final function decode_url( $keyline )
    {
        if( !$keyline ){ return false; }

        $keyline = self::urldecode( $keyline );
        $keyline = self::decode_string( $keyline );

        $key = substr( $keyline, 0, 32 );
        $md5 = substr( $keyline, -32, 32 );
        $name = str_replace( $key, '', str_replace( $md5, '', $keyline ) );
        $name = strlen($name) < 3 ? false : $name;

        if( self::strlen( $key ) != 32 || self::strlen( $md5 ) != 32 ){ return false; }

        $name = self::decode_string( $name );

        $cms_config = config::get();

        $chkey = md5( sha1( sha1($md5) . sha1($cms_config['key']) ) . date('Y.m.d') );

        if( $chkey == $key ){ return array( 'name' => $name, 'md5' => $md5 ); }
        return false;
    }

	public static final function make_url( $md5 = false, $new_name = false )
    {
        $cms_config = config::get();
        if( !$md5 ){ return false; }

        $new_name = false;

        $key = md5( sha1( sha1($md5) . sha1($cms_config['key']) ) . date('Y.m.d') ).($new_name?self::encode_string($new_name):'').$md5;
        $key = self::encode_string( $key );
        $key = self::urlencode( $key );

        if( self::integer( $cms_config['enable_chpu'] ) )
        {
            $key = $cms_config['homeurl'].'download:'.$key.'.html';
        }
        else
        {
            $key = $cms_config['homeurl'].'?mod=download&keyline='.$key;
        }
        return $key;
    }

	public static final function download( $md5, $newname = false )
	{
        $md5 = self::filter( $md5 );
        if( !$md5 ){ return false; }

        $_cl = new files;
        $SQL = 'SELECT * FROM files WHERE md5 = \''.$md5.'\';';
        $file = $_cl->db->super_query( $SQL );

        if( !is_array($file) || !count($file) ){ exit; return false; }

        $file['parth'] = UPL_DIR.DS.'files'.DS.date( 'Y-m-d', self::strtotime($file['load_time']) ).DS.'encoded:'.$file['md5'].'.scms';

        self::_headers( $file );

		$keyring = self::get_keyring_from_file( $file['parth'] );

		$_file = fopen( $file['parth'], 'rb');

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
		header( "Cache-Control: private", false );
		header( "Content-Type: " . $file['mime'] );
		header( 'Content-Disposition: attachment; filename="' . $file['orig_name'] . '"' );
		header( "Content-Transfer-Encoding: binary" );
        header( "Content-Length: " . $file['size'] );
        header("Connection: close");
    }

    public static final function update( int $post_id )
    {

    }

    public static final function get_info( $md5 = false )
    {
        $md5 = self::filter( $md5 );
        if( !$md5 ){ return false; }

        $cache_name = posts::CACHE_VAR_POSTS.'-file-'.$md5;

        $data = cache::get( $cache_name );

        if( is_array($data) && count($data) ){ return $data; }

        //////////////////////
        cache::clean( $cache_name );
        $files = new files;
        $SQL = 'SELECT * FROM files WHERE md5 = \''.$md5.'\'; '.QUERY_CACHABLE;
        $data = $files->db->super_query( $SQL );
        $files = false;
        unset( $data['keyring'] );
        cache::set( $cache_name, $data );
        //////////////////////

        return $data;
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
        $_2db['orig_name']      = $files->db->safesql( self::totranslit($array['name']) );
        $_2db['encoded']        = boolval($array['encoded'])?1:0;
        $_2db['load_time']      = date( 'Y-m-d H:i:s', time() );
        $_2db['keyring']        = $files->db->safesql( ($_2db['encoded'] && isset($array['keyring']) && is_array($array['keyring']))?implode('', $array['keyring']):'' );

        if (!file_exists($array['filename'])){ return false; }

        $SQL = 'INSERT INTO files ("' . implode('", "', array_keys($_2db)) . '") VALUES (\'' . implode('\', \'', array_values($_2db)) . '\');';

        $files->db->query($SQL);
        $files->db->free();
        $files = false;
        return true;
    }

		/**
		 * @param int $post_id
		 * @return array
		 */
		static public final function get($post_id = 0)
		{
			$post_id = self::integer($post_id);
			$_cl = new files;
			$SQL = 'SELECT * FROM files WHERE post_id=' . $post_id . ' ORDER BY load_time DESC;';
			$SQL = $_cl->db->query($SQL);

			$files = array();
			while (($row = $_cl->db->get_row($SQL)) !== false)
			{
				$files[] = $row;
			}

			$_cl->db->free();
			$_cl = false;

			return $files;
		}


		static public final function del($hash = false)
		{
			if (!$hash)
			{
				return false;
			}

			$SQL = 'SELECT * FROM files WHERE md5=\'' . self::strtolower(self::filter($hash)) . '\';';
			$_cl = new files;
			$file = $_cl->db->super_query($SQL);
            //if( is_array($file) && count($file) > 1 ){ $file = reset( $file ); }

			if (!$file || !is_array($file) || !isset($file['orig_name']))
			{
				return false;
			}

			$url = UPL_DIR . DS . 'files' . DS . date('Y-m-d', strtotime($file['load_time'])) . DS . 'encoded:'.$file['md5'].'.scms';

			if (file_exists($url))
			{
				unlink($url);
			}

			$SQL = 'DELETE FROM files WHERE md5=\'' . $file['md5'] . '\';';


			$file = $_cl->db->query($SQL);
			$_cl->db->free();
			return true;
		}

}

?>