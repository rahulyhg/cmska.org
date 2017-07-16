<div class="elemblock admpage editpost" id="posteditor">

    <input type="hidden" name="post:id" value="{post:id}" data-save="1" />

    <div class="admpage_nav">
        <ul class="reset">
            <li class="active anim" data-area="main">Основні дані</li>
            <li class="anim" data-area="seometa">SEO</li>
            <li class="anim" data-area="votes">Опитування</li>
            <li class="anim" data-area="access">Режими доступу</li>
            <li class="anim" data-area="linked_data">Зв'язані дані</li>
        </ul>
        <div class="buttons">
            <button type="button" class="type2" data-role="save">Зберегти</button>
            <button type="button" class="type1" data-role="delete">Видалити</button>
            <button type="button" class="type3" data-role="exit">Скасувати</button>
        </div>
    </div>

    <div class="adm_page_part active" data-area="main">

        <div class="editor_line">
            <div class="frame"><label class="label">Категорія:</label></div>
            <div class="frame">
                <select size="3" data-bigsize="8" class="input" data-save="1" name="categ:id" data-value="{categ:id}">
                    {categ:list}
                </select>
            </div>
        </div>

        <div class="editor_line">
            <div class="frame"><label class="label">Заголовок:</label><span class="labelinfo">до 250 символів</span></div>
            <div class="frame"><input class="input" type="text" name="post:title" data-save="1" value="{post:title}"></div>
        </div>

        <div class="editor_line">
            <div class="frame"><label class="label">Короткий текст публікацї:</label><span class="labelinfo">до 1000 символів</span></div>
            <div class="frame">
                {@include=bbpanel}
                <textarea id="shortpost" rows="4" class="input withbb" type="text" data-save="1" name="post:short_post">{post:short_post}</textarea>
            </div>
        </div>

        <div class="editor_line">
            <div class="frame"><label class="label">Повний текст публікацї:</label></div>
            <div class="frame">
                {@include=bbpanel}
                <textarea id="fullpost" rows="10" class="input withbb" type="text" data-save="1" name="post:full_post">{post:full_post}</textarea>
            </div>
        </div>

    </div>

    <div class="adm_page_part dnone" data-area="seometa">

        <div class="editor_line">
            <div class="frame"><label class="label">Текст гіперпосилання:</label><span class="labelinfo">тільки латиниця, до 64 символів</span></div>
            <div class="frame"><input class="input" type="text" name="post:alt_title" data-save="1" value="{post:alt_title}"></div>
        </div>

        <div class="editor_line">
            <div class="frame"><label class="label">Автор:</label><span class="labelinfo">&lt;meta name=&quot;author&quot; content=&quot;...</span></div>
            <div class="frame"><input class="input" type="text" name="post:author" data-save="1" value="{post:author}"></div>
        </div>

        <div class="editor_line">
            <div class="frame"><label class="label">Опис публікації:</label><span class="labelinfo">&lt;meta name=&quot;description&quot; content=&quot;...</span></div>
            <div class="frame"><textarea rows="2" class="input" type="text" data-save="1" name="post:descr">{post:descr}</textarea></div>
        </div>

        <div class="editor_line">
            <div class="frame"><label class="label">Ключові слова:</label><span class="labelinfo">&lt;meta name=&quot;keywords&quot; content=&quot;...</span></div>
            <div class="frame"><input class="input" type="text" name="post:keywords" data-save="1" value="{post:keywords}"></div>
        </div>
    </div>
    <div class="adm_page_part dnone" data-area="votes">
        <div><input class="input checkbox" type="checkbox" id="ch111"><label class="label" for="ch111">testing 1</label></div>
        <div><input class="input checkbox" type="checkbox" id="ch112"><label class="label red" for="ch112">testing 2</label></div>
        <div><input class="input checkbox" type="checkbox" id="ch113"><label class="label blue" for="ch113">testing 3</label></div>
    </div>
    <div class="adm_page_part dnone" data-area="access">3</div>
    <div class="adm_page_part dnone" data-area="linked_data">4</div>

    <div class="clear"></div>



</div>