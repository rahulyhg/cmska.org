<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !class_exists( 'cache' ) ){ require( CLASSES_DIR.DS.'class.cache.php' ); }

trait admin_build_panel
{
    private $_menu_items = false;

    public final function get_default_submode()
    {
        foreach( $this->get_menu_items()['items'] as $item )
        {
            if( abs(intval($item['is_default'])) != 0 )
            {
                return abs(intval($item['id']));
            }
        }

    }

    public final static function make_checkbox( $info=false, $name, $value = 1, $attr = array(), &$id=false )
    {
        if( !$id ){ $id = 'chbox-'.md5( microtime(true) . rand(0, 10000) . $name ); }

        $html = '<input data-save="1" class="input checkbox" type="checkbox" id="'.$id.'" name="'.$name.'" value="'.$value.'" '.((isset($attr['checked']) && abs(intval($attr['checked'])))?'checked="checked"':'').'>'.
                    '<label class="label" for="'.$id.'">'.$info.'</label>';
        return $html;
    }

    public final static function make_textinput( $info=false, $name, $value = 1, $attr = array(), &$id=false )
    {
        if( !$id ){ $id = 'chbox-'.md5( microtime(true) . rand(0, 10000) . $name ); }

        $html = '<input data-save="1" class="input" type="text" id="'.$id.'" name="'.$name.'" value="'.$value.'"'.((isset($attr['disabled']) && abs(intval($attr['disabled'])))?' disabled':'').'>';
        return $html;
    }    

    public final static function make_textarea( $info=false, $name, $value = 1, $attr = array(), &$id=false )
    {
        if( !$id ){ $id = 'chbox-'.md5( microtime(true) . rand(0, 10000) . $name ); }

        $html = '<textarea data-save="1" class="input textarea" type="text" id="'.$id.'" name="'.$name.'" '.((isset($attr['disabled']) && abs(intval($attr['disabled'])))?' disabled':'').'>'.$value.'</textarea>';
        return $html;
    }    

    public final function get_submod_name( $_mod_id = 0 )
    {
        $_inp_submod = array();
        $_inp_submod[] = _MOD_;
        if( $this->get_menu_items()['items'][$_mod_id]['parent_id'] > 0 )
        {
            $_inp_submod[] = $this->get_menu_items()['items'][$this->get_menu_items()['items'][$_mod_id]['parent_id']]['altname'];
        }
        $_inp_submod[] = $this->get_menu_items()['items'][$_mod_id]['altname'];

        unset($_inp_submod[0]);
        $_inp_submod = array_values($_inp_submod);

        return MODS_DIR.DS.'module.'._MOD_.DS.$_inp_submod[0].DS.$_inp_submod[1].'.php';
    }

    public final function html_get_menu_items()
    {
        $items = self::get_menu_items();
        $tpl = new tpl;

        $active_submod = _SUBMOD_?_SUBMOD_:13;

        foreach( $items['keys'][0] as $parent_id )
        {
            $is_active = false;
            foreach( $items['keys'][$parent_id] as $item_id )
            {
                if( abs(intval($item_id)) == $active_submod ){ $is_active = true; }
                if( !abs(intval($items['items'][$item_id]['show_at_nav'])) && abs(intval($item_id)) != $active_submod ){ continue; }

                $tpl->load( 'admin_menu_subelem' );
                $tpl->set( '{altname}', self::db2html($items['items'][$item_id]['altname']) );
                $tpl->set( '{name}', self::db2html($items['items'][$item_id]['name']) );
                $tpl->set( '{href}', '/index.php?mod='._MOD_.'&submod='.$item_id );
                $tpl->set( '{active}', ($item_id == $active_submod)?' active':'' );
                $tpl->compile( 'admin_menu_subelem' );
            }

            $tpl->load( 'admin_menu_elem' );
            $tpl->set( '{altname}', self::db2html( $items['items'][$parent_id]['altname'] ) );
            $tpl->set( '{name}', self::db2html( $items['items'][$parent_id]['name'] ) );
            $tpl->set( '{href}', '/index.php?mod='._MOD_.'&submod='.$parent_id );
            $tpl->set( '{subelems}', self::trim($tpl->result('admin_menu_subelem')) );
            $tpl->set( '{active}', $is_active?' active':'' );
            $tpl->compile( 'admin_menu_elem' );
        }

        $data = $tpl->result('admin_menu_elem');

            $tpl = null;
            unset( $tpl );

        return $data;
    }

    public final function get_menu_items()
    {
        if( $this->_menu_items && is_array($this->_menu_items) && isset($this->_menu_items['items']) )
        { return $this->_menu_items; }

        $cache_var = 'admin_menu_items_gr'.CURRENT_GROUP_ID;
        $this->_menu_items  = cache::get( $cache_var );

        if( $this->_menu_items && is_array($this->_menu_items) && isset($this->_menu_items['items']) )
        {
            return $this->_menu_items;
        }

        $this->_menu_items = array();

        $SQL = '
            SELECT *
            FROM
                admin_menu
            WHERE
                id > 0
                AND
                id IN ( SELECT item_id FROM admin_menu_accesses WHERE group_id = '.CURRENT_GROUP_ID.' )
            ORDER by level, position;';

        $SQL = $this->db->query( $SQL );

        while( $row = $this->db->get_row($SQL) )
        {
            $this->_menu_items[$row['id']] = $row;
        }
        $this->db->free( $SQL );

        $keys = array();

        foreach( $this->_menu_items as $line )
        {
            if( !isset($keys[$line['parent_id']]) ){ $keys[$line['parent_id']] = array(); }
            $keys[$line['parent_id']][] = $line['id'];
        }

        $this->_menu_items = array( 'items' => $this->_menu_items, 'keys' => $keys );

        cache::set( $cache_var, $this->_menu_items );

        return $this->_menu_items;
    }

}

?>