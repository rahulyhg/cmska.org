<?php
/**
 * class.bbcode.php
 *
 * клас обробки bbcode
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
 *     41 class bbcode
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
 * Клас обробки bbcode
 *
 * @author    MrGauss <author@cmska.org>
 * @package   cmska.org
 */
class bbcode
{
    use basic;

    /**
     * Перелік "простих" тегів
     * Зазвичай ці теги не мають додаткових параметрів
     *
     * @var static $simple_tags
     *
     * @access public
     */
    public static $simple_tags = array( 'b', 'i', 'u', 's', 'p', 'h2', 'h3', 'li', 'ol', 'ul', 'sub', 'sup', 'span' );

    /**
     * Кодування bbcode в html
     *
     * @var final static function bbcode2html( $text
     *
     * @access public
     */
    final public static function bbcode2html( $text = false )
    {
        $text = self::simple_tags( $text );
        $text = preg_replace_callback( '!\[(img)(\|.+?|)\](.+?)\[\/\1\]!is', 'self::process_image', $text );
        return $text;
    }

    /**
     * Декодування html в bbcode
     *
     * @var final static function html2bbcode( $text
     *
     * @access public
     */
    final public static function html2bbcode( $text = false )
    {
        $text = self::simple_tags( $text, true );
        $text = preg_replace_callback( '!<img(.+?)>!is', 'self::process_image', $text );
        return $text;
    }

    /**
     * Кодування/декодування bbcode-тегу [img...] та html-тегу <img...>
     *
     * @var final static function process_image( $array )
     *
     * @access private
     */
    final private static function process_image( $array )
    {
        if( strpos( isset($array[0])?$array[0]:'', '[/img]' ) !== false )
        {
            $img = array();
            $img['src']     = isset($array[3])?$array[3]:false;
            $img['alt']     = isset($array[2])?self::htmlspecialchars($array[2]):false;
            $img['alt']     = explode( '|', $img['alt'], 2 );
            $img['alt']     = end( $img['alt'] );
            $img['title']   = $img['alt'];

            return '<img class="post_img" src="'.$img['src'].'" alt="'.$img['alt'].'" title="'.$img['title'].'" />';
        }

        if( strpos( isset($array[0])?$array[0]:'', '<img' ) !== false )
        {
            $img = array();
            $img['src']         = preg_replace( '!(.*)src=\"(.+?)\"(.*)!is', '$2', $array['0'] );
            $img['title']       = preg_filter( '!(.*)title=\"(.+?)\"(.*)!is', '$2', $array['0'] );

            $img['src']   = $img['src']?$img['src']:false;
            $img['title'] = $img['title']?self::htmlspecialchars_decode($img['title']):false;

            return '[img'.($img['title']?'|'.$img['title']:'').']'.$img['src'].'[/img]';
        }
    }

    /**
     * Конвертація "простих" тегів html <-> bbcode
     *
     * @var final static function simple_tags( $text
     *
     * @access private
     */
    final private static function simple_tags( $text = false, $html2bbcode = false )
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

    /**
     * Конвертація html-тегу <code> в bbcode-тег [code]
     * Символи в тегах <code></code> будуть розкодовані через html_entity
     *
     * @var final static function _replace_code_html2bb( $array )
     *
     * @access private
     */
    final private static function _replace_code_html2bb( $array )
    {
        $text = $array[2];
        $text = self::html_entity_decode( self::trim( $text ) );
        return '[code]'.$text.'[/code]';
    }

    /**
     * Конвертація bbcode-тегу [code] в html-тег <code>
     * Символи в тегах [code][/code] закодовуються в html_entity
     *
     * @var final static function _replace_code_bb2html( $array )
     *
     * @access private
     */
    final private static function _replace_code_bb2html( $array )
    {
        $text = $array[2];
        $text = self::htmlentities( self::trim( $text ) );
        return '<code class="bb_code">'.$text.'</code>';
    }

    /**
     * Конвертація простих html-тегів в bbcode
     *
     * @var final static function _replace_simple_html2bb( $array )
     *
     * @access private
     */
    final private static function _replace_simple_html2bb( $array )
    {
        $tag = self::totranslit($array[1]);
        $text = end( $array );
        $title = (isset($array[3]) && $array[3])?'|'.self::htmlspecialchars_decode(preg_replace('!(^title=\"|\"$)!is','', trim($array[3]))):false;
        $align = (isset($array[2]) && $array[2])?'='.self::htmlspecialchars_decode(preg_replace('!align_!is','', trim($array[2]))):false;

        return '['.$tag.''.$align.''.$title.']'.$text.'[/'.$tag.']';
    }

    /**
     * Конвертація простих bbcode-тегів в html
     *
     * @var final static function _replace_simple_bb2html( $array )
     *
     * @access private
     */
    final private static function _replace_simple_bb2html( $array )
    {
        $tag = self::trim(self::totranslit($array[1]));
        $text = end( $array );
        $align =  ( isset($array[2]) && $array[2] )?' align_'.self::trim(str_replace('=','',$array[2])):false;
        $title =   ( isset($array[3]) && $array[3] )?' title="'.self::trim(self::htmlspecialchars(substr( $array[3], 1 ))).'"':false ;

        return '<'.$tag.' class=\"bb_'.$tag.''.$align.'\"'.$title.'>'.self::trim($text).'</'.$tag.'>';
    }

}

?>