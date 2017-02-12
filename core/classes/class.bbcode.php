<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

class bbcode
{
    use basic;

    public static $simple_tags = array( 'b', 'i', 'u', 's', 'p', 'h2', 'h3', 'li', 'ol', 'ul', 'sub', 'sup', 'span' );

    public final static function bbcode2html( $text = false )
    {
        $text = self::simple_tags( $text );
        return $text;
    }

    public final static function html2bbcode( $text = false )
    {
        $text = self::simple_tags( $text, true );
        return $text;
    }




    private final static function simple_tags( $text = false, $html2bbcode = false )
    {
        if( $html2bbcode )
        {
            $mask = '!<(code) class=\"bb_\1\">(.+?)</\1>!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace_callback( $mask, 'self::_replace_code_html2bb', $text ); }

            $mask = '!<('.implode('|',self::$simple_tags).') class=\"bb_\1(\s+?align_.+?|)\"(\s+?title=\".+?\"\s+?|)>(.+?)</\1>!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace_callback( $mask, 'self::_replace_simple_html2bb', $text ); }

            $mask = '!<('.implode('|',self::$simple_tags).') class=\"bb_\1\" title="(.+?)">(.+?)</\1>!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace( $mask, '[$1|$2]$3[/$1]', $text ); }



            $text = str_replace( '<br>', '[br]', $text );
        }
        else
        {
            $mask = '!\[(code)\](.+?)\[\/\1\]!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace_callback( $mask, 'self::_replace_code_bb2html', $text ); }

            $mask = '!\[('.implode('|',self::$simple_tags).')(=.+?|)(\|.+?|)\](.+?)\[\/\1\]!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace_callback( $mask, 'self::_replace_simple_bb2html', $text ); }

            $mask = '!\[(left|right|center|justify)\](.+?)\[\/\1\]!is';
            while( preg_match( $mask, $text ) ){ $text = preg_replace( $mask, '<p class=\"bb_p align_$1\">$2</p>', $text ); }

            $text = str_replace( '[br]', '<br>', $text );
        }
        return $text;
    }

    private final static function _replace_code_html2bb( $array )
    {
        $text = $array[2];
        $text = self::html_entity_decode( self::trim( $text ) );
        return '[code]'.$text.'[/code]';
    }

    private final static function _replace_code_bb2html( $array )
    {
        $text = $array[2];
        $text = self::htmlentities( self::trim( $text ) );
        return '<code class="bb_code">'.$text.'</code>';
    }

    private final static function _replace_simple_html2bb( $array )
    {
        $tag = self::totranslit($array[1]);
        $text = end( $array );
        $title = (isset($array[3]) && $array[3])?'|'.self::htmlspecialchars_decode(preg_replace('!(^title=\"|\"$)!is','', trim($array[3]))):false;
        $align = (isset($array[2]) && $array[2])?'='.self::htmlspecialchars_decode(preg_replace('!align_!is','', trim($array[2]))):false;

        return '['.$tag.''.$align.''.$title.']'.$text.'[/'.$tag.']';
    }

    private final static function _replace_simple_bb2html( $array )
    {
        $tag = self::trim(self::totranslit($array[1]));
        $text = end( $array );
        $align =  ( isset($array[2]) && $array[2] )?' align_'.self::trim(str_replace('=','',$array[2])):false;
        $title =   ( isset($array[3]) && $array[3] )?' title="'.self::trim(self::htmlspecialchars(substr( $array[3], 1 ))).'"':false ;

        return '<'.$tag.' class=\"bb_'.$tag.''.$align.'\"'.$title.'>'.self::trim($text).'</'.$tag.'>';
    }

}

?>