<?php
/**
 * index.php
 *
 * Єдина точка входу в CMS
 *
 * @category  main
 * @package   cmska.org
 * @author    MrGauss <author@cmska.org>
 * @copyright 2018
 * @license   GPL
 * @version   0.4
 */

/**
 * [CLASS/FUNCTION INDEX of SCRIPT]
 *
 * TOTAL FUNCTIONS: -
 * (This index is automatically created/updated by the plugin "DocBlock Comments")
 *
 */


/**
 * Тимчасовий захід - на стадії розробки CMS виводить phpinfo() для усих відвідувачів
 * окрім розробників
 */
if( $_SERVER['HTTP_X_REAL_IP'] != '217.115.100.95' && strpos( $_SERVER['HTTP_X_REAL_IP'], '192.168' ) === false )
{
    ob_start();
	phpinfo();
    $data = ob_get_clean();

    $data = preg_replace( '!<style(.+?)style>!is', '<link rel="stylesheet" type="text/css" href="/tpl/default/css/phpinfo.css" />', $data );

    echo $data;
    exit;
}


error_reporting ( E_ALL );
ini_set ( 'display_errors', true );
ini_set ( 'html_errors', false );
ini_set ( 'error_reporting', E_ALL );
define ( 'DOMAIN',          'cmska.org' );
define ( 'HOME',            '/' );
define ( 'SCHEME',          strtolower( explode(':',$_SERVER['SCRIPT_URI'])[0] ) );
define ( 'HOMEURL',         SCHEME.'://'.DOMAIN.HOME );
define ( 'GAUSS_CMS',       true );
define ( 'DS',              DIRECTORY_SEPARATOR );
define ( 'ROOT_DIR',        dirname ( __FILE__ ) );
define ( 'CORE_DIR',        ROOT_DIR.DS.'core' );
define ( 'CLASSES_DIR',     CORE_DIR.DS.'classes' );
define ( 'CACHE_DIR',       ROOT_DIR.DS.'cache' );
define ( 'MODS_DIR',        CORE_DIR.DS.'mod' );
define ( 'TPL_DIR',         ROOT_DIR.DS.'tpl' );
define ( 'UPL_DIR',         ROOT_DIR.DS.'uploads' );
define ( 'USER_IP',         $_SERVER['REMOTE_ADDR'] );
define ( 'CHARSET',         'Windows-1251' /*'CP1251'*/ );
define ( 'CACHE_TYPE',      'FILE' /*MEM | FILE*/ );


header( 'Content-type: text/html; charset='.CHARSET );
ob_start();


/**
 * Підключення обробника помилок
 */
require( CLASSES_DIR.DS.'class.err_handler.php' );
err_handler::start();

/**
 * Підключення ядра
 */
require( CORE_DIR.DS.'init.php' );


/**
 * Виведення даних
 */

        $tpl->load( 'content' );
        $tpl->compile( 'content' );
echo    $tpl->result( 'content' )."\n".'<!-- Used memory: '.round(memory_get_peak_usage()/1024,2).' kb -->';

exit;

?>