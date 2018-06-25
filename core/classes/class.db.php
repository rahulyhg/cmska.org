<?php

//////////////////////////////////////////////////////////////////////////////////////////

if( !defined('GAUSS_CMS') ){ echo basename(__FILE__); exit; }

//////////////////////////////////////////////////////////////////////////////////////////

if( !trait_exists( 'basic' ) ){      require( CLASSES_DIR.DS.'trait.basic.php' ); }

//////////////////////////////////////////////////////////////////////////////////////////

define( 'QUERY_CACHABLE', ' -- %QUERY_CACHABLE' );

class db
{
    use basic;

    const   QUERY_LOG  = true;
    private $db_id = false;
    private $query_id = false;
    private $connected = false;

    public  $counters = array();
    public  $version = false;

    public  $num_rows = false;

    public final function __construct( $dbhost=false, $dbport=5432, $dbname=false, $dbuser=false, $dbpass=false, $schema=false, $charset=false, $collate=false )
    {
        $this->_DBHOST  = $dbhost;
        $this->_DBPORT  = $dbport;
        $this->_DBNAME  = $dbname;
        $this->_DBUSER  = $dbuser;
        $this->_DBPASS  = $dbpass;
        $this->_COLLATE = $collate;
        $this->_CHARSET = $charset;
        $this->_SCHEMA  = $schema;

        $this->connect();

        $this->version = pg_version();
        $this->version = $this->version['server'];
    }

    public final function __destruct()
    {
        $this->close();
    }

    public final function close()
    {
        if( $this->connected )
        {
            pg_close( $this->db_id );
        }
    }

    public function connect()
    {
        $this->db_id = pg_connect ('host='.$this->_DBHOST.' port='.$this->_DBPORT.' dbname='.$this->_DBNAME.' user='.$this->_DBUSER.' password='.$this->_DBPASS);

        if( !$this->db_id || pg_connection_status( $this->db_id ) !== PGSQL_CONNECTION_OK )
        {
            self::show_error('bad connection!');
        }
        else
        {
            $this->connected = true;
        }

        pg_query( $this->db_id, 'SET CLIENT_ENCODING TO \''.$this->_COLLATE.'\';');
        pg_query( $this->db_id, 'SET NAMES \''.$this->_COLLATE.'\';');
        pg_query( $this->db_id, 'SET search_path TO '.$this->_SCHEMA.', pg_catalog;');
        pg_query( $this->db_id, 'SET TIME ZONE \'EET\';');

        pg_set_client_encoding( $this->db_id, $this->_COLLATE );
    }

    public final function pg_meta_data( $table )
    {
        if( !$this->connected || !$this->db_id || !pg_ping($this->db_id) ){ $this->connect(); }
        return pg_meta_data( $this->db_id, $this->_SCHEMA.'.'.$table );
    }

    public final function safesql( $source )
    {
        return pg_escape_string( $source );
    }

    public final function log( $query )
    {
        $line = date('Y.m.d H:i:s').':'."\n".str_repeat('-',32)."\n".$query."\n".str_repeat('-',32)."\n";
        self::write_file( CACHE_DIR.DS.'sql.log', $line, true );
    }

    public final function query( $SQL )
    {
        if( !$this->connected || !$this->db_id || !pg_ping($this->db_id) ){ $this->connect(); }

        $this->query_id = pg_query( $this->db_id, $SQL );
        $this->num_rows = pg_num_rows($this->query_id);
        $status = pg_result_status( $this->query_id, PGSQL_STATUS_STRING );

        if( self::QUERY_LOG ){ self::log( $SQL ); }

        if( !isset($this->counters['queries']) ){ $this->counters['queries'] = 0; }
        if( !isset($this->counters['cached']) ){ $this->counters['cached'] = 0; }

        $this->counters['queries']++;

        if( strpos( $SQL, QUERY_CACHABLE ) !== false ){ $this->counters['cached']++; }

        if( $error = pg_last_error() )
        {
            self::show_error( $error );
        }

        return $this->query_id;
    }

    public final function get_row( $query_id = false )
    {
        if( !$query_id ){ $query_id = $this->query_id; }
        if( !$query_id ){ return false; }
        return pg_fetch_assoc( $query_id );
    }

    public final function get_query_rows( $query_id = false )
    {
        if( !$query_id ){ $query_id = &$this->query_id; }
        if( !$query_id ){ return false; }
        return abs( intval( pg_num_rows( $query_id ) ) );
    }

    public final function super_query( $query )
    {
        $rows = array();
        $qid = $this->query( $query );

        while($row = $this->get_row( $qid ))
        {
            $rows[] = $row;
        }
        $this->free( $qid );

        if( !count($rows) ){ $rows = array(); }
        if( count($rows) == 1 ){ $rows = $rows[0]; }

        return $rows;
    }

    public final function pg_version()
    {
        if( !$this->connected || !$this->db_id || !pg_ping($this->db_id) ){ $this->connect(); }

        return pg_version();
    }

    public final function version()
    {
        $SQL = 'SHOW server_version;';
        $SQL = $this->super_query( $SQL );
        return $SQL['server_version'];
    }

    public final function dbsize()
    {
        $SQL = 'SELECT pg_size_pretty(pg_database_size(\''.$this->_DBNAME.'\')) as size;';
        $SQL = $this->super_query( $SQL );
        return $SQL['size'];
    }

    public final function get_count( $query )
    {
        $count = $this->super_query($query);
        return abs(intval( isset($count['count'])?$count['count']:0 ));
    }

    public final function free( $query_id = '' )
    {
        if ( $query_id == '' ){ $query_id = &$this->query_id; }
        pg_free_result($query_id);
    }

    static private final function show_error( $error )
    {
        echo $error;
        exit;
    }
}

?>