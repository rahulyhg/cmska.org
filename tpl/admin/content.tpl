<!DOCTYPE HTML>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=CP1251" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
        <meta name="description" content="{title}">
        <meta name="keywords" content="CMS">
        <meta name="author" content="MrGauss">
        <meta name="application-name" content="Gauss CMS">
        <title>{title}</title>
        <base href="{HOME}">

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
        <div id="page_frame">

            <!--
            <div class="mainbox">
                <div id="header">
                    <div id="logo" class="noselect">MrGauss's&nbsp;CMS</div>
                    <div id="sublogo" class="noselect">Просто й надійно</div>
                    <div id="whoareme" class="noselect">
                        <span>Ви ввійшли як <b>MrGauss</b> [192.168.2.1]</span>
                    </div>
                </div>
            </div>
            -->
            <div class="clear"></div>

            <div id="nav">
                <div class="mainbox">
                    {global:main_navigation}
                </div>

            </div>
            <div class="clear"></div>

            <div id="content">
                <div class="mainbox">

                    {global:info}
                    {global:page_item}

                </div>
            </div>
        </div>



        <div id="overlay" class="dnone">
            <div class="overlay"></div>
            <div class="close"></div>
            <div id="progress"></div>
            <div id="maessage"></div>
        </div>

        <div id="ajax"></div>

    </body>
</html>