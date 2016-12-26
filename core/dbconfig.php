<?php

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

$db = new db
(
  '127.0.0.1',   // HOST
  'cmska.org',   // DBNAME
  'cmska.org',   // DBUSER
  '$cmska.org%', // DBPASS
  'site',        // SCHEMA
  CHARSET,      // CHARSET
  'WIN1251'      // COLLATE
);

?>