<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////
// Basic title
$tpl->head_tags['title'] = 'ΐδμ³νοΰνελό';
$_admin = new admin;

//////////////////////////////////////////////////////////////////////////////////////////
// Basic checkes
if( !_SUBMOD_ )
{
    header( 'Location: /index.php?mod='._MOD_.'&submod='.$_admin->get_default_submode() );
    exit;
}
if( _SUBMOD_ && !in_array( _SUBMOD_, array_keys($_admin->get_menu_items()['items']) ) ){ common::err( 'ACCESS DENIED! User '.CURRENT_USER_ID.' try acces to submod '._SUBMOD_ ); }

//////////////////////////////////////////////////////////////////////////////////////////
// Load nav template for global inserting to content.tpl
$tpl->load( 'main_navigation' );
$tpl->set( '{list}', $_admin->html_get_menu_items() );
$tpl->compile( 'main_navigation' );

//////////////////////////////////////////////////////////////////////////////////////////
// Submodule load
$_inp_submod = $_admin->get_submod_name( _SUBMOD_ );
if( !file_exists( $_inp_submod ) )
{
    if( !is_dir(dirname($_inp_submod)) ){ mkdir(dirname($_inp_submod)); }
    fclose( fopen( $_inp_submod, 'w' ) );

    common::err( 'ACCESS DENIED! File '.str_replace( ROOT_DIR, '', $_inp_submod ).' not exists!' );
    exit;
}

require( $_inp_submod );

?>