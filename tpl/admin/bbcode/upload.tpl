<div id="file_list">
    <div id="ins"></div>
    <div id="lnks">
        <div><input type="text" name="imgtagtitle"></div>
        <div><input type="text" name="url" readonly="readonly"></div>
        <div><input type="text" name="tag" readonly="readonly"></div>
    </div>
</div>

<div id="upload_frame">
        <form name="file" enctype="multipart/form-data" action="/index.php?ajax=1&mod={MOD}&action=12&post_id={post:id}" method="post">
            <div id="upload_config">
                <div class="conf ptop">
                    <input data-value="{upload.image.compress}" id="_upl_conf_resize_image" class="input checkbox" type="checkbox" name="upload.image.compress" value="1">
                    <label class="label" for="_upl_conf_resize_image">Стиснути зображення</label>
                </div>

                <div class="conf">
                    <input type="text" class="input" step="1" value="{upload.image.compress.x}" name="upload.image.compress.x" required="required">
                    <span>X</span>
                    <input type="text" class="input" step="1" value="{upload.image.compress.y}" name="upload.image.compress.y" required="required">
                    <span>px</span>
                </div>

                <div class="conf ptop">
                    <input data-value="{upload.image.mini}" id="_upl_conf_make_mini" class="input checkbox" type="checkbox" name="upload.image.mini" value="1">
                    <label class="label" for="_upl_conf_make_mini">Створити мініатюру</label>
                </div>

                <div class="conf">
                    <input type="text" class="input" step="1" value="{upload.image.mini.x}" name="upload.image.mini.x" required="required">
                    <span>X</span>
                    <input type="text" class="input" step="1" value="{upload.image.mini.y}" name="upload.image.mini.y" required="required">
                    <span>px</span>
                </div>
                <div class="conf"><input data-value="{upload.image.mini.proportion}" id="_upl_conf_proportion" class="input checkbox" type="checkbox" name="upload.image.mini.proportion" value="1"><label class="label red" for="_upl_conf_proportion">Пропорційна мініатюра</label></div>

                <div class="conf ptop"><input data-value="{upload.image.watermark}" id="_upl_conf_addwm" class="input checkbox" type="checkbox" name="upload.image.watermark" value="1"><label class="label blue" for="_upl_conf_addwm">Накласти логотип</label></div>

            </div>

            <input type="hidden" name="max_file_uploads" value="{max_file_uploads}" />
            <input type="hidden" name="upload_max_filesize" value="{upload_max_filesize}" />

            <input class="input" type="file" name="upfiles[]" required="required" multiple accept="{upload.image.ext},{upload.file.ext}">
            <div class="button-panel"><button class="button type2" type="submit">Завантажити</button></div>
        </form>
</div>