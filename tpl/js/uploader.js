var uploader = new function()
{
    this.dialog = function()
    {
        var did = 'upload_frame';
            common.close_dialog( did );

        var post = {};
            post['ajax']        = 1;
            post['action']      = 10;
            post['mod']         = 'admin';
            post['subaction']   = 0;
            post['post_id']    = parseInt( $('input[data-role="uploader:post_id"]').val() );

        $.ajax({ data: post }).done( function( _r )
        {
            try{ _r = jQuery.parseJSON( _r ); }catch(err){ alert( 'ERROR: '+err+"\n\n"+_r ); return false; }
            if( parseInt(_r['error'])>0 ){ alert( _r['error_text'] ); return false; }

            $('#ajax').append('<div id="'+did+'" title="'+lng.upload.form_title+'">'+_r['template']+'</div>');

            var bi = 0;
            var dialog = {};
                dialog["zIndex"]  = 1001;
                dialog["modal"]   = true;
                dialog["width"]   = '760';



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

                uploader.config();
                uploader.init_check();
                uploader.submit();
                uploader.show_uploaded();

            $('#'+did).dialog( dialog );
        } );
    }


    this.submit = function()
    {
        $('#upload_frame form').submit(function( event )
        {
            if( !$(this).find('input[type="file"]').prop('files').length ){ return false; }

            var form = $(this);
            var _files;
            _files = form.find('input[type="file"]').prop('files');

            event.stopPropagation();
            event.preventDefault();

            if( typeof _files == 'undefined' ) return false;

            var _fdata = new FormData();
            $.each( _files, function( key, value ){ _fdata.append( key, value ); });

            _fdata.append( 'my_file_upload', 1 );

            form.find('#upload_config input[type="checkbox"]').each(function(){ _fdata.append( 'config['+$(this).attr('name')+']', $(this).prop('checked')?1:0 ); });
            form.find('#upload_config input[type="text"]').each(function(){ _fdata.append( 'config['+$(this).attr('name')+']', $(this).val() ); });

            $.ajax({
                "url"         : form.attr('action'),
                "type"        : 'POST',
                "data"        : _fdata,
                "cache"       : false,
                "dataType"    : 'text',
                "processData" : false,
                "contentType" : false
            }).done(function( _r )
            {
                try{ _r = jQuery.parseJSON( _r ); }catch(err){ alert( 'ERROR: '+err+"\n\n"+_r ); return false; }
                if( parseInt(_r['error'])>0 ){ alert( _r['error_text'] ); return false; }

                //form.find('input[type="file"]').val( false );
                form.find('button[type="submit"]').attr( 'disabled', true );
                common.hide_loader();
                uploader.show_uploaded();
            });

            return false;
        });
    }


    this.init_check = function()
    {
        $('#upload_frame form input[type="file"]').change(function(){ uploader.check_files($(this)); });
    }

    this.config = function()
    {
        $('#upload_frame').find('button[type="submit"]').attr( 'disabled', true );
        $('#upload_frame input[type="checkbox"][data-value]').each(function()
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

    this.tag = function()
    {
        var url = $('#lnks').find('input[name="url"]').val();
        var ttl = $('#lnks').find('input[name="imgtagtitle"]').val();

        if( ttl.length > 0 ){ ttl = '|'+ttl; }
        else{ ttl = ''; }

        var tag = '[img'+ttl+']'+url+'[/img]';
        $('#lnks').find('input[name="tag"]').val(tag);
        $('#lnks').find('input[name="tag"]').select();
        document.execCommand("copy");
    }

    this.del = function( hash, area )
    {
        var post = {};
            post['ajax']        = 1;
            post['action']      = 13;
            post['mod']         = 'admin';
            post['subaction']   = 0;
            post['hash']    = hash;
            post['area']    = area;

        $.ajax({ data: post }).done( function( _r )
        {
            try{ _r = jQuery.parseJSON( _r ); }catch(err){ alert( 'ERROR: '+err+"\n\n"+_r ); return false; }
            if( parseInt(_r['error'])>0 ){ alert( _r['error_text'] ); return false; }

            $('#lnks').find('input[name="url"]').val( '' );
            $('#lnks').find('input[name="tag"]').val( '' );

            uploader.show_uploaded();
        });
    }

    this.show_uploaded = function()
    {
        var post = {};
            post['ajax']        = 1;
            post['action']      = 11;
            post['mod']         = 'admin';
            post['subaction']   = 0;
            post['post_id']    = parseInt( $('input[data-role="uploader:post_id"]').val() );

        $.ajax({ data: post }).done( function( _r )
        {
            try{ _r = jQuery.parseJSON( _r ); }catch(err){ alert( 'ERROR: '+err+"\n\n"+_r ); return false; }
            if( parseInt(_r['error'])>0 ){ alert( _r['error_text'] ); return false; }

            $('#file_list #ins').html( _r['template'] );

            $('#file_list #ins').find('.bttns .del').click(function()
            {
                uploader.del( $(this).parents('.uploaded').unbind().find('img').attr('data-hash'), $(this).parents('.uploaded').attr('data-type') );
            });

            $('#file_list .uploaded').unbind().click(
            function()
            {
                if( $(this).attr('data-type') == 'image' )
                {
                    $('#lnks').find('input[name="url"]').val( $(this).find('img').attr('src') );
                    $('#lnks').find('input[name="imgtagtitle"]').val( '' );


                    uploader.tag();

                    $('#lnks').find('input[name="tag"]').unbind().click(function(){$(this).select();});
                    $('#lnks').find('input[name="url"]').unbind().click(function(){$(this).select();});
                    $('#lnks').find('input[name="imgtagtitle"]').unbind().change(function(){uploader.tag();});
                }

                if( $(this).attr('data-type') == 'file' )
                {
                    $('#lnks').find('input[name="url"]').val( $(this).attr('data-hash') );
                    $('#lnks').find('input[name="imgtagtitle"]').val( $(this).attr('data-origname') );

                    var url = $('#lnks').find('input[name="url"]').val();
                    var ttl = $('#lnks').find('input[name="imgtagtitle"]').val();

                    if( ttl.length > 0 ){ ttl = '|'+ttl; }
                    else{ ttl = ''; }

                    var tag = '[attach]'+url+'[/attach]';
                    $('#lnks').find('input[name="tag"]').val(tag);
                    $('#lnks').find('input[name="tag"]').select();
                    document.execCommand("copy");

                    $('#lnks').find('input[name="tag"]').unbind().click(function(){$(this).select();});
                    $('#lnks').find('input[name="url"]').unbind().click(function(){$(this).select();});
                    $('#lnks').find('input[name="imgtagtitle"]').unbind().change(function()
                    {
                        var url = $('#lnks').find('input[name="url"]').val();
                        var ttl = $('#lnks').find('input[name="imgtagtitle"]').val();

                        if( ttl.length > 0 ){ ttl = '|'+ttl; }
                        else{ ttl = ''; }

                        var tag = '[attach'+ttl+']'+url+'[/attach]';
                        $('#lnks').find('input[name="tag"]').val(tag);
                        $('#lnks').find('input[name="tag"]').select();
                        document.execCommand("copy");
                    });
                }

            });
        });
    }
}