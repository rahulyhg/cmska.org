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

    public final static function array2html( $data )
    {

        $html = array();
        foreach( $data as $categ => $array )
        {
            $html[] = '<td colspan="2" class="categ">'.$categ.'</td>';
            foreach( $array as $key => $value )
            {
                $html[] =  '<td class="key">'.$key.'</td><td class="val">'.$value.'</td>';
            }
        }
        $html = '<tr>'.implode('</tr><tr>', $html).'</tr>';
        $html = '<table class="stats">'.$html.'</table>';
        return $html;
    }

    public final static function get_stats()
    {
        $stats = new stats;
        $data = array();

        $data['server'] = array();
        $data['server']['OS'] = php_uname();   

        $data['db'] = $stats->db->pg_version();

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
        $data['php']['php_ini_scanned_files'] = implode( '<br>', explode(',',php_ini_scanned_files()) );

        $data['php_extensions'] = array();
        foreach (get_loaded_extensions() as $i => $ext)
        {
            $data['php_extensions'][$ext] = explode('-', phpversion($ext))[0];
        }



        return $data;
    }



}

?>