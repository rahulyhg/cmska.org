<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

$tpl->head_tags['title'] = 'Налаштування';

//////////////////////////////////////////////////////////////////////////////////////////

$_CONFIG_DATA = array();

$_CONFIG_DATA[] = array
(
    'type'  => 'checkbox',
    'name'  => 'enable_site',
    'value'  => isset($_config['enable_site'])?$_config['enable_site']:false,
    'title' => 'Ввімкнути сайт',
    'descr' => 'Тут що завгодно',
    'attr'  => array(),
);

$_CONFIG_DATA[] = array
(
    'type'  => 'textinput',
    'name'  => 'title',
    'value'  => isset($_config['title'])?$_config['title']:false,
    'title' => 'Ввімкнути сайт',
    'descr' => 'Тут що завгодно',
    'attr'  => array(),
);

$_CONFIG_DATA[] = array
(
    'type'  => 'textinput',
    'name'  => 'homeurl',
    'value'  => isset($_config['homeurl'])?$_config['homeurl']:false,
    'title' => 'Ввімкнути сайт',
    'descr' => 'Тут що завгодно',
    'attr'  => array(),
);

$_CONFIG_DATA[] = array
(
    'type'  => 'textarea',
    'name'  => 'site_descr',
    'value'  => isset($_config['site_descr'])?$_config['site_descr']:false,
    'title' => 'Ввімкнути сайт',
    'descr' => 'Тут що завгодно',
    'attr'  => array(),
);

$_CONFIG_DATA[] = array
(
    'type'  => 'checkbox',
    'name'  => 'enable_chpu',
    'value'  => isset($_config['enable_chpu'])?$_config['enable_chpu']:false,
    'title' => 'Ввімкнути сайт',
    'descr' => 'Тут що завгодно',
    'attr'  => array(),
);

//////////////////////////////////////////////////////////////////////////////////////////

foreach( $_CONFIG_DATA as $_conf_line )
{

    switch ( $_conf_line['type'] )
    {
        case 'checkbox':
            $_conf_line['attr']['checked'] = abs(intval($_conf_line['value']))?true:false;
            $_id = false;
            $tpl->load( 'config_element' );
            $tpl->set( '{title}', $_conf_line['title'] );
            $tpl->set( '{descr}', $_conf_line['descr'] );
            $tpl->set( '{elem}', admin::make_checkbox( false, $_conf_line['name'], 1, $_conf_line['attr'], $_id ) );
            $tpl->set( '{id}', $_id );
            $tpl->compile( 'config_element' );
        break;

        case 'textinput':
            $_id = false;
            $tpl->load( 'config_element' );
            $tpl->set( '{title}', $_conf_line['title'] );
            $tpl->set( '{descr}', $_conf_line['descr'] );
            $tpl->set( '{elem}', admin::make_textinput( false, $_conf_line['name'], $_conf_line['value'], $_conf_line['attr'], $_id ) );
            $tpl->set( '{id}', $_id );
            $tpl->compile( 'config_element' );
        break;

        case 'textarea':
            $_id = false;
            $tpl->load( 'config_element' );
            $tpl->set( '{title}', $_conf_line['title'] );
            $tpl->set( '{descr}', $_conf_line['descr'] );
            $tpl->set( '{elem}', admin::make_textarea( false, $_conf_line['name'], $_conf_line['value'], $_conf_line['attr'], $_id ) );
            $tpl->set( '{id}', $_id );
            $tpl->compile( 'config_element' );
        break;

    }
}

//////////////////////////////////////////////////////////////////////////////////////////

$tpl->load( 'config' );
$tpl->set( '{basic_config}', $tpl->result( 'config_element' ) );
$tpl->compile( 'config' );

//////////////////////////////////////////////////////////////////////////////////////////

// GLOBAL TEMPLATE LOADING
$tpl->load( 'page_item' );
$tpl->set( '{data}', $tpl->result( 'config' ) );
$tpl->compile( 'page_item' );

?>