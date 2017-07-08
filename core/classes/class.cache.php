<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

class cache
{
    use basic;

    static public final function mem_init( $server, $port )
    {
        if( isset($GLOBALS['_MEMCACHE']) && is_object($GLOBALS['_MEMCACHE']) )
        {
            $GLOBALS['_MEMCACHE']->close();
        }

        $GLOBALS['_MEMCACHE'] = false;
        $GLOBALS['_MEMCACHE'] = new Memcached();
        $GLOBALS['_MEMCACHE']->addServer( $server, $port );
    }

    static public final function clean( $prefix = false )
    {
        if( isset($GLOBALS['_MEMCACHE']) && is_object($GLOBALS['_MEMCACHE']) )
        {
            self::mem_init( 'unix:/var/run/memcached.sock', 0 );
            return true;
        }

        $prefix = self::strtolower( $prefix );

        $cache_dir = opendir( CACHE_DIR );
        while( ($file = readdir($cache_dir)) !== false )
        {
            if( is_file( CACHE_DIR.DS.$file ) === false ){ continue; }

            if( $prefix )
            {
                if( strpos( $file, 'cache-'.$prefix )!==false )
                {
                    unlink( CACHE_DIR.DS.$file );
                }
            }
            else
            {
                unlink( CACHE_DIR.DS.$file );
            }

        }
        closedir($cache_dir);
        return true;
    }

    static public final function set( $name, $data, $log = false )
    {
        if( isset($GLOBALS['_MEMCACHE']) && is_object($GLOBALS['_MEMCACHE']) )
        {
            $GLOBALS['_MEMCACHE']->delete( md5($name) );
            $GLOBALS['_MEMCACHE']->set( md5($name), $data );
            return true;
        }

        $name = self::get_cache_file_path( $name );
        ob_start();
        var_export( $data );
        $data = '<?php if( !defined(\'GAUSS_CMS\') ){ echo basename(__FILE__); exit; }'."\n".' /* CACHE CREATED: '.microtime(true).' ('.date('Y-m-d H:i:s').') */'."\n".'return '.ob_get_clean().'; '."\n".'?>';
        $data = trim( $data );
        return self::write_file( $name, $data, $log );
    }

    static public final function get( $name )
    {
        if( isset($GLOBALS['_MEMCACHE']) && is_object($GLOBALS['_MEMCACHE']) )
        {
            return $GLOBALS['_MEMCACHE']->get( md5($name) );
        }

        $name = self::get_cache_file_path( $name );
        if( !file_exists($name) ){ return false; }
        if( filemtime($name)>time()-60*60 )
        {
            unlink( $name );
            return false;
        }
        return require( $name );
    }

    static private final function get_cache_file_path( $name )
    {
        return CACHE_DIR.DS.'cache-'.self::strtolower( trim( $name ) ).'.'.DOMAIN.'.php';
    }
}

//////////////////////////////////////////////////////////////////////////////////////////

$_MEMCACHE = false;

if( defined('CACHE_TYPE') && CACHE_TYPE == 'MEM' )
{
    cache::mem_init( 'unix:/var/run/memcached.sock', 0 );
}

//////////////////////////////////////////////////////////////////////////////////////////

?>
