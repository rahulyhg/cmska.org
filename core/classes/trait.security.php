<?php

    //////////////////////////////////////////////////////////////////////////////////////////

    if (!defined('GAUSS_CMS'))
    {
        echo basename(__FILE__);
        exit;
    }

    //////////////////////////////////////////////////////////////////////////////////////////

    trait security
    {
        public static final function OTHER_send()
        {
            # header( 'Strict-Transport-Security: max-age=15768000; includeSubDomains' );
            # header( 'X-Frame-Options: DENY' );
            # header( 'X-XSS-Protection: 1; mode=block' );
            # header( 'X-Content-Type-Options: nosniff' );
        }

        public static final function CSP_send()
        {
            # header( 'Content-Security-Policy: default-src \'self\'; media-src \'self\' *.youtube.com; script-src \'self\' *.googleapis.com connect.facebook.net cdnjs.cloudflare.com maps.gstatic.com *.youtube.com; frame-src \'self\' *.youtube.com' );
        }

        public static final function CORS_send()
        {
            $_config    = config::get();
            $domains = isset($_config['security.cors'])?$_config['security.cors']:false;

            $domains = explode( ' ', $domains );
            if( !is_array($domains) || !count($domains) ){ return false; }

            $domains = 'https://'.implode( ' https://', $domains );
            header( 'Access-Control-Allow-Origin: '.$domains );

        }

    }

?>