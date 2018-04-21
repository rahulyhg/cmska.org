var uploader = new function()
{
    this.dialog = function()
    {
        var did = 'upload_frame';
            common.close_dialog( did );

        var post = {};
            post['ajax']    = 1;
            post['action']  = 10;
            post['mod']     = 'admin';
            post['subaction'] = 0;

        $.ajax({ data: post }).done( function( _r )
        {
            try{ _r = jQuery.parseJSON( _r ); }catch(err){ alert( 'ERROR: '+err+"\n\n"+_r ); return false; }
            if( parseInt(_r['error'])>0 ){ alert( _r['error_text'] ); return false; }

            $('#ajax').append('<div id="'+did+'" title="'+lng.upload.form_title+'">'+_r['template']+'</div>');

            var bi = 0;
            var dialog = {};
                dialog["zIndex"]  = 1001;
                dialog["modal"]   = true;
                dialog["width"]   = '560';

                /*dialog["buttons"] = {};
                dialog["buttons"][bi] = {};
                dialog["buttons"][bi]["text"]  = "Скасувати";
                dialog["buttons"][bi]["click"] = function(){ common.close_dialog( did ); };
                dialog["buttons"][bi]["class"] = "type1";
                dialog["buttons"][bi]["data-role"] = "close_button";

                bi++;
                dialog["buttons"][bi] = {};
                dialog["buttons"][bi]["text"]  = "Зберегти";
                dialog["buttons"][bi]["click"] = function(){ common.close_dialog( did ); };
                dialog["buttons"][bi]["class"] = "type2";
                dialog["buttons"][bi]["data-role"] = "save_button";   */


            $('#'+did).dialog( dialog );
        } );
    }
    this.config = function()
    {
        $('#upload_window').find('button[type="submit"]').attr( 'disabled', true );
        $('#upload_window input[type="checkbox"][data-value]').each(function()
        {
            if( parseInt($(this).attr('data-value'))>0 )
            {
                $(this).attr('checked', true);
            }
            else
            {
                $(this).attr('checked', false);
            }
        });
    }
    this.check_files = function( obj )
    {
        if( !obj.prop('files').length ){ return false; }

        var max_file_uploads = parseInt( obj.parents('form').find('input[name="max_file_uploads"]').val() );
        var upload_max_filesize = parseInt( obj.parents('form').find('input[name="upload_max_filesize"]').val() );

        var button = obj.parents('form').find('button');

        if( obj.prop('files').length > max_file_uploads )
        {
            common.se( 'Ви намагаєтесь завантажити занадто багато файлів!<br>Максимум - ' + max_file_uploads, 'info' );
            button.attr( 'disabled', 'disabled' );
            return false;
        }

        var i = 0;
        for( var i = 0; i < obj.prop('files').length; i++ )
        {
            var file = obj.prop('files').item(i);
            // console.log( file );

            if( file['size'] > upload_max_filesize )
            {
                common.se( 'Файл "'+file['name']+'" має занадто великий розмір ('+(parseInt(file['size']/1024))+'kb)!', 'warning' );
                button.attr( 'disabled', 'disabled' );
                return false;
            }
        }

        button.attr( 'disabled', false );
    }
}

$(document).ready( function()
{
    uploader.config();
    $('#upload_window form input[type="file"]').change(function(){ uploader.check_files($(this)); });
});