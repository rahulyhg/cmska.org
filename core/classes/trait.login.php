<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

trait login
{
    private static $TOKEN_UPD_TIME = 900;
	private static $PASS_SALT = 'NKDlkvro83,sv-2l;mf2emopfv';
	
	private $logged = false;

	public final function is_logged()
	{
		return $this->logged;
	}
	

	
	public final function check_auth()
	{
		$login = false;
		$pass  = false;
		$token = false;

		if( isset($_POST['login']) && isset($_POST['pass']) )
		{
		  $login = self::filter( $_POST['login'] );
		  $pass  = self::passencode( $_POST['pass'] );
          $_POST['login'] = false;
          $_POST['pass'] = false;
		}
		elseif( isset($_SESSION['token']) ){ $token  = strip_tags( $_SESSION['token'] ); }
		elseif( isset($_COOKIE['token']) ){  $token  = strip_tags( $_COOKIE['token'] ); }
		else
		{
			define( 'CURRENT_USER_ID', false );	
			return false; 
		}

		if( ($login && $pass) || $token )
		{
			if( $login && $pass )
			{
				$this->logged = $this->check_login_pass( $login, $pass );
				if( $this->logged ){ $token = $this->update_token(); }
                define( '_TRY_PASS_LOG_IN', true );
			}
			elseif( $token )
			{
				$this->logged = $this->check_token( $token );
                define( '_TRY_SESSION_LOG_IN', true );
			}
			
			
			if( $this->logged )
			{
				self::set_cookie( 'token', $token );
				$_SESSION['token'] = $token;
				return true;
			}			
		}
		else
		{
			define( 'CURRENT_USER_ID', false );
		}
	}

    public final function get_curr_user_info()
    {
        return $this->get_users( array( 'user.id' => CURRENT_USER_ID ) )[CURRENT_USER_ID];
    }

    private final function get_users( $filters = array() )
    {
        $filters['user.id'] = isset($filters['user.id'])?self::integer( $filters['user.id'] ):false;

        $SELECT = array();
        $FROM   = array();
        $WHERE  = array();

        $SELECT['users.id']         = 'user.id';
        $SELECT['users.login']      = 'user.login';
        $SELECT['users.email']      = 'user.email';
        $SELECT['users.group_id']   = 'user.group_id';

        $FROM['users'] = 'users as users';

        if( $filters['user.id'] !== false )
        {
            $WHERE['user.id'] = 'users.id = '.$filters['user.id'].'';
        }

        foreach( $SELECT as $k=>&$v ){ $v = ''.$k.' as "'.$v.'"'; }
        $SQL = 'SELECT '."\n\t".implode( ','."\n\t", $SELECT )."\n".'FROM '.implode(' ', $FROM ).' '.(count($WHERE)?"\n".'WHERE '.implode( $WHERE, ' AND ' ):'')."\n".'ORDER by users.id;'.QUERY_CACHABLE;

        $var = 'user-data'.self::md5($SQL);
        $data = cache::get( $var );
        if( is_array($data) && count($data) ){ return $data; }

        $SQL = $this->db->query( $SQL );
        while( $row = $this->db->get_row($SQL) )
        {
            $data[$row['user.id']] = array();
            foreach( $row as $k=>$v )
            {
                $k = explode('.',$k,2);
                if(!isset($data[$row['user.id']][$k[0]])){ $data[$row['user.id']][$k[0]] = array(); }
                $data[$row['user.id']][$k[0]][$k[1]] = $v;
            }
        }

        cache::set( $var, $data );

        return $data;
    }

	private final function update_token()
	{
		$token = str_shuffle( sha1( mt_rand( 0, 99999 ) ) );
		$token = self::passencode( $token.USER_IP );

		$SQL = 'UPDATE users SET token=\''.$token.'\', last_ip=\''.USER_IP.'\' WHERE id = '.abs(intval(CURRENT_USER_ID)).';';
		$this->db->query( $SQL );
		
		return $token;
	}

	private final function check_token( $token )
	{
		$token = $this->strtolower( $this->db->safesql( $token ) );

		$SQL = 'SELECT
                        id,
                        last_ip,
                        ( extract(epoch from NOW()::timestamp) - extract(epoch from token_upd_time::timestamp) )::integer as token_time_diff
                        FROM
                        users WHERE token=\''.$token.'\' AND last_ip=\''.USER_IP.'\' LIMIT 1 OFFSET 0;';

		$id = $this->db->super_query( $SQL );

		if( is_array($id) && isset($id['id']) && isset($id['token_time_diff']) && self::integer( $id['token_time_diff'] ) < self::$TOKEN_UPD_TIME )
		{
			$id = self::integer( $id['id'] );
			define( 'CURRENT_USER_ID', $id );
			$SQL = 'UPDATE users SET last_ip=\''.USER_IP.'\', token_upd_time = NOW()::timestamp WHERE id = '.CURRENT_USER_ID.';';
			$this->db->query( $SQL );
		}
		else
		{
			define( 'CURRENT_USER_ID', false );
		}
		
		return CURRENT_USER_ID?true:false;
	}		
	
	private final function check_login_pass( $login, $pass )
	{
		$login = $this->strtolower( $this->db->safesql( $login ) );
		$pass  = $this->db->safesql( $pass );
		
		$SQL = 'SELECT id FROM users WHERE email=\''.$login.'\' and password=\''.$pass.'\' LIMIT 1 OFFSET 0;';
		$id = $this->db->super_query( $SQL );
		
		if( is_array($id) && isset($id['id']) )
		{ 
			$id = $id['id']; 
			define( 'CURRENT_USER_ID', abs(intval($id)) );
		}
		else
		{
			define( 'CURRENT_USER_ID', false );
		}
		
		return CURRENT_USER_ID?true:false;
	}	
	
	private final static function passencode( $str )
	{
		$i = 32;
		while( $i > 0 )
		{
			$i--;
			$str = self::md5( base64_encode( sha1( self::$PASS_SALT ) . sha1( $str ) ) . $str . strrev( $str ) );
		}
		return $str;
	}
	
	public final static function set_cookie( $name, $value )
	{
		$expires = time() + (self::$TOKEN_UPD_TIME);
		setcookie( $name, $value, $expires, "/", DOMAIN, TRUE, TRUE );
	}

	public static final function start_session( $sid = false )
	{
		$params = session_get_cookie_params();
		$params['domain'] = DOMAIN;

		$params['secure'] = true;
		$params['httponly'] = true;
		$params['lifetime'] = self::$TOKEN_UPD_TIME;

        session_set_cookie_params($params['lifetime'], "/", $params['domain'], $params['secure'], true );

		if ( $sid ){ session_id( $sid );  }
		session_start();
	}

    public final function logout()
    {
        self::set_cookie( 'token', false );
        session_destroy();
        header( 'Location: '.HOME );
        exit;
    }
	
}

?>