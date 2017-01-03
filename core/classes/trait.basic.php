<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

trait basic
{
    public final function __call( $name, $arguments )
    {
        echo self::err( 'Method "'. $name. '" don\'t exist! '."\n" );
        exit;
    }

    public static function __callStatic($name, $arguments)
    {
        echo self::err( 'Вызов статического метода '.$name.' '. implode(', ', $arguments)."\n" );
        exit;
    }

	static public final function err( $text )
	{
        trigger_error( self::htmlentities( $text ), E_USER_ERROR );
		exit;
	}

    static public final function filter( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data ) ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::filter', $data ); }
        return self::trim( filter_var( strip_tags($data), FILTER_UNSAFE_RAW, FILTER_FLAG_ENCODE_LOW | FILTER_FLAG_STRIP_BACKTICK | FILTER_FLAG_ENCODE_AMP ) );
    }

    static public final function htmlspecialchars_decode( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::htmlspecialchars_decode', $data ); }
        return htmlspecialchars_decode( $data, ENT_QUOTES | ENT_HTML5 );
    }

	static public final function integer( $data )
	{
        if( !is_numeric( $data ) && !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::integer', $data ); }
        return abs(intval($data));
	}

    static public final function trim( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::trim', $data ); }
        return trim( $data );
    }

    static public final function stripslashes( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::stripslashes', $data ); }
        return stripslashes( $data );
    }

    static public final function strlen( $data )
    {
        if( !is_scalar( $data ) ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string only!' ); }
        return mb_strlen( $data, CHARSET ); ;
    }

    static public final function html_entity_decode( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::html_entity_decode', $data ); }
        return html_entity_decode( $data, ENT_QUOTES | ENT_HTML5, CHARSET ); ;
    }

    static public final function htmlspecialchars( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::htmlspecialchars', $data ); }
        return htmlspecialchars( $data, ENT_QUOTES | ENT_HTML5, CHARSET, true );;
    }

    static public final function htmlentities( $data = '' )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::htmlentities', $data ); }
        return htmlentities( $data, ENT_QUOTES | ENT_HTML5, CHARSET, true );
    }

    static public final function strtoupper( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::strtoupper', $data ); }
        return mb_strtoupper( $data, CHARSET );
    }

    static public final function strtolower( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::strtolower', $data ); }
        return mb_strtolower( $data, CHARSET );
    }

    static public final function urlencode( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::urlencode', $data ); }
        return urlencode( $data );
    }

    static public final function urldecode( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::urldecode', $data ); }
        return urldecode( $data );
    }
    static public final function utf2win( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::utf2win', $data ); }
        return mb_convert_encoding( $data, 'cp1251', 'utf-8' );
    }

    static public final function win2utf( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::win2utf', $data ); }
        return mb_convert_encoding( $data, 'utf-8', 'cp1251' );
    }

    static final public function encode_string( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::encode_string', $data ); }
        return self::urlencode( base64_encode( strrev( base64_encode( $data ) ) ) );
    }

    static final public function decode_string( $data )
    {
        if( !is_scalar( $data ) && !is_array( $data )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($data) ){ return array_map( 'self::decode_string', $data ); }
        return base64_decode( strrev( base64_decode( self::urldecode( $data ) ) ) ); ;
    }

    static public final function en_date( $date, $format = 'd.m.Y H:i:s' )
    {
        if( !is_scalar( $date ) ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string only!' ); }
        $date = strtotime( $date );
        $date = intval( $date );
        $date = date( $format, $date );
        return $date;
    }

    static public final function db2html( $str )
    {
        if( !is_scalar( $str ) && !is_array( $str )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($str) ){ return array_map( 'self::db2html', $str ); }

        $str = self::stripslashes( $str );
        $str = self::htmlentities( $str );
        
        return $str;
    }

    static public final function totranslit( $str )
    {
        if( !is_scalar( $str ) && !is_array( $str )  ){ self::err( ''.__CLASS__.'::'.__METHOD__.' accepts string or array only!' ); }
        if( is_array($str) ){ return array_map( 'self::totranslit', $str ); }

        $str = self::strtolower( $str );
        $rp = array();
        $rp[] = array( 'абвгдеёзийклмнопрстуфхцьыэі ', 'abvgdeezijklmnoprstufхc\'yei_' );
        $rp[] = array( 'АБВГДЕёЗИЙКЛМНОПРСТУФХЦЬЫЭІ ', 'ABVGDEEZIJKLMNOPRSTUFХC\'YEI_' );

        for( $i=0; $i<count($rp); $i++ ){ $str = strtr( $str, $rp[$i][0], $rp[$i][1] ); }

        $str = str_replace( 'ж', 'zh', $str );
        $str = str_replace( 'ч', 'ch', $str );
        $str = str_replace( 'ш', 'sh', $str );
        $str = str_replace( 'щ', 'shh', $str );
        $str = str_replace( 'ъ', '\'', $str );
        $str = str_replace( 'ю', 'yu', $str );
        $str = str_replace( 'я', 'ya', $str );
        $str = str_replace( 'є', 'ye', $str );
        $str = str_replace( 'Ж', 'ZH', $str );
        $str = str_replace( 'Ч', 'CH', $str );
        $str = str_replace( 'Ш', 'SH', $str );
        $str = str_replace( 'Щ', 'SHH', $str );
        $str = str_replace( 'Ъ', '`', $str );
        $str = str_replace( 'Ю', 'YU', $str );
        $str = str_replace( 'Я', 'YA', $str );
        $str = str_replace( 'Є', 'YE', $str );

        $str = self::strtolower( $str );

        $str = self::trim( strip_tags( $str ) );
        $str = preg_replace( '![^a-z0-9\_\-]+!mi', '', $str );
        $str = preg_replace( '![.]+!i', '.', $str );
        $str = self::strtolower( $str );

        return $str;
    }

    static protected final function read_file( $filename )
    {
        if( !file_exists($filename) ){  return false; }
        if( !filesize($filename) ){     return false; }

        $fop = fopen( $filename, 'rb' );
        $data = fread( $fop, filesize( $filename ) );
        fclose( $fop );
        return $data;
    }

    static protected final function write_file( $filename, $data = false, $log = false )
    {
        if( !file_exists($filename) ){ fclose( fopen($filename, 'a' ) ); }

        if( $log == true ){ $fop =  fopen( $filename, 'a' ); }
        else{ $fop =  fopen( $filename, 'w' ); }

        if( flock($fop, LOCK_EX ) )
        {
          fwrite( $fop, $data );
          fflush( $fop );
          flock( $fop, LOCK_UN );
        }

        fclose( $fop );

        return true;
    }

}

?>