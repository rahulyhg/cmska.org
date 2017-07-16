<div id="uploaded_files">

</div>
<div id="upload_config">
    <table>
        <tr>
            <td><input id="_upl_conf_resize_image" class="input checkbox" type="checkbox" name="resize_image"   value="1"><label class="label" for="_upl_conf_resize_image">Стиснути зображення</label></td>
            <td>
                <input type="text" class="input" step="1" value="800" name="res_x" required>
                <span>X</span>
                <input type="text" class="input" step="1" value="600" name="res_y" required>
                <span>px</span>
            </td>
        </tr>
         <tr>
            <td><input id="_upl_conf_make_mini" class="input checkbox" type="checkbox" name="make_mini"   value="1"><label class="label" for="_upl_conf_make_mini">Створити мініатюру</label></td>
            <td>
                <input type="text" class="input" step="1" value="200" name="mini_x" required>
                <span>X</span>
                <input type="text" class="input" step="1" value="200" name="mini_y" required>
                <span>px</span>
            </td>
        </tr>
         <tr>
            <td><input id="_upl_conf_addwm" class="input checkbox" type="checkbox" name="addwm" value="1"><label class="label blue" for="_upl_conf_addwm">Накласти логотип</label></td>
            <td><input id="_upl_conf_proportion" class="input checkbox" type="checkbox" name="proportion" value="1"><label class="label red" for="_upl_conf_proportion">Зберегти пропорції</label></td>
        </tr>
    </table>
</div>
<div id="upload_frame">
    <iframe src="/index.php?ajax=1&mod={MOD}&action=11"></iframe>
</div>