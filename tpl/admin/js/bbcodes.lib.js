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
};


$(document).ready( function()
{
    $('.bbpanel [data-btype="simple"]').click(function()
    {
        var inp = document.getElementById( $(this).parents('.bbpanel').parent().find('textarea').attr('id') );
        bbcode.simple_tag( inp, $(this).attr('data-func'), ($(this).attr('data-func')=='br'?true:false) );
    });

    $('.bbpanel [data-func="file"]').click(function()
    {
        uploader.dialog();
    });

});