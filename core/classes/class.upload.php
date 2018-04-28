<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic'  ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }
if( !class_exists( 'images' ) ){ require( CLASSES_DIR.DS.'class.images.php' ); }
if( !class_exists( 'files'  ) ){ require( CLASSES_DIR.DS.'class.files.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

class upload
{
    use basic;

    static public final function del( $hash, $area )
    {
        if( $area == 'image' )
        {
            return images::del( $hash )?1:0;
        }

        if( $area == 'files' )
        {

        }
        return false;
    }

    static public final function process( $files, $conf, $post_id )
    {
        $cms_config = config::get();
        $post_id = self::integer( $post_id );

        $file_max_size  = self::iniBytes2normalBytes( ini_get( 'upload_max_filesize' ) );
        $image_max_size = $file_max_size;

        $file_max_size  =  ( $file_max_size >= $cms_config['upload.max.filesize'] )?$cms_config['upload.max.filesize']:$file_max_size;
        $image_max_size =  ( $image_max_size >= $cms_config['upload.max.imagesize'] )?$cms_config['upload.max.imagesize']:$image_max_size;

        foreach( $files as $id => $file )
        {
            $file['post_id'] = $post_id;
            $file['name'] = self::utf2win( $file['name'] );
            $ext = self::fileExt( $file['name'] );

            $file['size'] = self::integer( $file['size'] );
            $file['ext'] = $ext;

            if( $file['size'] != filesize($file['tmp_name']) )
            {
                $files[$id]['status'] = 0;
                $files[$id]['error'] = 'Помилка підрахунку розміру!';
                unset( $files['tmp_name'] );
                continue;
            }

            if( !preg_match( '!\.'.$ext.'(,|$)!i', $cms_config['upload.image.ext'].','.$cms_config['upload.file.ext'] )  )
            {
                $files[$id]['status'] = 0;
                $files[$id]['error'] = 'Заборонене розширення!';
                unset( $files['tmp_name'] );
                continue;
            }

            if( preg_match( '!\.'.$ext.'(,|$)!i', $cms_config['upload.image.ext'] ) && $file['size'] > $image_max_size )
            {
                $files[$id]['status'] = 0;
                $files[$id]['error'] = 'Зображення занадто велике!';
                unset( $files['tmp_name'] );
                continue;
            }

            if( preg_match( '!\.'.$ext.'(,|$)!i', $cms_config['upload.file.ext'] ) && $file['size'] > $file_max_size )
            {
                $files[$id]['status'] = 0;
                $files[$id]['error'] = 'Файл занадто великий!';
                unset( $files['tmp_name'] );
                continue;
            }

            $files[$id] = self::load( $file, $conf );
        }
        return $files;
    }

    static private final function load( $file, $conf )
    {
        $cms_config = config::get();
        $save_dir = UPL_DIR;
        $file_mode = false;

        if( preg_match( '!\.'.$file['ext'].'(,|$)!i', $cms_config['upload.file.ext'] ) )
        {
            $save_dir = $save_dir.DS.'files';
            $file_mode = 'file';
            $filename = sha1_file( $file['tmp_name'] ).'.scms';
        }
        else if( preg_match( '!\.'.$file['ext'].'(,|$)!i', $cms_config['upload.image.ext'] ) )
        {
            $save_dir = $save_dir.DS.'images';
            $file_mode = 'image';
            $filename = date('H-i-s').'-'.substr( str_shuffle( md5_file( $file['tmp_name'] ) ), 0, 8 ).'.'.$file['ext'];
        }
        else
        {
            self::err( 'Спроба завантаження забороненого файлу!'."\n" );
        }

        $save_dir = $save_dir.DS.date('Y-m-d');

        if( !is_dir( $save_dir ) )
        {
            if( !mkdir( $save_dir ) ){ self::err( 'Помилка створення каталогу!'."\n" ); }
            if( !mkdir( $save_dir.DS.'mini' ) ){ self::err( 'Помилка створення каталогу!'."\n" ); }
            chmod( $save_dir, 0777 );
            chmod( $save_dir.DS.'mini', 0777 );
        }

        if( move_uploaded_file( $file['tmp_name'], $save_dir.DS.$filename ) )
        {
            $file['status'] = 1;
            $file['error'] = false;
            $file['filename'] = $save_dir.DS.$filename;
            unset($file['tmp_name']);

            if( $file_mode == 'file'  ){ $file =  files::_upload_process( $file, $conf ); }
            if( $file_mode == 'image' ){ $file = images::_upload_process( $file, $conf ); }
        }
        else
        {
            $file['status'] = 0;
            $file['error'] = 'Завантаження не вдалося!';
            unset($file['tmp_name']);
        }
        return $file;
    }

}

?>