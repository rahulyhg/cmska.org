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

$(document).ready( function()
{
    $('.bbpanel [data-btype="simple"]').click(function()
    {
        var inp = document.getElementById( $(this).parents('.bbpanel').parent().find('textarea').attr('id') );
        bbcode.simple_tag( inp, $(this).attr('data-func'), ($(this).attr('data-func')=='br'?true:false) );
    });

    $('.bbpanel [data-func="file"]').click(function()
    {
        alert(1);
        var did = 'upload_frame';

        if( $( '#'+did ).hasClass('ui-dialog-content') ){ $('#'+did).dialog("close"); }
        $('#'+did).remove();
        $('#ajax').append('<div id="'+did+'" title="Uplod form">123</div>');

        var bi = 0;
        var dialog = {};
            dialog["zIndex"]  = 1001;
            dialog["modal"]   = true;
            dialog["width"]   = '700';

            dialog["buttons"] = {};
            dialog["buttons"][bi] = {};
            dialog["buttons"][bi]["text"]  = "Скасувати";
            dialog["buttons"][bi]["click"] = function(){  };
            dialog["buttons"][bi]["class"] = "type1";
            dialog["buttons"][bi]["data-role"] = "close_button";

        $('#'+did).dialog( dialog );
    });

});