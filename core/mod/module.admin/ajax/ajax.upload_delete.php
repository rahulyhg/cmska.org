<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$HASH = common::filter( isset($_REQUEST['hash'])?$_REQUEST['hash']:0 );
$AREA = common::filter( isset($_REQUEST['area'])?$_REQUEST['area']:0 );

ajax::set_data( 'reslt', upload::del($HASH, $AREA)?1:0 );

?>