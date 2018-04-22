<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic'  ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }
if( !trait_exists( 'db_connect'  ) ){ require( CLASSES_DIR.DS.'trait.db_connect.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

class images
{
    use basic, db_connect;
    static public final function _upload_process( $file, $config )
    {
        $cms_config = config::get();

        foreach
        (
            array (
                'upload.image.compress',
                'upload.image.mini',
                'upload.image.watermark',
                'upload.image.mini.proportion',
                'upload.image.compress.x',
                'upload.image.compress.y',
                'upload.image.mini.x',
                'upload.image.mini.y',
            )
            as $key
        )
        {
            if( !isset($config[$key]) ){ self::err( ''.__CLASS__.'::'.__METHOD__.' >> $config[\''.$key.'\'] not exist!' ); }
            $config[$key] = self::integer( !isset($config[$key])?$config[$key]:$config[$key] );
        }

        $_cl = new images;
        $file = $_cl->any2png( $file, $config );

        $_cl->ins2db( $file );
        return $file;
    }

    static private final function get_image_type( $data = false )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::'.__METHOD__, $data ); }

        if( !file_exists($data) ){ self::err( ''.__CLASS__.'::'.__METHOD__.' >> file not exist!' ); }

        $data = self::strtolower( self::fileinfo( $data ) );

        if( strpos( $data, 'image' )    === false ){ return false; }
        if( strpos( $data, 'png' )      !== false ){ return IMAGETYPE_PNG; }
        if( strpos( $data, 'jpeg' )     !== false ){ return IMAGETYPE_JPEG; }
        if( strpos( $data, 'gif' )      !== false ){ return IMAGETYPE_GIF; }
        return false;
        // exif_imagetype($file)
    }

    private final function any2png( $file, $config = array() )
    {
        $im = false;

        switch( self::get_image_type($file['filename']) )
        {
          case IMAGETYPE_GIF:   $im = imagecreatefromgif( $file['filename']); break;
          case IMAGETYPE_JPEG:  $im = imagecreatefromjpeg($file['filename']); break;
          case IMAGETYPE_PNG:   $im = imagecreatefrompng( $file['filename']); break;
        }

        if( $im === false )
        {
            $file['status'] = 0;
            $file['error'] = 'Помилка обробки зображення!';
            unlink( $file['filename'] );
            return $file;
        }

        $_dir = dirname($file['filename']);
        $_fnm = preg_replace( '!\.(\w+?)$!i', '.png', basename( $file['filename'] ) );
        $_newfile = $_dir.DS.$_fnm;

        imagepng( $im, $_newfile, 7 );

        if( $_newfile != $file['filename'] ){ unlink( $file['filename'] ); }

        if( $config['upload.image.compress'] )
        {
            self::compress( $_newfile, $config['upload.image.compress.x'], $config['upload.image.compress.y'] );
        }

        if( $config['upload.image.mini'] )
        {
            //self::makemini( $_newfile, $config['upload.image.mini.x'], $config['upload.image.mini.y'], $config['upload.image.mini.proportion'] );
        }

        $file['filename'] = $_newfile;
        $file['ext']      = 'png';
        $file['type']     = self::fileinfo( $file['filename'] );
        $file['size']     = filesize( $file['filename'] );
        $file['name']     = basename( $file['filename'] );


        return $file;
    }

    private final function makemini( $file, $x = 200, $y = 100, $prop = false )
    {
        $im = imagecreatefrompng( $file );

        $sizes = array();
        $sizes['old'] = array();
        $sizes['old']['w'] = imagesx( $im );
        $sizes['old']['h'] = imagesy( $im );
        $sizes['new'] = array();
        $sizes['new']['w'] = $x;
        $sizes['new']['h'] = $y;

        if( $prop )
        {
            $koef = $sizes['old']['w'] / $sizes['old']['h'];

            if( $sizes['old']['w'] >= $sizes['old']['h'] ){ $sizes['new']['h'] = ceil( $sizes['new']['w'] / $koef ); }
            if( $sizes['old']['h'] >= $sizes['old']['w'] ){ $sizes['new']['w'] = ceil( $sizes['new']['h'] * $koef ); }
        }

    }

    private final function compress( $file, $x, $y )
    {
        $im = imagecreatefrompng( $file );

        $sizes = array();
        $sizes['old'] = array();
        $sizes['old']['w'] = imagesx( $im );
        $sizes['old']['h'] = imagesy( $im );
        $sizes['new'] = array();
        $sizes['new']['w'] = $x;
        $sizes['new']['h'] = $y;

        if( $sizes['old']['w'] <= $sizes['new']['w'] && $sizes['old']['h'] <= $sizes['new']['h'] )
        {
            imagedestroy( $im );
            return false;
        }

        $koef = ( $sizes['old']['w'] + 1 ) / ( $sizes['old']['h'] + 1 );

        if( $sizes['old']['w'] >= $sizes['old']['h'] ){ $sizes['new']['h'] = ceil( $sizes['new']['w'] / $koef ); }
        if( $sizes['old']['h'] >= $sizes['old']['w'] ){ $sizes['new']['w'] = ceil( $sizes['new']['h'] * $koef ); }

        var_export($sizes);
        exit;

        $new_im = imagecreatetruecolor( $sizes['new']['w'], $sizes['new']['h'] );

        imagecopyresized( $new_im, $im, 0, 0, 0, 0, $sizes['new']['w'], $sizes['new']['h'], $sizes['old']['w'], $sizes['old']['h'] );
        imagedestroy( $im );

        imagepng( $new_im, $file, 7 );
        return true;
    }

    private final function ins2db( $data )
    {

    }

}

?>