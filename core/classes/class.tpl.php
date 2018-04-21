<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

class tpl
{
    use basic;

    private $cache = array();
    private $theme = array();
    private $buffer = array();
    private $current = false;

    public  $head_tags = array
            (
                'title' => '',
                'description' => '',
                'keywords' => '',
                'charset' => '',
            );

    public final function info( $title=false, $message, $level='notice' )
    {
        $this->load( 'info' );
        $this->set( '{info:title}',     self::htmlspecialchars( $title ) );
        $this->set( '{info:message}',   self::htmlspecialchars( $message ) );
        $this->set( '{info:level}',     self::htmlspecialchars( $level ) );
        $this->compile( 'info' );
    }

    public final function load( $skin  = false, $enable_current = true )
    {
        if( !$skin ){ return false; }

        $skin = explode( '/', $skin );
        foreach( $skin as $k=>$v ){ $skin[$k] = self::totranslit($v); }
        $skin = implode( DS, $skin );
        $filename = CURRENT_SKIN.DS.$skin.'.tpl';

        if( !file_exists( $filename ) )
        {
            self::err( 'TEMPLATE NOT FOUND: '.$skin.'.tpl' );
            exit;
        }

        if( !isset($this->cache[$skin]) )
        {
            $this->cache[$skin] = self::read_file( $filename );
        }

        $this->theme[$skin] = $this->parse_global_tags( $this->cache[$skin] );

        if( $enable_current ){ $this->current = $skin; }
        return $this->theme[$skin];
    }

    public function set( $tag, $value, $skin=false )
    {
        $skin = $skin?$skin:$this->current;
        if( isset($this->theme[$skin]) )
        {
            if( is_array($value) )
            {
                self::err( 'tag '.$tag.' have array value! String is needed! File: '.__FILE__ );
                exit;
            }
            else
            {
                $this->theme[$skin] = str_replace( $tag, $value, $this->theme[$skin] );
            }
        }
    }

    public final function set_block( $mask, $value, $skin=false )
    {
        $skin = $skin?$skin:$this->current;

        if( isset($this->theme[$skin]) )
        {
            if( is_array($value) )
            {
                self::err( 'mask '.$mask.' have array value! String is needed! File: '.__FILE__ );
                exit;
            }
            $this->theme[$skin] = preg_replace( $mask, $value, $this->theme[$skin] );
        }
    }

    public final function compile( $skin=false )
    {
        if( !$skin ){ $skin = $this->current; }

        if( !isset($this->buffer[$skin]) ){ $this->buffer[$skin] = ''; }

        $this->buffer[$skin] = $this->buffer[$skin].$this->theme[$skin];
        $this->theme[$skin] = '';
    }

    public final function result( $skin=false )
    {
        if( !$skin ){ $skin = $this->current; }
        if( !isset($this->buffer[$skin]) ){ $this->buffer[$skin] = ''; }

        $data = $this->buffer[$skin];
        $this->clean($skin);

        if( $skin == 'content' )
        {
            foreach( $this->head_tags as $key => $value )
            {
                $data = str_replace( '{'.self::strtolower($key).'}', $value, $data );
            }

            foreach( $this->buffer as $key => $value )
            {
                $data = str_replace( '{global:'.$key.'}', $value, $data );
                $this->clean( $key );
            }

            $data = preg_replace( '!\{global:(\w+?)\}!', '', $data );
        }
        return $data;
    }

    public final function ins( $skin=false, $data )
    {
        if( !$skin ){ $skin = $this->current; }
        if( !isset($this->buffer[$skin]) ){ $this->buffer[$skin] = ''; }

        $this->buffer[$skin] = $this->buffer[$skin].$data;
    }

    public final function clean( $skin=false )
    {
        $skin = $skin?$skin:$this->current;
        $this->theme[$skin] = false;
        $this->cache[$skin] = false;
        $this->buffer[$skin] = false;
        unset( $this->cache[$skin] );
        unset( $this->theme[$skin] );
        unset( $this->buffer[$skin] );
    }

    private final function parse_global_tags( $data )
    {
        $data = str_replace( '{MOD}', _MOD_, $data );
        $data = str_replace( '{SKINDIR}', str_replace( ROOT_DIR, '', CURRENT_SKIN ), $data );
        $data = str_replace( '{HOME}', HOMEURL, $data );
        $data = str_replace( '{CHARSET}', CHARSET, $data );
        $data = $this->parse_tags_include( $data );
        $data = $this->parse_tags_login_nologin( $data );
        $data = $this->parse_tags_curr_user_info( $data );
        $data = $this->parse_tags_group( $data );
        $data = $this->parse_categ_list( $data );
        return $data;
    }

    private final function parse_tags_include( $data )
    {
        $tag = false;
        if( preg_match_all( '!\{\@include=([a-z0-9\/]+?)\}!i', $data, $tag ) )
        {
            if( isset($tag[1]) && is_array($tag[1]) && count($tag[1]) )
            {
                foreach( $tag[1] as $key=>$elem )
                {
                    $elem = explode( '/', $elem );
                    $elem  = self::totranslit( $elem );
                    $elem  = implode( DS, $elem );
                    $file = CURRENT_SKIN.DS.$elem.'.tpl';
                    if( !file_exists( $file ) ){ $elem = false; }

                    if( $elem && isset($tag[0][$key]) && $tag[0][$key] )
                    {
                        $data  = str_replace( $tag[0][$key], $this->load( $elem, false ), $data );
                    }
                }
            }
        }
        return $data;
    }

    private final function parse_tags_login_nologin( $data )
    {
        if( preg_match( '!\[(login|nologin)\](.+?)\[\/\1\]!is', $data ) )
        {
            $data = str_replace( (CURRENT_USER_ID?'[login]':'[nologin]'), '', $data );
            $data = str_replace( (CURRENT_USER_ID?'[/login]':'[/nologin]'), '', $data );

            $data = preg_replace( '!\[('.(CURRENT_USER_ID?'nologin':'login').')\](.+?)\[\/\1\]!is', '', $data );
        }
        return $data;
    }

    private final function parse_tags_curr_user_info( $data )
    {
        if( strpos( $data, '{curr.user:' ) )
        {
            if( !isset($GLOBALS['_user']) || !is_object($GLOBALS['_user'])){ self::err( '«м≥нну "_user" втрачено!' ); }

            foreach( $GLOBALS['_user']->get_curr_user_info()['user'] as $key => $value )
            {
                $data = str_replace( '{curr.user:'.$key.'}', self::htmlspecialchars(self::stripslashes($value)), $data );
            }
        }
        return $data;
    }

    private final function parse_tags_group( $data )
    {
        if( preg_match( '!\[(group:\d+?)\](.+?)\[\/\1\]!is', $data ) )
        {
          $data = str_replace( '[group:'.CURRENT_GROUP_ID.']', '', $data );
          $data = str_replace( '[/group:'.CURRENT_GROUP_ID.']', '', $data );
          $data = preg_replace( '!\[(group:\d+?)\](.+?)\[\/\1\]!is', '', $data );
        }

        if( preg_match( '!\[(nogroup:\d+?)\](.+?)\[\/\1\]!is', $data ) )
        {
          $data = str_replace( '[nogroup:'.CURRENT_GROUP_ID.']', '', $data );
          $data = str_replace( '[/nogroup:'.CURRENT_GROUP_ID.']', '', $data );
          $data = preg_replace( '!\[(nogroup:\d+?)\](.+?)\[\/\1\]!is', '', $data );
        }

        return $data;
    }

    private final function parse_categ_list( $data )
    {
        if( strpos( $data, '{categ:list}' ) )
        {
          if( !isset($GLOBALS['_CATEG']) || !is_object($GLOBALS['_CATEG']) ){ $GLOBALS['_CATEG'] = new categ; }
          $data = str_replace( '{categ:list}',  $GLOBALS['_CATEG']->get_categ_opts(), $data );
        }

        return $data;
    }


}

?>