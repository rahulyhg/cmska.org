<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

require( CLASSES_DIR.DS.'class.common.php' );
require( CLASSES_DIR.DS.'class.ajax.php' );
require( CLASSES_DIR.DS.'class.config.php' );
require( CLASSES_DIR.DS.'class.cache.php' );
require( CLASSES_DIR.DS.'class.db.php' );
require( CLASSES_DIR.DS.'class.user.php' );
require( CLASSES_DIR.DS.'class.tpl.php' );
require( CLASSES_DIR.DS.'class.admin.php' );
require( CLASSES_DIR.DS.'class.categ.php' );
require( CLASSES_DIR.DS.'class.tags.php' );
require( CLASSES_DIR.DS.'class.bbcode.php' );
require( CLASSES_DIR.DS.'class.posts.php' );
require( CLASSES_DIR.DS.'class.upload.php' );

//////////////////////////////////////////////////////////////////////////////////////////

require( CORE_DIR.DS.'dbconfig.php' );
user::start_session();

//////////////////////////////////////////////////////////////////////////////////////////

$_REQUEST   = common::filter( $_REQUEST );
$_COOKIE    = common::filter( $_COOKIE );
$_POST      = common::filter( $_POST );
$_GET       = common::filter( $_GET );

//////////////////////////////////////////////////////////////////////////////////////////

$_config    = config::get();
$tpl        = new tpl;
$tpl->head_tags['title'] = common::trim( $_config['title'] );
$tpl->head_tags['charset'] = common::trim( CHARSET );

//////////////////////////////////////////////////////////////////////////////////////////

require( CORE_DIR.DS.'chpu.php' );

//////////////////////////////////////////////////////////////////////////////////////////

define( '_AJAX_',       isset($_REQUEST['ajax'])?common::integer($_REQUEST['ajax']):false );
define( '_MOD_',        isset($_REQUEST['mod'])?common::totranslit(common::trim($_REQUEST['mod'])):'posts' );
define( '_SUBMOD_',     isset($_REQUEST['submod'])?common::integer($_REQUEST['submod']):false );
define( '_ACTION_',     isset($_REQUEST['action'])?common::integer($_REQUEST['action']):false );
define( '_SUBACTION_',  isset($_REQUEST['subaction'])?common::integer($_REQUEST['subaction']):false );

//////////////////////////////////////////////////////////////////////////////////////////

$_user = new user;
$_user->check_auth();
if( !defined('CURRENT_USER_ID') )
{
    common::err( 'Константа CURRENT_USER_ID не визачена!' );
}

if( _MOD_ == 'logout' )
{
    $_user->logout();
}

//////////////////////////////////////////////////////////////////////////////////////////

if( !CURRENT_USER_ID && _MOD_ == 'admin' ){             header( 'Location: /' ); exit; }
if( in_array( _MOD_, array('admin', 'forum') ) ){       define( 'CURRENT_SKIN', TPL_DIR.DS._MOD_ ); }
else{ define( 'CURRENT_SKIN', TPL_DIR.DS.$_config['skin'] ); }


//////////////////////////////////////////////////////////////////////////////////////////

if( CURRENT_USER_ID > 0 )
{
    define( 'CURRENT_GROUP_ID', $_user->get_user_param( 'group_id' ) );
}
else
{
    define( 'CURRENT_GROUP_ID', false );
}

//////////////////////////////////////////////////////////////////////////////////////////

if( _AJAX_ )
{
    require( CORE_DIR.DS.'router.ajax.php' );

}
else
{
    require( CORE_DIR.DS.'router.static.php' );
    require( MODS_DIR.DS.'login.php' );
}

?>