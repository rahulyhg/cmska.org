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
    this.save = function( obj )
    {
        var post = {};
            post['ajax']    = 1;
            post['action']  = 100;
            post['mod']     = 'admin';
            post['subaction'] = 1;
            post['save'] = {};

        //var b = '';

        $('#posteditor').find('[data-save="1"]').each(function()
        {
            post['save'][$(this).attr('name')] = $(this).val();
            //b = b + "\n" + $(this).attr('name') + ':' + $(this).val();
        });



        $.ajax({ data: post }).done(function( _r )
        {
            try{ _r = jQuery.parseJSON( _r ); }catch(err){ common.se( 'ERROR: '+err+"\n\n"+_r, 'warning' ); return false; }
            if( parseInt(_r['error'])>0 ){ common.se( _r['error_text'], 'warning' ); return false; }


            return false;
        });
    }
}



/**********************************************************************************************/

var uploading = new function()
{
    this.config_id = "upload_config";

    this.get_config = function()
    {
        var cf = $('#'+uploading.config_id, window.parent.document);
        cf.find('input').each( function()
        {
            var name = $(this).attr('name');
            var val  = $(this).val();

            if( $(this).attr('type') == 'checkbox' )
            {
                val = $(this).is(":checked")?1:0;
            }

            $('#upload_window form [name="'+name+'"]').remove();
            $('#upload_window form input[type="file"]').after( '<input type="hidden" name="'+name+'" value="'+val+'">' );

        } );
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

    $('.editpost button[data-role="save"]').click(function(){ posts.save( $('#posteditor') ); window.location.reload(); });

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