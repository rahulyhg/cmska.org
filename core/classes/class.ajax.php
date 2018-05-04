<?php
/**
 * class.ajax.php
 *
 * клас для обробки даних при AJAX-запитах
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
 * Клас для отримання та обробки даних, що передаються при формуванні AJAX-запитів
 * Функціонал класу дозволяє створювати спеціальну змінну в глобальному адресному просторі
 * з подальшою обробкою даних в межах цієї змінної.
 * Вихідні дані завжди формуються в форматі JSON
 *
 * @author    MrGauss <author@cmska.org>
 * @package   cmska.org
 * @use       basic
 */
class ajax
{
  use basic;

  /**
   * Маска (макет) змінної в котру записуються дані для подальшої обробки
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
   * Перенесення макету _ajax_result в глобальний простір
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
   * Отримання даних з глобального простору та їх конвертація в JSON формат
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
   * Занесення відомостей про помилку
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
   * Занесення даних дозмінної глобального простору
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