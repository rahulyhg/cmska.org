<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

class bbcode
{
    use basic;

    public static $simple_tags = array( 'b', 'i', 'u', 's', 'p', 'h2', 'h3', 'li', 'ol', 'ul', 'sub', 'sup' );

    public final static function bbcode2html( $text = false )
    {
        $text = self::simple_tags( $text );
        return $text;
    }

    public final static function html2bbcode( $text = false )
    {
        return $text;
    }




    private final static function simple_tags( $text = false, $html2bbcode = false )
    {
        if( $html2bbcode )
        {
            $mask = '!<('.implode('|',self::$simple_tags).') class=\"bb_\1\">(.+?)</\1>!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace( $mask, '[$1]$2[/$1]', $text ); }

            $mask = '!<('.implode('|',self::$simple_tags).') class=\"bb_\1 align_(left|right|center|justify)\">(.+?)</\1>!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace( $mask, '[$1|$2]$3[/$1]', $text ); }

            $text = str_replace( '<br>', '[br]', $text );
        }
        else
        {
            $mask = '!\[('.implode('|',self::$simple_tags).')\](.+?)\[\/\1\]!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace( $mask, '<$1 class=\"bb_$1\">$2</$1>', $text ); }

            $mask = '!\[('.implode('|',self::$simple_tags).')\|(left|right|center|justify)\](.+?)\[\/\1\]!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace( $mask, '<$1 class=\"bb_$1 align_$2\">$3</$1>', $text ); }

            $mask = '!\[(left|right|center|justify)\](.+?)\[\/\1\]!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace( $mask, '<p class=\"bb_p align_$1\">$2</p>', $text ); }


            $text = str_replace( '[br]', '<br>', $text );
        }
        return $text;
    }

}

?>