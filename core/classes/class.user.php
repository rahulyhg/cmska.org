<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }
if( !trait_exists( 'login' ) ){ require( CLASSES_DIR.DS.'trait.login.php' ); }
if( !trait_exists( 'db_connect' ) ){ require( CLASSES_DIR.DS.'trait.db_connect.php' ); }

class user
{
	use basic, 
		login, 
		db_connect;
	
	public final function __construct()
	{
		$this->__cconnect_2_db();
	}

    public final function get_user_param( $param, $user_id = false )
    {
        if( !$user_id ){ $user_id = CURRENT_USER_ID; }
        $param = self::totranslit( self::filter( $param ) );

        $data = $this->get_all_user_data( CURRENT_USER_ID );

        if( !$data ){ return false; }

        if( !isset( $data[$param] ) )
        {
            self::err( 'Значение переданное в качестве параметра не существует в массиве не существует в '.__CLASS__.'::'.__METHOD__ );
            exit;
        }

        return $data[$param];
    }

    private final function get_all_user_data( $user_id = false )
    {
        $user_id = abs( intval( $user_id ) );
        if( !$user_id )
        {
            self::err( 'USER_ID must be INTEGER at '.__CLASS__.'::'.__METHOD__ );
            exit;
        }

        $SQL = 'SELECT * FROM users WHERE id = '.$user_id.';';
        $SQL = $this->db->query( $SQL );
        $data = $this->db->get_row( $SQL );
        $this->db->free( $SQL );
        return $data;
    }

}

?>