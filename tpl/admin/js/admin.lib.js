var common = new function()
{
    this._NO_LOADER_FRAME = false;

    this.show_loader  = function(){ $('#overlay').removeClass('dnone'); }

    this.hide_loader  = function(){$('#overlay').addClass('dnone'); }

    this.close_dialog = function( dialog_id )
    {
        if( $( '#'+dialog_id ).hasClass('ui-dialog-content') )
        {
            $('#'+dialog_id).dialog("close");
        }
        $('#'+dialog_id).remove();
    }

    this.se = function( text = 'ololo!', type = 'error' )
    {
        alert( text );
    }
}



var AJAX = false;
var posts = new function()
{
    this.del = function( obj )
    {
        var post = {};
            post['ajax']        = 1;
            post['action']      = 100;
            post['mod']         = 'admin';
            post['subaction']   = 2;
            post['post_id']     = obj.attr( 'data-post_id' );
            post['post_hash']   = obj.attr( 'data-hash_key' );

            $.ajax({ "data": post }).done(function( _r )
            {
                try{ _r = jQuery.parseJSON( _r ); }catch(err){ common.se( 'ERROR: '+err+"\n\n"+_r, 'warning' ); return false; }
                if( parseInt(_r['error'])>0 ){ common.se( _r['error_text'], 'warning' ); return false; }

                window.location.href = window.location.href.replace(/post_id=([^&]+)/g, 'post_id=0');
                return false;
            });
    }

    this.save = function( obj )
    {
        var post = {};
            post['ajax']    = 1;
            post['action']  = 100;
            post['mod']     = 'admin';
            post['subaction'] = 1;
            post['save'] = {};

        $('#posteditor').find('[data-save="1"]').not('input[type="checkbox"]').each(function()
        {
            post['save'][$(this).attr('name')] = $(this).val();
        });

        $('#posteditor').find('input[type="checkbox"][data-save="1"]').each(function()
        {
            post['save'][$(this).attr('name')] = parseInt( $(this).prop('checked')?1:0 );
        });

        $('#posteditor').find('button[data-role="save"]').prop('disabled', true );
        common.show_loader();

        setTimeout(function()
        {
            $.ajax({ "data": post }).done(function( _r )
            {
                try{ _r = jQuery.parseJSON( _r ); }catch(err){ common.se( 'ERROR: '+err+"\n\n"+_r, 'warning' ); return false; }
                if( parseInt(_r['error'])>0 ){ common.se( _r['error_text'], 'warning' ); return false; }

                    _r['post_id'] = parseInt( _r['post_id'] );
                var curr_post_id = 0;
                if( window.location.href.match(/post_id=([^&]+)/) )
                {
                    curr_post_id = parseInt( window.location.href.match(/post_id=([^&]+)/)[1] );
                }

                if( _r['post_id'] != curr_post_id )
                {
                    if( window.location.href.match(/post_id=([^&]+)/) )
                    {
                        window.location.href = window.location.href.replace(/post_id=([^&]+)/g, 'post_id='+_r['post_id']).replace(/submod=([^&]+)/g, 'submod=20' );
                    }
                    else
                    {
                        window.location.href = window.location.href.replace(/submod=([^&]+)/g, 'submod=20' )+'&post_id=0';
                    }
                }
                else
                {
                    setTimeout(function()
                    {
                        $('#posteditor').find('button[data-role="save"]').prop('disabled', false );
                    }, 100 );
                }
                return true;
            });
        }, 800);




        return true;
    }
}

/**********************************************************************************************/
$(document).ready(function()
{

    $.ajaxSetup({
        "url":          $('html head base').attr('href'),
        "global":       false,
        "crossDomain":  false,
        "type":         "POST",
        "dataType":     "text",
        "async":        true,
        "cache":        false,
        // "processData" : false,
        // "contentType" : false,
        "timeout":      false,
        "beforeSend":   function()
                        {
                          AJAX = true;
                          if( !common._NO_LOADER_FRAME ){ common.show_loader(); }
                        },
        "complete":     function( jobj, ev )
                        {
                          AJAX = false;
                          common.hide_loader();
                        },
        "error":        function( jqXHRo, err_type ){ common.se( 'AJAX ERROR: '+err_type, 'warning' ); },
    });

    $('#overlay .close').click(function(){ common.hide_loader(); });

    $('select[data-value]').each(function()
    {
        $(this).val( $(this).attr('data-value') );
        $(this).scrollTop( $(this).find(':selected').position().top );
    });

    $('input[type="checkbox"][data-value]').each(function()
    {
        $(this).attr( 'checked', parseInt($(this).attr('data-value'))?true:false );
    });


    $('input[type="text"].input, input[type="password"].input, textarea.input, select.input')
        .focusin(function(){ $(this).addClass('active'); })
        .focusout(function(){ $(this).removeClass('active'); });

    $('#nav #nav_tree .nav_frame')
    .hover(
        function()
        {
            $('#nav #nav_tree .nav_frame').removeClass('wasactive');
            $('#nav #nav_tree .nav_frame.active').addClass('wasactive');
            $('#nav #nav_tree .nav_frame').removeClass('active');
            $(this).addClass('active');
        },
        function()
        {
            $('#nav #nav_tree .nav_frame').removeClass('active');
            $('#nav #nav_tree .nav_frame.wasactive').addClass('active').removeClass('wasactive');
        }
    );

    $('.admpage .admpage_nav ul li[data-area]')
    .click(
        function()
        {
            $(this).parents('.admpage_nav').find('li.active').removeClass('active');
            $(this).addClass('active');

            $('.admpage .adm_page_part[data-area]').addClass( 'dnone' );
            $('.admpage .adm_page_part[data-area]').removeClass( 'active' );
            $('.admpage .adm_page_part[data-area="'+$(this).attr('data-area')+'"]').removeClass( 'dnone' );
            $('.admpage .adm_page_part[data-area="'+$(this).attr('data-area')+'"]').addClass( 'active' );
        }
    );

    $('.admpage .adm_page_part select.input[data-bigsize]')
        .focusin(function()
        {
            $(this)
                .attr( 'data-size', parseInt($(this).attr( 'size' )) )
                .attr( 'size', parseInt($(this).attr('data-bigsize')) );
        })
        .focusout(function()
        {
            $(this).attr( 'size', parseInt($(this).attr( 'data-size' )) );
            $(this).scrollTop( $(this).find(':selected').position().top );
        });

    $('.bbpanel').click(function()
    {
        $(this).parent().find('textarea').addClass('active').focus();
    });

    $('.editpost button[data-role="save"]').click(function()
    {
        if( posts.save( $('#posteditor') ) ){ /*window.location.reload();*/ }
    });

    $('.editpost button[data-role="delete"]').click(function()
    {
        if( posts.del( $('#posteditor') ) ){ window.location.reload(); }
    });

    $('#page_frame #content .mainbox #post_list_frame .post_list').click( function(){ window.location = $(this).attr('data-editurl'); } );


    $('#upload_window form button').click(function()
    {
        uploading.get_config();
    });

    $('#configeditor button[data-role="save"]').click(function()
    {
        var save = {};

        $('#configeditor [data-save="1"]').each(function()
        {
           save[$(this).attr('name')] = $(this).val();
           if( $(this).attr('type') == 'checkbox' )
           {
                save[$(this).attr('name')] = $(this).is(':checked')?1:0;
           } 
        });


        var post = {};
            post['ajax']    = 1;
            post['action']  = 2;
            post['mod']     = 'admin';
            post['save'] = save;


        $.ajax({ data: post }).done(function( _r )
        {
            try{ _r = jQuery.parseJSON( _r ); }catch(err){ common.se( 'ERROR: '+err+"\n\n"+_r, 'warning' ); return false; }
            if( parseInt(_r['error'])>0 ){ common.se( _r['error_text'], 'warning' ); return false; }


            return false;
        });        
               
    });

});