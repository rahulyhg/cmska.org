<li id="alogin">
[nologin]
<a href="/" data-role="dialog:open" data-dialog="loginform"><span>Вхід</span></a>

        <div id="loginform" title="Авторизація" data-role="dialog:window" data-dopts="1" data-width="240">
            <form method="post" action="/" name="loginform" if="floginform">
                <p><input class="input" type="text" name="login" /></p>
                <p><input class="input" type="password" name="pass" /></p>
                <p title="Оберіть ступінь шифрування"><keygen name="security" keytype="rsa"></p>
                <div class="fbutton">
                    <button class="button" type="submit">Вхід</button>
                </div>
            </form>
            <div class="center">
                <a href="/">Реєстрація</a> | <a href="/" data-role="dialog:close">Скасувати</a>
            </div>
        </div>
[/nologin]
[login]
<a href="/"><span>Профіль [{curr.user:login}]</span></a>
    <div class="submenu">
        <ul class="reset subnav">
            <li><a href="/">Профіль</a></li>
            <li><a href="/">Налаштування</a></li>
            [group:1]<li><a href="/index.php?mod=admin" target="_blank">Адмінпанель</a></li>[/group:1]
            <li><a href="/index.php?mod=logout">Вихід</a></li>
        </ul>
    </div>
[/login]
</li>