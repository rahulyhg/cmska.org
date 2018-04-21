<!DOCTYPE HTML>
<html id="upload_window">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset={CHARSET}" />
        <title>Upload file</title>
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/jquery-ui.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/jquery-ui.structure.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/jquery-ui.theme.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/style.css" media="screen" />

        <script src="/tpl/js/jquery.js" type="text/javascript"></script>
        <script src="/tpl/js/jquery-ui.js" type="text/javascript"></script>
        <script src="{SKINDIR}/js/admin.lib.js" type="text/javascript"></script>
        <script src="{SKINDIR}/js/bbcodes.lib.js" type="text/javascript"></script>
        <script src="/tpl/js/uploader.js" type="text/javascript"></script>
    </head>
    <body>
        <form name="file" enctype="multipart/form-data" action="/index.php?ajax=1&mod={MOD}&action=12" method="post">
            <div id="upload_config">
                <table>
                    <tr>
                        <td><input data-value="{upload.image.compress}" id="_upl_conf_resize_image" class="input checkbox" type="checkbox" name="resize_image" value="1"><label class="label" for="_upl_conf_resize_image">Стиснути зображення</label></td>
                        <td>
                            <input type="text" class="input" step="1" value="{upload.image.compress.x}" name="res_x" required="required">
                            <span>X</span>
                            <input type="text" class="input" step="1" value="{upload.image.compress.y}" name="res_y" required="required">
                            <span>px</span>
                        </td>
                    </tr>
                     <tr>
                        <td><input data-value="{upload.image.mini}" id="_upl_conf_make_mini" class="input checkbox" type="checkbox" name="make_mini" value="1"><label class="label" for="_upl_conf_make_mini">Створити мініатюру</label></td>
                        <td>
                            <input type="text" class="input" step="1" value="{upload.image.mini.x}" name="mini_x" required="required">
                            <span>X</span>
                            <input type="text" class="input" step="1" value="200" name="{upload.image.mini.y}" required="required">
                            <span>px</span>
                        </td>
                    </tr>
                     <tr>
                        <td><input data-value="{upload.image.watermark}" id="_upl_conf_addwm" class="input checkbox" type="checkbox" name="addwm" value="1"><label class="label blue" for="_upl_conf_addwm">Накласти логотип</label></td>
                        <td><input data-value="{upload.image.mini.proportion}" id="_upl_conf_proportion" class="input checkbox" type="checkbox" name="proportion" value="1"><label class="label red" for="_upl_conf_proportion">Зберегти пропорції</label></td>
                    </tr>
                </table>
            </div>
            <input type="hidden" name="max_file_uploads" value="{max_file_uploads}" />
            <input type="hidden" name="upload_max_filesize" value="{upload_max_filesize}" />

            <input class="input" type="file" name="upfiles[]" required="required" multiple accept="{upload.image.ext},{upload.file.ext}">
            <button class="button type2" type="submit">Завантажити</button>
        </form>
    </body>
</html>