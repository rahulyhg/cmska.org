<?php
/**
 * class.ajax.php
 *
 * ���� ��� ������� ����� ��� AJAX-�������
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
 *     48 class ajax
 *
 * TOTAL FUNCTIONS: 0
 * (This index is automatically created/updated by the WeBuilder plugin "DocBlock Comments")
 *
 */

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

$_ajax_result = array
           (
             'error' => 0,
             'error_text'     => '',
           );

/**
 * ���� ��� ��������� �� ������� �����, �� ����������� ��� ��������� AJAX-������
 * ���������� ����� �������� ���������� ���������� ����� � ����������� ��������� �������
 * � ��������� �������� ����� � ����� ���� �����.
 * ������ ��� ������ ���������� � ������ JSON
 *
 * @author    MrGauss <author@cmska.org>
 * @package   cmska.org
 * @use       basic
 */
class ajax
{
  use basic;

  /**
   * ����� (�����) ����� � ����� ����������� ��� ��� �������� �������
   *
   * @var static $_ajax_result
   * @static
   * @access public
   */
  public static $_ajax_result = array
           (
             'error' => 0,
             'error_text'     => '',
           );

  /**
   * ����������� ������ _ajax_result � ���������� ������
   *
   * @var final static function ch_result()
   * @static
   * @access public
   * @return null
   */
  final public static function ch_result()
  {
    if( !isset($GLOBALS['_ajax_result']) && !is_array($GLOBALS['_ajax_result']) )
    {
      $GLOBALS['_ajax_result'] = self::$_ajax_result;
    }
  }

  /**
   * ��������� ����� � ����������� �������� �� �� ����������� � JSON ������
   *
   * @var final static function result()
   * @static
   * @access public
   * @return string
   */
  final public static function result()
  {
    self::ch_result();
    $result = &$GLOBALS['_ajax_result'];

    $result = self::win2utf( $result );
    $result = json_encode( $result, JSON_NUMERIC_CHECK );
    return $result;
  }

  /**
   * ��������� ��������� ��� �������
   *
   * @var final static function set_error( $id
   * @static
   * @access public
   * @return bool
   */
  final public static function set_error( $id = 0, $text = '' )
  {
    self::set_data( 'error', $id );
    self::set_data( 'error_text', $text );
    return true;
  }

  /**
   * ��������� ����� ������� ����������� ��������
   *
   * @var final static function set_data( $name
   * @static
   * @access public
   * @return bool
   */
  final public static function set_data( $name, $data )
  {
    self::ch_result();
    $result = &$GLOBALS['_ajax_result'];

    $result[$name] = $data;
    return true;
  }
}

?>