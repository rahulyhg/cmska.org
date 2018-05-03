<?php
/**
 * class.admin.php
 *
 * клас для роботи з модулем адмін-панелі
 *
 * @category  main
 * @package   cmska.org
 * @author    MrGauss <author@cmska.org>
 * @copyright 2018
 * @license   GPL
 * @version   0.4
 */

/**
 * [CLASS/FUNCTION INDEX of SCRIPT]
 *
 *     44 class admin
 *
 * TOTAL FUNCTIONS: 0
 * (This index is automatically created/updated by the WeBuilder plugin "DocBlock Comments")
 *
 */

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){ require( CLASSES_DIR.DS.'trait.basic.php' ); }
if( !trait_exists( 'db_connect' ) ){ require( CLASSES_DIR.DS.'trait.db_connect.php' ); }
if( !trait_exists( 'admin_build_panel' ) ){ require( CLASSES_DIR.DS.'admin'.DS.'trait.admin.build_panel.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

/**
 * Клас для роботи з модулем адмін-панелі
 *
 * @author    MrGauss <author@cmska.org>
 * @package   cmska.org
 * @use       basic, db_connect, admin_build_panel
 */
class admin
{
    use basic, db_connect, admin_build_panel;

}

?>