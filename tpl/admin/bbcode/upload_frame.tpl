<!DOCTYPE HTML>
<html id="upload_window">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=CP1251" />
        <title>Upload file</title>
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/jquery-ui.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/jquery-ui.structure.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/jquery-ui.theme.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/style.css" media="screen" />

        <script src="/tpl/js/jquery.js" type="text/javascript"></script>
        <script src="/tpl/js/jquery-ui.js" type="text/javascript"></script>
        <script src="{SKINDIR}/js/admin.lib.js" type="text/javascript"></script>
        <script src="{SKINDIR}/js/bbcodes.lib.js" type="text/javascript"></script>
    </head>
    <body>
        <form name="file" action="/index.php?ajax=1&mod={MOD}&action=12" method="post">
            <input class="input" type="file" name="file" required multiple>
            <button class="button type2">Завантажити</button>
        </form>
    </body>
</html>