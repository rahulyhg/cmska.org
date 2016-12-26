<!DOCTYPE HTML>
<html lang="ua">
	<head>
        <meta http-equiv="Content-Type" content="text/html; charset={charset}" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
        <meta name="description" content="Test site">
        <meta name="keywords" content="CMS">
        <meta name="author" content="MrGauss">
        <meta name="application-name" content="Gauss CMS">

    	<base href="{HOME}">
    	<title>{title}</title>

        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/jquery-ui.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/jquery-ui.structure.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/jquery-ui.theme.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{SKINDIR}/css/style.css" media="screen" />

        <script src="/tpl/js/jquery.js" type="text/javascript"></script>
        <script src="/tpl/js/jquery-ui.js" type="text/javascript"></script>
        <script src="{SKINDIR}/js/main.lib.js" type="text/javascript"></script>
	</head>
	<body>

        <div id="page">
            <div class="wpage topnav noselect">
                <ul class="reset nav">
                    <li><a href="/"><span>Головна сторінка</span></a></li>
                    <li><a href="/"><span>Правила сайту</span></a>
                        <div class="submenu">
                            <ul class="reset subnav">
                                <li><a href="/">testing</a></li>
                                <li><a href="/">testing</a></li>
                                <li><a href="/">testing</a></li>
                                <li><a href="/">testing</a></li>
                            </ul>
                        </div>
                    </li>
                    <li><a href="/"><span>Зворотній зв'язок</span></a></li>
                    {global:login}
                </ul>
                <div class="clear"></div>
            </div>
            <div class="clear"></div>

            <div class="wpage logo noselect">
                <a href="/"><b><u>cmska</u>.org</b><i>Omnia mutantur, nihil interit</i></a>
                <div class="clear"></div>
            </div>
            <div class="clear"></div>

            <div class="wpage logonav">
                <ul class="reset logonav">
                    <li class="active"><a href=""><span>Головна</span></a></li>
                    <li><a href=""><span>Категорія 1</span></a></li>
                    <li><a href=""><span>Категорія 2</span></a>
                        <div class="submenu">
                            <ul class="reset subnav">
                                <li><a href="/">testing</a></li>
                                <li><a href="/">testing</a></li>
                                <li><a href="/">testing</a></li>
                                <li><a href="/">testing</a></li>
                            </ul>
                        </div>
                    </li>
                    <li><a href=""><span>Категорія 3</span></a></li>
                    <li><a href=""><span>Категорія 4</span></a></li>
                </ul>
                <div class="clear"></div>
            </div>
            <div class="clear"></div>

            <div class="wpage content">
                <div id="content">

                    {global:info}
                    {global:posts}

                </div>

                <aside id="aside">
                    <div class="frame">
                       asdasdasda
                    </div>
                </aside>

                <div class="clear"></div>
            </div>
            <div class="clear"></div>

            <div class="wpage footer">
                footer
                <div class="clear"></div>
            </div>
            <div class="clear"></div>

        </div>






	</body>
</html>