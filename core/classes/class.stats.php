<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }
if( !trait_exists( 'db_connect' ) ){ require( CLASSES_DIR.DS.'trait.db_connect.php' ); }

class stats
{
    use basic,
        db_connect;

    public final function __construct()
    {
        $this->__cconnect_2_db();
    }

    static public final function ins2html( $html )
    {
        if( $GLOBALS['db'] && is_object($GLOBALS['db']) )
        {
            $db = &$GLOBALS['db'];
        }
        else
        {
            $db = false;
        }

        if( $db && isset($db->counters['queries']) )
        {
            $html = str_replace( '{stats:queries}', $db?$db->counters['queries']:0, $html );
        }

        if( $db && isset($db->counters['cached']) )
        {
            $html = str_replace( '{stats:cached}', $db?$db->counters['cached']:0, $html );
        }

        $html = str_replace( '{stats:used_memory}', common::integer2size(memory_get_peak_usage()), $html );
        $html = preg_replace( '!\{stats:(.+?)\}!i', '0', $html );

        return $html;
    }

    private final static function get_folder_size( $dir )
    {
        $size = 0;
        if( !is_dir( $dir ) ){ return $size; }

        foreach( scandir( $dir ) as $name )
        {
            if( $name == '.' || $name == '..' ){ continue; }

            $name = $dir.DS.$name;

            if( is_file( $name ) ){ $size = $size + filesize( $name ); }
            if( is_dir( $name ) ) { $size = $size + self::get_folder_size( $name ); }
        }
        return $size;
    }

    public final static function get_html_stats()
    {
        $tpl = new tpl;
        $tpl->load( 'stats' );

        foreach( self::get_stats() as $categ => $array )
        {
            if( !is_array($array) ){ continue; }
            foreach( $array as $k => $v )
            {
                $tpl->set( '{'.$categ.':'.$k.'}', $v );
            }
        }

        $tpl->compile( 'stats' );
        return $tpl->result( 'stats' );
    }

    public final static function array2html( $data )
    {

        $html = array();
        foreach( $data as $categ => $array )
        {
            $html[$categ] = array();
            $html[$categ][] = '<tr><td colspan="2" class="categ">'.$categ.'</td></tr>';
            foreach( $array as $key => $value )
            {
                $html[$categ][] =  '<tr data-key="'.$key.'"><td class="key">'.$key.'</td><td class="val">'.$value.'</td></tr>';
            }
            $html[$categ] = '<table data-categ="'.$categ.'" class="full_stats">'.implode('',$html[$categ]).'</table>';
        }
        $html = ''.implode('', $html).'';
        return $html;
    }



    public final static function get_stats()
    {
        $stats = new stats;
        $data = array();

        $data['server'] = array();
        $data['server']['os'] = PHP_OS.' '.php_uname('r');
        $data['server']['disk_free_space'] =    self::integer2size(disk_free_space(ROOT_DIR));
        $data['server']['disk_total_space'] =   self::integer2size(disk_total_space(ROOT_DIR));
        $data['server']['used_size'] =          self::integer2size(self::get_folder_size(ROOT_DIR));
        $data['server']['cache_size'] =          self::integer2size(self::get_folder_size(CACHE_DIR));

        $data['postgresql'] = $stats->db->pg_version();
        $data['postgresql']['db_size'] = $stats->db->dbsize();

        $data['server']['db_type'] = explode( ' ', $data['postgresql']['server'] )[0];

        $data['php'] = array();
        $data['php']['user'] = $_SERVER['USER'];
        $data['php']['version'] = phpversion().' '.php_sapi_name();
        $data['php']['zend'] = zend_version();
        $data['php']['extensions'] = implode( ', ', get_loaded_extensions() );
        $data['php']['allow_url_fopen'] = abs(intval(ini_get('allow_url_fopen')))?'YES':'NO';
        $data['php']['allow_url_include'] = abs(intval(ini_get('allow_url_include')))?'YES':'NO';
        $data['php']['display_errors'] = abs(intval(ini_get('display_errors')))?'YES':'NO';
        $data['php']['max_file_uploads'] = ini_get('max_file_uploads');
        $data['php']['memory_limit'] = ini_get('memory_limit');
        $data['php']['max_execution_time'] = ini_get('max_execution_time');
        $data['php']['max_input_time'] = ini_get('max_input_time');
        $data['php']['open_basedir'] = preg_replace( '!'.addslashes(dirname(ROOT_DIR)).'!is', '', str_replace( PATH_SEPARATOR, '<br>', ini_get('open_basedir') ) );
        $data['php']['upload_tmp_dir'] = preg_replace( '!'.addslashes(dirname(ROOT_DIR)).'!is', '', str_replace( PATH_SEPARATOR, '<br>', ini_get('upload_tmp_dir') ) );
        $data['php']['error_log'] = preg_replace( '!'.addslashes(dirname(ROOT_DIR)).'!is', '', ini_get('error_log') );
        $data['php']['suhosin_log'] = preg_replace( '!'.addslashes(dirname(ROOT_DIR)).'!is', '', ini_get('suhosin.log.file.name') );
        $data['php']['disable_functions'] = str_replace( ',', ', ', ini_get('disable_functions') );
        $data['php']['default_mimetype'] = ini_get('default_mimetype');
        $data['php']['default_charset'] = ini_get('default_charset');
        $data['php']['date.timezone'] = ini_get('date.timezone');
        $data['php']['suhosin.simulation'] = abs(intval(ini_get('suhosin.simulation')))?'YES':'NO';
        $data['php']['suhosin.disable_eval'] = abs(intval(ini_get('suhosin.executor.disable_eval')))?'YES':'NO';
        $data['php']['php_ini_loaded_file'] = php_ini_loaded_file();

        /*$data['php_extensions'] = array();
        foreach (get_loaded_extensions() as $i => $ext)
        {
            $data['php_extensions'][$ext] = explode('-', phpversion($ext))[0];
            if( !$data['php_extensions'][$ext] ){ unset($data['php_extensions'][$ext]); }
        }*/

        return $data;
    }



}

?>