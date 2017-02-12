var common = new function()
{
    this._NO_LOADER_FRAME = false;
    this.show_loader = function(){ $('#overlay').removeClass('dnone'); } // TESTING GIT
    this.hide_loader = function(){$('#overlay').addClass('dnone'); }
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
            try{ _r = jQuery.parseJSON( _r ); }catch(err){ alert( 'ERROR: '+err+"\n\n"+_r ); return false; }
            if( parseInt(_r['error'])>0 ){ alert( _r['error_text'] ); return false; }


            return false;
        });
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
        "async":        false,
        "cache":        false,
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
        "error":        function( jqXHRo, err_type ){ alert( 'AJAX ERROR: '+err_type ); },
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

    $('.editpost .editor_nav ul li[data-area]')
    .click(
        function()
        {
            $(this).parents('.editor_nav').find('li.active').removeClass('active');
            $(this).addClass('active');

            $('.editpost .main_editor[data-area]').addClass( 'dnone' );
            $('.editpost .main_editor[data-area]').removeClass( 'active' );
            $('.editpost .main_editor[data-area="'+$(this).attr('data-area')+'"]').removeClass( 'dnone' );
            $('.editpost .main_editor[data-area="'+$(this).attr('data-area')+'"]').addClass( 'active' );
        }
    );

    $('.editpost .main_editor select.input[data-bigsize]')
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

});