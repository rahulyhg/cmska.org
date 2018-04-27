<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }
if( !trait_exists( 'db_connect' ) ){ require( CLASSES_DIR.DS.'trait.db_connect.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

class tags
{
    use basic, db_connect;

    const CACHE_VAR_TAGS = 'tags';

    public final static function tag_decode( $tag )
    {
        return self::utf2win( self::urldecode( $tag ) );
    }

    public final function get_url( $tag, $category = false )
    {
        return ($category?$category:HOME).'tag:'.self::urlencode(self::win2utf( $tag )).'/';
    }

    public final function get_id( $tag )
    {
        foreach( $this->get_tags() as $id => $data )
        {
            if( $data['name'] == $tag )
            {
                return $id;
            }
        }
        return false;
    }

    public final function get_tags()
    {
        $data = cache::get( self::CACHE_VAR_TAGS );

        if( !$data || !is_array($data) || !count($data) )
        {
            $SQL = 'SELECT id, name, altname  FROM tags WHERE id > 0 ORDER BY name; '.QUERY_CACHABLE;
            $SQL = $this->db->query( $SQL );

            $data = array();
            while( ($row = $this->db->get_row($SQL)) != false )
            {
                $data[$row['id']] = self::stripslashes( $row );
                $data[$row['id']]['name'] = self::htmlspecialchars( $data[$row['id']]['name'] );
                $data[$row['id']]['altname'] = self::totranslit( $data[$row['id']]['altname'] );
            }
            $this->db->free( $SQL );
            cache::set( self::CACHE_VAR_TAGS, $data );
        }

        return $data;
    }

}

?>