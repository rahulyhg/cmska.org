<?php
/**
 * class.categ.php
 *
 * клас для роботи з категоріями
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
 *     42 class categ
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

//////////////////////////////////////////////////////////////////////////////////////////

/**
 * Клас для роботи з категоріями
 *
 * @author    MrGauss <author@cmska.org>
 * @package   cmska.org
 */
class categ
{
    use basic, db_connect;

    const CACHE_VAR_CATEG = 'categ';

    /**
     * Отримання дерева категорій у вигляді елементів <option...>
     *
     * @var final function get_categ_opts()
     *
     * @access public
     * @return string
     */
    final public function get_categ_opts()
    {
      $data = array();

      foreach( $this->get_categories() as $categ )
      {
        $attrs = array();

        $categ = self::stripslashes( $categ );
        $categ = self::htmlspecialchars( $categ );

        foreach( $categ as $attr => &$value )
        {
          if( is_array($value) ){ continue; }
          $attrs[] = 'data-'.$attr.'="'.$value.'"';
        }
        $attrs = implode( ' ', $attrs );
        $data[] = '<option '.$attrs.' value="'.$categ['id'].'">'.$categ['name'].'</option>';
      }
      $data = "\n\t".implode( "\n\t", $data )."\n";

      return $data;
    }

    /**
     * Отримання дерева категорій з БД
     *
     * @var final function get_categories()
     *
     * @access public
     * @return array
     */
    final public function get_categories()
    {
        $data = cache::get( self::CACHE_VAR_CATEG );

        if( !$data || !is_array($data) || !count($data) )
        {
            $SQL = 'SELECT * FROM categories ORDER BY level; '.QUERY_CACHABLE;
            $SQL = $this->db->query( $SQL );

            $data = array();
            while( ($row = $this->db->get_row($SQL)) != false )
            {
                $data[$row['id']] = self::stripslashes( $row );
                $data[$row['id']]['name'] = self::htmlspecialchars( $data[$row['id']]['name'] );
                $data[$row['id']]['altname'] = self::totranslit( $data[$row['id']]['altname'] );
            }
            $this->db->free( $SQL );
            cache::set( self::CACHE_VAR_CATEG, $data );
        }

        return $data;
    }

    /**
     * [add description]
     *
     * @var final function get_id( $altname )
     *
     * @access public
     */
    public final function get_id( $altname )
    {
        foreach( $this->get_categories() as $id => $value )
        {
            if( self::totranslit($value['altname']) == self::totranslit($altname) )
            {
                return $id;
            }
        }
        return false;
    }

    /**
     * [add description]
     *
     * @var final function get_url( $id )
     *
     * @access public
     */
    public final function get_url( $id )
    {
        $data = $this->get_categories();
        $ptree = $data[$id]['ptree'];

        $ptree = explode( '-', $ptree );
        $ptree = array_values(self::integer( $ptree ));

        $link = array();
        if( $ptree[0] == 0 )
        {
            $ptree[0] = null;
            unset( $ptree[0] );
        }

        while( count($ptree) )
        {
            $ptree = array_values( $ptree );
            $link[] = $data[$ptree[0]]['altname'];
            $ptree[0] = null;
            unset( $ptree[0] );
        }

        $link[] = $data[$id]['altname'];
        $link = HOME.''.implode( '/', $link ).'/';

        return $link;
    }

}


?>