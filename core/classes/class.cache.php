<?php
/**
 * class.cache.php
 *
 * клас для роботи з кешем
 *
 * @category  class
 * @package   cmska.org
 * @author    MrGauss <author@cmska.org>
 * @copyright 2018
 * @license   GPL
 * @version   0.4
 */

/**
 * [CLASS/FUNCTION INDEX of SCRIPT]
 *
 *     43 class cache
 *
 * TOTAL FUNCTIONS: 0
 * (This index is automatically created/updated by the WeBuilder plugin "DocBlock Comments")
 *
 */



//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

/**
 * Клас для роботи з системою кешування даних
 *
 * @author    MrGauss <author@cmska.org>
 * @package   cmska.org
 */
class cache
{
    use basic;

    final public static function clean( $prefix = false )
    {
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



    final public static function set( $name, $data, $log = false )
    {
        $name = self::get_cache_file_path( $name );
        ob_start();
        var_export( $data );
        $data = '<?php if( !defined(\'GAUSS_CMS\') ){ echo basename(__FILE__); exit; }'."\n".' /* CACHE CREATED: '.microtime(true).' ('.date('Y-m-d H:i:s').') */'."\n".'return '.ob_get_clean().'; '."\n".'?>';
        $data = trim( $data );
        return self::write_file( $name, $data, $log );
    }



    final public static function get( $name )
    {
        $name = self::get_cache_file_path( $name );

        if( !file_exists($name) ){ return false; }
        if( ! ( ( filemtime($name) + 60*60 ) > time() ) )
        {
            unlink( $name );
            return false;
        }

        return require( $name );
    }


    final private static function get_cache_file_path( $name )
    {
        return CACHE_DIR.DS.'cache-'.self::strtolower( trim( $name ) ).'.'.DOMAIN.'.php';
    }
}

?>