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

// eval( 'phpinfo(); exit;' );

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
define ( 'LOGS_DIR',        dirname ( ROOT_DIR ).DS.'logs' );
define ( 'CORE_DIR',        ROOT_DIR.DS.'core' );
define ( 'CLASSES_DIR',     CORE_DIR.DS.'classes' );
define ( 'CACHE_DIR',       ROOT_DIR.DS.'cache' );
define ( 'MODS_DIR',        CORE_DIR.DS.'mod' );
define ( 'TPL_DIR',         ROOT_DIR.DS.'tpl' );
define ( 'UPL_DIR',         ROOT_DIR.DS.'uploads' );
define ( 'USER_IP',         $_SERVER['REMOTE_ADDR'] );
define ( 'CHARSET',         'Windows-1251' /*'CP1251'*/ );
define ( 'CACHE_TYPE',      'FILE' /*MEM | FILE*/ );

setlocale ( LC_ALL, 'uk_UA.utf8' );

/*
if( preg_match( '!^192\.168\.!i', USER_IP ) )
{
    function get_photo_date( $file )
    {
        $data = exif_read_data( $file );

        if( !isset( $data['DateTimeOriginal'] ) )
        {
            if( preg_match( '!((\d{8})|(\d{4}\.\d{2}\.\d{2}))!i', basename( $file ), $m ) !== false )
            {
                if( !isset($m[1]) ){ return false; }

                if( strlen($m[1]) == 8 )
                {
                    $m[1] = substr( $m[1], 0, 4 ).'.'.substr( $m[1], 4, 2 ).'.'.substr( $m[1], 6, 2 ).' 14:09:00';
                }
                else
                {
                    $m[1] = $m[1].' 14:09:00';
                }

                $data['DateTimeOriginal'] = trim( $m[1] );
            }
            else
            {
                return false;
            }
        }else{ $data['DateTimeOriginal'] = date( 'Y.m.d H:i:s', strtotime($data['DateTimeOriginal']) ); }

        $data['DateTimeOriginal'] = explode( ' ', $data['DateTimeOriginal'], 2 );
        $data['DateTimeOriginal'] = reset( $data['DateTimeOriginal'] );

        return $data['DateTimeOriginal'];
    }
    //
    function win2utf($data)
    {
        return mb_convert_encoding($data, 'utf-8', 'cp1251');
    }

    function write( $file, $text )
    {
        $original_im = imagecreatefromjpeg( $file );
        $color1       = imagecolorallocate($original_im, 255, 255, 255 );
        $color2       = imagecolorallocate($original_im, 0, 0, 0 );

        $font =  TPL_DIR.DS.'verdanab.ttf';

        $left   = imagesx( $original_im );
        $top    = imagesy( $original_im );
        $size   = intval( round( $left/100 ) );

        $box = imageftbbox( $size, 0, $font, $text );
        $box['w'] = $box[4];
        $box['h'] = abs( $box[5] );

        $left = $left - ( $box['w'] + 10 );
        $top  = $top  - ( $box['h'] );

        imagettftext( $original_im, $size, 0, $left-1, $top-1, $color2, $font, $text );
        imagettftext( $original_im, $size, 0, $left+1, $top-1, $color2, $font, $text );
        imagettftext( $original_im, $size, 0, $left-1, $top+1, $color2, $font, $text );
        imagettftext( $original_im, $size, 0, $left+1, $top+1, $color2, $font, $text );
        imagettftext( $original_im, $size, 0, $left, $top, $color1, $font, $text );

        $nf = win2utf( CACHE_DIR.DS.basename( $file ) );

        imagejpeg( $original_im, $nf, 100 );
        return $nf;
    }


    $_F = scandir( ROOT_DIR.DS.'PRINT' );
    shuffle( $_F );

    $i = 0;
    foreach( $_F as $file )
    {
        if( $file == '.' || $file == '..' ){ continue; }
        if( file_exists( win2utf( CACHE_DIR.DS.basename( $file ) ) ) ){ continue; }

        $file = ROOT_DIR.DS.'PRINT'.DS.$file;

        $date = get_photo_date($file);
        $img = false;

        if( $date ){ $img = write( $file, $date ); }
        if( !$img )
        {
            echo $file."\n".$date;
            exit;
        }

        $img = str_replace( ROOT_DIR, HOMEURL, $img );

        echo '<img src="'.$img.'" >';
        exit;

        $i++;
        echo $i."\t".$file."\t".$date."\n";
        exit;
    }

    echo 'DONE!';
    exit;
}
*/


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
echo    stats::ins2html( $tpl->result( 'content' ) );

exit;

?>