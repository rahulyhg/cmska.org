var bbcode = new function()
{
    this.getselected = function( obj )
    {
        return obj.value.substring( obj.selectionStart, obj.selectionEnd );
    };

    this.replace_selected = function( obj, repltext )
    {
        return obj.value.substring( 0, obj.selectionStart) + repltext + obj.value.substring(obj.selectionEnd);
    };

    this.simple_tag = function( obj, tag, single )
    {
        obj.value = ( bbcode.replace_selected( obj, '['+tag+']' + bbcode.getselected( obj ) + (single?'':'[/'+tag+']') ) );
    }
}

var uploading = new function()
{
    this.config_id = "upload_config";

    this.get_config = function()
    {
        var cf = $('#'+uploading.config_id, window.parent.document);

        alert( cf.html() );
    }

}

$(document).ready( function()
{
    $('.bbpanel [data-btype="simple"]').click(function()
    {
        var inp = document.getElementById( $(this).parents('.bbpanel').parent().find('textarea').attr('id') );
        bbcode.simple_tag( inp, $(this).attr('data-func'), ($(this).attr('data-func')=='br'?true:false) );
    });

    $('.bbpanel [data-func="file"]').click(function()
    {
        var did = 'upload_frame';
            close_dialog( did );

        var post = {};
            post['ajax']    = 1;
            post['action']  = 10;
            post['mod']     = 'admin';
            post['subaction'] = 0;

        $.ajax({ data: post }).done(function( _r )
        {
            try{ _r = jQuery.parseJSON( _r ); }catch(err){ alert( 'ERROR: '+err+"\n\n"+_r ); return false; }
            if( parseInt(_r['error'])>0 ){ alert( _r['error_text'] ); return false; }

            $('#ajax').append('<div id="'+did+'" title="'+lng.upload.form_title+'">'+_r['template']+'</div>');


            return false;
        });

        var bi = 0;
        var dialog = {};
            dialog["zIndex"]  = 1001;
            dialog["modal"]   = true;
            dialog["width"]   = '560';

            dialog["buttons"] = {};
            dialog["buttons"][bi] = {};
            dialog["buttons"][bi]["text"]  = "Скасувати";
            dialog["buttons"][bi]["click"] = function(){ close_dialog( did ); };
            dialog["buttons"][bi]["class"] = "type1";
            dialog["buttons"][bi]["data-role"] = "close_button";

        $('#'+did).dialog( dialog );
    });

});