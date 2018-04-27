<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////


if( !defined( 'CONFIG_FILE' ) ){ define( 'CONFIG_FILE', CORE_DIR.DS.'config.php' ); }

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }

class config
{
	use basic;
	
	static public final function get()
	{
		if( !file_exists( CONFIG_FILE ) ){ return array(); }
		return require( CONFIG_FILE );
	}
	
	static public final function set( $config )
	{
	    if( !defined('CMS_KEY') ){ define( 'CMS_KEY', false ); }
		$config = array_merge( self::get(), $config );
		$config['key'] = ( !isset($config['key']) || $config['key'] != CMS_KEY )?md5( str_shuffle(microtime(1)) ):$config['key'];
        $key = $config['key'];
		
		ob_start();
			var_export( $config );
		$config = ob_get_clean();
		$config = '<?php /* CONFIG CREATED: '.microtime(true).' ('.date('Y-m-d H:i:s').') */'."\n"
                    .'if(!defined(\'CMS_KEY\')){ define( \'CMS_KEY\', \''.$key.'\' ); }'."\n"
                    .'return '.$config.';'."\n".'?>';
		
		return self::write_file( CONFIG_FILE, $config );
	}	
	
}

?>