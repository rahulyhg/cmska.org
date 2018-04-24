--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.12
-- Dumped by pg_dump version 9.5.12

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: cmska.org; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE "cmska.org" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'ru_UA.UTF-8' LC_CTYPE = 'ru_UA.UTF-8';


\connect "cmska.org"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- Name: site; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "site";


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA "pg_catalog";


--
-- Name: EXTENSION "plpgsql"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "plpgsql" IS 'PL/pgSQL procedural language';


--
-- Name: GEN_PTREE_MULTILIST_AFTER(); Type: FUNCTION; Schema: site; Owner: -
--

CREATE FUNCTION "site"."GEN_PTREE_MULTILIST_AFTER"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$DECLARE
	
BEGIN

	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		IF NEW.ptree::TEXT = 'LOOP'::TEXT THEN
			RETURN NEW;
		END IF;
	END IF;

	IF TG_OP != 'INSERT' THEN
			EXECUTE 'UPDATE ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' SET ptree=' || quote_nullable( ''::text ) || '::text WHERE id !=' || OLD.id || '::integer AND parent_id=' || OLD.id || '::integer;';	
	END IF;

	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		RETURN NEW;
	END IF;

	RETURN OLD;
END;$$;


--
-- Name: GEN_PTREE_MULTILIS_BEFORE(); Type: FUNCTION; Schema: site; Owner: -
--

CREATE FUNCTION "site"."GEN_PTREE_MULTILIS_BEFORE"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$DECLARE
	
	counter int4;
	itree int8[];
	pid int8;

BEGIN

	counter = 0;
	itree = Array[]::int8[];
	pid = NULL;

	pid = NEW.parent_id::int8;
	itree = array_append( itree, pid::int8 );

	WHILE pid> 0
	LOOP

		EXECUTE 'SELECT parent_id FROM ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' WHERE "id"=' || pid || '::INTEGER ' INTO pid;
		itree = array_append( itree, pid::int8 );

		counter = counter + 1;

		IF counter > 15 THEN
			NEW.ptree = 'LOOP'::text;
			RETURN NEW;
		END IF;

	END LOOP;

	SELECT ARRAY( SELECT itree[i] FROM generate_subscripts(itree,1) AS s(i) ORDER BY i DESC ) INTO itree;

	NEW.ptree = array_to_string(itree, '-')::text;
	NEW.level = counter;

  RETURN NEW;
END;$$;


--
-- Name: before_ins_upd_posts(); Type: FUNCTION; Schema: site; Owner: -
--

CREATE FUNCTION "site"."before_ins_upd_posts"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$DECLARE
	
STXT text;

BEGIN

	STXT = NEW.svector;

	NEW.svector = 
		setweight( coalesce( to_tsvector( lower(NEW.keywords) ),''),'A') || ' ' || 
		setweight( coalesce( to_tsvector( lower(NEW.descr)),''),'B') || ' ' ||
		setweight( coalesce( to_tsvector( lower(NEW.title)),''),'C') || ' ' ||
		setweight( coalesce( to_tsvector( lower( STXT )),''),'D');

  RETURN NEW;
END;$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin_menu; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."admin_menu" (
    "id" integer NOT NULL,
    "parent_id" integer DEFAULT 0 NOT NULL,
    "ptree" "text" DEFAULT ''::"text" NOT NULL,
    "level" integer DEFAULT 0 NOT NULL,
    "name" character varying(255) DEFAULT ''::character varying NOT NULL,
    "descr" character varying(255) DEFAULT ''::character varying NOT NULL,
    "show_at_nav" smallint DEFAULT 1 NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "altname" character varying(255) DEFAULT ''::character varying NOT NULL,
    "is_default" smallint DEFAULT 0 NOT NULL
);


--
-- Name: admin_menu_accesses; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."admin_menu_accesses" (
    "item_id" integer DEFAULT 0 NOT NULL,
    "group_id" integer DEFAULT 0 NOT NULL
);


--
-- Name: admin_menu_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "site"."admin_menu_id_seq"
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "site"."admin_menu_id_seq" OWNED BY "site"."admin_menu"."id";


--
-- Name: categories; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."categories" (
    "id" integer NOT NULL,
    "altname" character varying(255) DEFAULT ''::character varying NOT NULL,
    "name" character varying(255) DEFAULT ''::character varying NOT NULL,
    "parent_id" integer DEFAULT 0 NOT NULL,
    "ptree" "text" DEFAULT ''::"text" NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "level" integer DEFAULT 0 NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "site"."categories_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "site"."categories_id_seq" OWNED BY "site"."categories"."id";


--
-- Name: files; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."files" (
    "sha1" character varying(40) DEFAULT ''::character varying NOT NULL,
    "load_time" timestamp without time zone DEFAULT ("now"())::timestamp without time zone NOT NULL,
    "orig_name" character varying(255) DEFAULT ''::character varying NOT NULL,
    "size" integer DEFAULT 0 NOT NULL,
    "user_id" bigint DEFAULT 0 NOT NULL,
    "post_id" bigint DEFAULT 0 NOT NULL
);


--
-- Name: images; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."images" (
    "post_id" bigint DEFAULT 0 NOT NULL,
    "user_id" bigint DEFAULT 0 NOT NULL,
    "serv_name" character varying(32) DEFAULT ''::character varying NOT NULL,
    "load_time" timestamp without time zone DEFAULT ("now"())::timestamp without time zone NOT NULL
);


--
-- Name: posts; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."posts" (
    "id" bigint NOT NULL,
    "title" character varying(255) DEFAULT ''::character varying NOT NULL,
    "alt_title" character varying(255) DEFAULT ''::character varying NOT NULL,
    "descr" character varying(255) DEFAULT ''::character varying NOT NULL,
    "short_post" "text" DEFAULT ''::"text" NOT NULL,
    "full_post" "text" DEFAULT ''::"text" NOT NULL,
    "author_id" integer DEFAULT 0 NOT NULL,
    "created_time" timestamp without time zone DEFAULT ("now"())::timestamp without time zone NOT NULL,
    "svector" "tsvector" DEFAULT ''::"tsvector" NOT NULL,
    "keywords" character varying(255) DEFAULT ''::character varying NOT NULL,
    "category" integer DEFAULT 0 NOT NULL,
    "posted" smallint DEFAULT 0 NOT NULL,
    "fixed" smallint DEFAULT 0 NOT NULL,
    "static" smallint DEFAULT 0 NOT NULL
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "site"."posts_id_seq"
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "site"."posts_id_seq" OWNED BY "site"."posts"."id";


--
-- Name: posts_tags; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."posts_tags" (
    "post_id" bigint DEFAULT 0 NOT NULL,
    "tag_id" bigint DEFAULT 0 NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."tags" (
    "id" bigint NOT NULL,
    "name" character varying(255) DEFAULT ''::character varying NOT NULL,
    "altname" character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "site"."tags_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "site"."tags_id_seq" OWNED BY "site"."tags"."id";


--
-- Name: user_groups; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."user_groups" (
    "id" integer NOT NULL,
    "name" character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: user_groups_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "site"."user_groups_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "site"."user_groups_id_seq" OWNED BY "site"."user_groups"."id";


--
-- Name: user_ip_history; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."user_ip_history" (
    "user_id" bigint DEFAULT 0 NOT NULL,
    "ip" character varying(16) DEFAULT '0.0.0.0'::character varying NOT NULL,
    "ts" timestamp without time zone DEFAULT "now"() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."users" (
    "id" bigint NOT NULL,
    "login" character varying(32) DEFAULT ''::character varying NOT NULL,
    "password" character varying(32) DEFAULT ''::character varying NOT NULL,
    "email" character varying(255) DEFAULT ''::character varying NOT NULL,
    "last_ip" character varying(16) DEFAULT '0.0.0.0'::character varying NOT NULL,
    "token" character varying(32) DEFAULT ''::character varying NOT NULL,
    "group_id" integer DEFAULT 0 NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "site"."users_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "site"."users_id_seq" OWNED BY "site"."users"."id";


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."admin_menu_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."categories" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."categories_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."posts_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."tags" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."tags_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."user_groups" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."user_groups_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."users_id_seq"'::"regclass");


--
-- Data for Name: admin_menu; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (0, 0, '0', 0, '--', '--', 1, 0, '', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (1, 0, '0', 0, 'Система', '', 1, 2, 'system', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (3, 1, '0-1', 1, 'Реклама', '', 1, 4, 'ads', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (12, 0, '0', 0, 'Головна', '', 1, 1, 'main', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (6, 0, '0', 0, 'Публікації', '', 1, 3, 'posts', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (2, 1, '0-1', 1, 'Налаштування', '', 1, 1, 'config', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (4, 1, '0-1', 1, 'Керування БД', '', 1, 2, 'database', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (7, 6, '0-6', 1, 'Додати', '', 1, 1, 'add', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (10, 6, '0-6', 1, 'Додаткові поля', '', 1, 3, 'fields', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (9, 6, '0-6', 1, 'Категорії', '', 1, 4, 'categ', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (14, 1, '0-1', 1, 'Адмінпанель', '', 1, 5, 'admin', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (15, 0, '0', 0, 'Контент', '', 1, 4, 'content', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (5, 15, '0-15', 1, 'Теги', '', 1, 3, 'tags', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (11, 15, '0-15', 1, 'Голосування', '', 1, 5, 'votes', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (16, 0, '0', 0, 'Користувачі', '', 1, 5, 'users', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (17, 16, '0-16', 1, 'Групи', '', 1, 3, 'groups', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (18, 16, '0-16', 1, 'Додаткові поля', '', 1, 4, 'fields', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (19, 16, '0-16', 1, 'Налаштування', '', 1, 2, 'config', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (8, 6, '0-6', 1, 'Редагувати', '', 0, 2, 'edit', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (20, 6, '0-6', 1, 'Список', '', 1, 2, 'list', 0);
INSERT INTO "site"."admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (13, 12, '0-12', 1, 'Статистика', '', 1, 1, 'stats', 1);


--
-- Data for Name: admin_menu_accesses; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (1, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (5, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (3, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (13, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (12, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (6, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (2, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (4, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (7, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (8, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (10, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (9, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (11, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (14, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (15, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (16, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (18, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (17, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (19, 1);
INSERT INTO "site"."admin_menu_accesses" ("item_id", "group_id") VALUES (20, 1);


--
-- Name: admin_menu_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."admin_menu_id_seq"', 20, true);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (0, '--', '--', 0, '', 0, 0);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (1, 'blog', 'Блог розробників', 0, '0', 0, 0);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (2, 'release', 'Релізи', 0, '0', 0, 0);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (3, 'addon', 'Доповнення', 0, '0', 0, 0);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (4, 'hack', 'Дрібні хаки', 3, '0-3', 0, 1);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (5, 'tpl', 'Зовнішній вигляд', 3, '0-3', 0, 1);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (6, 'newfunc', 'Нові функції', 3, '0-3', 0, 1);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."categories_id_seq"', 6, true);


--
-- Data for Name: files; Type: TABLE DATA; Schema: site; Owner: -
--



--
-- Data for Name: images; Type: TABLE DATA; Schema: site; Owner: -
--



--
-- Data for Name: posts; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (0, '', '', '', '', '', 0, '2016-11-08 23:22:58', '', '', 0, 0, 0, 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (3, 'Навіщо ще одна CMS?', 'navishho_shhe_odna_sistema_keruvannya_kontentom', '', 'Це питання особисто мені задають всі хто вперше дізнається про розробку чогось нового. Особливо якщо людина знайома з поняттям CMS. Але все не так просто, як здається на перший погляд...', '<p class=\"bb_p\">За основу можна взяти будь-що, але видивитись переваги й недоліки можна тільки після детального аналізу роботи. Якщо глянути список доступних для використання CMS, то бере сумнів в тому, що ніхто раніше не реалізовував щось подібне. Але... Є нюанси!</p>&#10;<h2 class=\"bb_h2\">Content-Security-Policy</h2>&#10;<p class=\"bb_p\">CSP рекомендується консорціумом W3C. CSP намагаються використовувати web-гіганти, але натикаються на проблеми, що витікають з принципу базової розробки. А в сфері систем керування контентом ситуація значно гірша. Встановіть CSP на найвищий рівень:</p>&#10;<code class="bb_code">Content-Security-Policy&colon; default-src &apos;self&apos;&semi;</code>&#10;<p class=\"bb_p\">і ви не знайдете CMS, яка б адекватно працювала. Про роботу в режимі "production" мова не заводиться взагалі.</p>&#10;<h2 class=\"bb_h2\">PostgreSQL</h2>&#10;<p class=\"bb_p\">Більшість розробників CMS, з метою підтримки якомога більшої кількості СУБД, користуються лише тими функціональними можливостями, які притаманні всім СУБД. Інші ж реалізовують лише підтримку MySQL.</p>&#10;<p class=\"bb_p\">Мати в розпорядженні СУБД, але користуватись тільки можливостями занесення/зчитування даних - безглуздо.</p>&#10;<p class=\"bb_p\">Ми реалізовуємо лише підтримку PostgreSQL з використанням більшості доступних особливостей цієї ОСУБД.</p>&#10;&#10;<h2 class=\"bb_h2\">php 7</h2>&#10;<p class=\"bb_p\">Зрозуміло, що використання php останньої версії не новинка в сфері написання коду, але як і з CSP важливими є налаштування. Переведемо PHP  в режим коли розробнику не сходять з рук дрібні помилки:</p>&#10;<code class="bb_code">error&lowbar;reporting &lpar; E&lowbar;ALL &rpar;&semi;</code>&#10;<p class=\"bb_p\">і ситуація буде такою ж як і з CSP - знайти CMS, яка працюватиме, буде вкрай складно, а в "production" тільки після власноручного допилювання.</p>&#10;<h2 class=\"bb_h2\">Шаблони</h2>&#10;<p class=\"bb_p\">Хто користувався різними CMS мабуть неодноразово помічав, що іноді розробники спрощують метод виведення інформації в шаблон, розміщуючи в останньому елементи PHP. В такому випадку, розробка шаблону для власного сайту є задачею не по зубах для людини, яка не володіє необхідною мовою програмування.</p>&#10;<p class=\"bb_p\">Ми використовуємо чисті HTML шаблони, інформація в які вноситься за кодовими мітками. Це не новинка, але це важливо.</p>&#10;<h2 class=\"bb_h2\">Використання серверної пам''яті</h2>&#10;<p class=\"bb_p\">Наш результат - до 1Mb при завантаженні будь-якої сторінки сайту.</p>', 1, '2017-02-12 23:54:53.664647', '''cms'':4C,5 ''навіщ'':1C,6 ''одн'':3C,7 ''ще'':2C,8', '', 1, 1, 0, 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (1, 'Нова розробка - нова історія', 'nova_rozrobka_cms_z_visokim_rivnem_zahistu', '', 'Це перша публікація в даній CMS. В ній я розповім про нову структуру, можливості та особливості сайту. Також постараюсь трішки торкнутись історії та розповім про причини створення даного ресурсу.', '<p class=\"bb_p\">Розпочнемо мабуть з початку, а саме з причин створення як ресурсу в цілому так і його серверної частини. Доречі в рамках історичного екскурсу можуть зачіпатись теми, які багатьом припікають сраки, тому хто вже відчуває нестабільність температурного режиму - далі не читайте :)</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.1.0 - <span class=\"bb_span\" title="Всім похуй">Nemo curat</span></h2>&#10;<p class=\"bb_p\">Історія ресурсу cmska.org розпочалась в далекому 2007 році з реєстрації доменного імені "cmska.org.ua". Спочатку це був аматорський сайт двох студентів, яким було просто цікаво дізнатись як працюють сайти. Наступним кроком була спеціалізація контенту - в якості каркасу для сайту було обрано CMS DLE (тоді ще не загиджений), а сам сайт цілком перетворено на сайт підтримки даної CMS.</p>&#10;<p class=\"bb_p\">Так тривало довго. Змінювався склад аматорів, змінювався зовнішній вигляд сайту, незмінною були лише домен та тематика. І тривало так до моменту виходу в світ першої розробки від одного з авторів "cmska.org.ua".</p>&#10;<p class=\"bb_p\">Перша розробка дала рушійну силу (WMZ) і розуміння того, що web-сфера не заповнена в необхідній мірі, а виходячи з того, що знайовся покупець на відверту аматорську роботу - web-сфера вимагала продовження.</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.2.0 - <span class=\"bb_span\" title="Довіряй, але дивись кому">Fide, sed cui fidas, vide</span></h2>&#10;<p class=\"bb_p\">В 2009 році було придбано домен "cmska.org". На цей період авторський склад час від часу випускав модулі для CMS DLE та приймав активну участь у тодішньому main-stream - створення автоматизованої системи для швидкого і якісного генерування сайтів. Останнє заняття давало значну фінансову підтримку - вміння генерувати "унікальний" контент + володіння навичками SEO завжди давали гарний прибуток.</p>&#10;<p class=\"bb_p\">На початку 10-х серед авторського складу проекту cmska стався перший розкол - всі чотири учасники вирішили розпочати власний шлях... і жоден не хотів продовжувати попередню тематику. Причина проста - зі збільшенням популярності проекту, збільшувались і випадки витоку платного контенту, в результаті чого місяці розробки втрачали можливість бути оплачуваними. Тематика CMS DLE втратила актуальність як неоплачувана.</p>&#10;<p class=\"bb_p\">Весь проект, всі вихідні коди залишились в одного з співавторів - в мене. Я завжди притримувався ідей публічності та допомоги починаючим web-розробникам, а тому через деякий час після припинення діяльності було прийняте рішення "відродити" проект - продовжити створення унікального функціоналу та контенту. Але все ж слід приймати до уваги, що тематика "неофіційної підтримки" комерційного програмного засобу - ідея абсурдна. Тому...</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.3.0 - <span class=\"bb_span\" title="Все змінюється, ніщо не зникає безслідно">Omnia mutantur, nihil interit</span></h2>&#10;<p class=\"bb_p\">З середини 2015 року було розпочато розробку нової CMS - некомерційного продукту з відкритим вихідним кодом, який би враховував не примхи й забаганки "project manager", а рекомендації щодо безпеки та продуктивності.</p>&#10;&#10;', 1, '2017-02-12 16:38:41.175227', '''10'':15 ''2007'':17 ''2009'':18 ''2015'':19 ''cms'':21,22 ''cmska'':29 ''cmska.org'':5,20,30,67,208 ''cmska.org.ua'':6,7 ''cui'':31 ''curat'':32 ''dle'':24 ''fida'':34 ''fide'':25 ''interit'':35 ''main'':38 ''main-stream'':37 ''manag'':40 ''mutantur'':41 ''nemo'':26 ''nihil'':42 ''omnia'':27 ''project'':9 ''sed'':43 ''seo'':28 ''stream'':39 ''v.1.0'':44 ''v.2.0'':45 ''v.3.0'':46 ''vide'':47 ''web'':50,53 ''web-розробник'':49 ''web-сфер'':52 ''wmz'':13 ''абсурдн'':70 ''автоматизованої'':71 ''авторськ'':72,73 ''авторів'':74 ''активн'':75 ''актуальніст'':76 ''ал'':56 ''аматорськ'':77,78 ''аматорів'':79 ''багат'':80 ''безпек'':81 ''би'':82 ''був'':83 ''бул'':84,85,86 ''бут'':87 ''ве'':177 ''вже'':89 ''вигляд'':90 ''вимага'':91 ''випадк'':92 ''випуска'':93 ''виріш'':94 ''виток'':95 ''виход'':96 ''виходяч'':97 ''вихідн'':98 ''вихідні'':99 ''власн'':100 ''вміння'':101 ''володін'':102 ''враховува'':103 ''всі'':105 ''втрат'':106 ''втрача'':107 ''від'':108 ''відверт'':109 ''відкрит'':110 ''відродит'':10 ''відчуває'':111 ''гарн'':112 ''генеруван'':113 ''генеруват'':114 ''дава'':115,116 ''дал'':117 ''далек'':118 ''далі'':119 ''даної'':120 ''двох'':121 ''деяк'':122 ''довг'':125 ''дом'':126 ''домен'':127 ''допомог'':128 ''доречі'':57 ''дізнат'':129 ''діяльності'':130 ''екскурс'':131 ''жод'':133 ''з'':36,134 ''забаганк'':135 ''завжд'':136 ''загиджен'':137 ''залиш'':138 ''занятт'':139 ''заповн'':140 ''засоб'':141 ''зачіпат'':142 ''збільшен'':143 ''збільшува'':144 ''змінював'':58,145 ''знай'':146 ''значн'':147 ''зовнішні'':148 ''зі'':149 ''й'':150 ''йог'':151 ''каркас'':152 ''код'':153,154 ''комерційн'':155 ''контент'':156,157,158,159 ''крок'':160 ''лиш'':161 ''мабут'':162 ''мен'':163 ''модулі'':164 ''можливіст'':165 ''можут'':166 ''момент'':167 ''мірі'':168 ''місяці'':169 ''навичк'':171 ''наступн'':60 ''незмін'':173 ''некомерційн'':174 ''необхідні'':175 ''неоплачува'':176 ''неофіційної'':11 ''нестабільніст'':178 ''нов'':1C,3C ''нової'':179 ''обра'':180 ''одн'':181 ''оплачуван'':182 ''останнє'':61 ''перетвор'':183 ''перш'':8,184 ''першої'':185 ''період'':186 ''платн'':187 ''покупец'':188 ''попередн'':189 ''популярності'':190 ''початк'':191,192 ''починаюч'':193 ''працюют'':194 ''прибуток'':195 ''придба'':197 ''прийма'':198 ''приймат'':199 ''прийнят'':200 ''примх'':201 ''припинен'':202 ''припікают'':203 ''притримував'':204 ''причин'':62,205 ''програмн'':206 ''продовжен'':207 ''продовжит'':209 ''продовжуват'':210 ''продукт'':212 ''продуктивності'':211 ''проект'':213,214,215,216 ''прост'':217,218 ''публічності'':219 ''підтримк'':220,221,222 ''після'':223 ''рамк'':224 ''режим'':225 ''результаті'':226 ''рекомендації'':227 ''ресурс'':228 ''реєстрації'':229 ''робот'':230 ''розкол'':231 ''розпоча'':232 ''розпочат'':233,234 ''розпочнем'':63 ''розробк'':2C,235,236,237 ''розробник'':51 ''розумін'':238 ''рок'':239 ''році'':240 ''рушійн'':241 ''рішен'':242 ''сайт'':243,244,245,246 ''сайтів'':247 ''сам'':249 ''світ'':250 ''серверної'':251 ''серед'':252 ''середин'':253 ''сил'':254 ''систем'':255 ''склад'':256,257 ''слід'':258 ''спеціалізаці'':259 ''спочатк'':64 ''співавторів'':260 ''срак'':261 ''став'':262 ''створен'':263 ''студентів'':264 ''сфер'':54 ''та'':265 ''тем'':270 ''тематик'':65,267,268,269 ''температурн'':271 ''тоді'':14 ''тодішн'':273 ''том'':66,274 ''трива'':275 ''уваг'':277 ''унікальн'':12,278 ''учасник'':279 ''участ'':280 ''функціонал'':281 ''фінансов'':282 ''х'':16 ''хотів'':283 ''хто'':284 ''це'':285,286 ''цікав'':287 ''цілком'':288 ''цілом'':289 ''час'':290,292 ''частин'':291 ''чита'':294 ''чог'':295 ''чотир'':296 ''швидк'':297 ''шлях'':298 ''ще'':299 ''що'':300 ''щод'':301 ''як'':302,303,304 ''якості'':305 ''які'':306 ''якісн'':307 ''і'':55,308 ''іде'':309,310 ''імені'':311 ''історичн'':312 ''історі'':4C,33', '', 1, 1, 0, 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (2, 'define', 'define', '', 'В даній публікації я познайомлю Вас з деякими парадигмами, константами CMS яку ми пишемо.', '<code class="bb_code">define&lpar; &apos;open&lowbar;source&apos;&comma; true &rpar;&semi;</code>&#10;<p class=\"bb_p\">Дана CMS є розробкою з відкритим вихідним кодом, тобто кожен бажаючий може використовувати її в власних цілях. Група розробників сайту "cmska.org" залишає за собою право розробки та супроводу даного програмного продукту.</p>&#10;<br>&#10;<code class="bb_code">define&lpar; &apos;language&apos;&comma; &apos;&Ucy;&kcy;&rcy;&acy;&yicy;&ncy;&scy;&softcy;&kcy;&acy;&apos; &rpar;&semi;</code>&#10;<p class=\"bb_p\">Розробники "cmska.org" є громадянами України, а тому на даному ресурсі та в розробці використовується лише Українська мова.</p>&#10;<br>&#10;<code class="bb_code">define&lpar; &apos;security&lowbar;level&apos;&comma; &apos;&Ncy;&acy;&jcy;&vcy;&icy;&shchcy;&icy;&jcy;&apos; &rpar;&semi;</code>&#10;<p class=\"bb_p\">В своїй діяльності розробники керуються принципом максимальної захищеності як користувачів так і сайту. З метою здійснення цього принципу розробники зобов''язуються в межах своєї компетенції використовувати всі методи підвищення рівня захисту.</p>', 1, '2017-02-12 22:03:08.457754', '''cms'':11 ''cmska.org'':2 ''defin'':1C,12,50,58 ''languag'':3 ''level'':7 ''open'':4 ''secur'':6 ''sourc'':5 ''true'':13 ''бажаюч'':19 ''використовуват'':21 ''використовуєт'':22 ''вихідн'':23 ''власн'':24 ''всі'':25 ''відкрит'':26 ''громадян'':27 ''груп'':14 ''дан'':9,28,29 ''діяльності'':30 ''з'':15,31 ''залишає'':33 ''захист'':34 ''захищеності'':35 ''здійснен'':36 ''зоб'':37 ''керуют'':39 ''код'':40 ''кож'':41 ''компетенції'':42 ''користувачів'':43 ''лиш'':44 ''максимальної'':45 ''меж'':46 ''мет'':48 ''метод'':47 ''мов'':49 ''мож'':51 ''прав'':53 ''принцип'':54,55 ''програмн'':56 ''продукт'':57 ''підвищен'':59 ''ресурсі'':60 ''розробк'':61,62 ''розробник'':10,63 ''розробників'':64 ''розробці'':65 ''рівня'':66 ''сайт'':67,68 ''своєї'':69 ''свої'':70 ''соб'':71 ''супровод'':72 ''та'':73 ''тобт'':75 ''том'':76 ''україн'':16 ''українськ'':17 ''цьог'':77 ''цілях'':78 ''язуют'':38 ''як'':79 ''є'':80 ''і'':81 ''її'':82', '', 1, 1, 0, 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (4, 'Оновлена версія після тривалої паузи', 'onovlena_versiya_pislya_trivalo_pauzi', '', 'На сьогоднішній день ми стикнулись з проблемою, що притаманна мабуть переважній більшості не комерційних авторських розробок - вихід оновлень.', '<p class=\"bb_p\">На сьогоднішній день ми стикнулись з проблемою, що притаманна мабуть переважній більшості не комерційних авторських розробок - вихід оновлень.</p>&#10;<p class=\"bb_p\">Станом на час написання даної публікації, розробкою займаюсь я самотужки. І як можна побачити з хронології публікацій - цей рік видався не дуже продуктивним.</p>&#10;<p class=\"bb_p\">Тим не менш, прогрес є! За минулий рік було реалізовано велику кількість базових класів після чого проведена їх ретельна оптимізація. Це досить важливо, оскільки частина класів отримує вхідні дані й вимагає їх ретельної фільтрації, до іншої ж частини висуваються досить жорстокі вимоги до швидкості відпрацювання.</p>&#10;<p class=\"bb_p\">Також "допиляна" частина адміністративної панелі і тепер зручніше створювати публікації. Але тут з''явилась проблема - мені перестав подобатись зовнішній вигляд адміністративної панелі, а саме меню навігації.</p>', 1, '2018-03-04 22:28:45.333495', '''авторськ'':13 ''адміністративної'':14 ''ал'':8 ''базов'':15 ''бул'':16 ''більшості'':17 ''важлив'':18 ''велик'':19 ''версі'':2C ''вигляд'':20 ''видав'':21 ''вимагає'':22 ''вимог'':23 ''висувают'':24 ''вихід'':25 ''вхідні'':26 ''відпрацюван'':27 ''даної'':29 ''дані'':30 ''ден'':31 ''допиля'':6 ''дос'':33 ''дуж'':34 ''жорстокі'':36 ''з'':37,38 ''займа'':40 ''зовнішні'':41 ''зручніш'':42 ''й'':43 ''класів'':44 ''комерційн'':45 ''кількість'':46 ''мабут'':47 ''мен'':49 ''менш'':48 ''мені'':50 ''ми'':51 ''минул'':52 ''можн'':53 ''навігації'':55 ''написан'':56 ''оновл'':1C ''оновлен'':58 ''оптимізаці'':60 ''оскільк'':61 ''отримує'':62 ''панелі'':63,64 ''пауз'':5C ''переважні'':65 ''переста'':66 ''побачит'':67 ''подобат'':68 ''притаман'':69 ''проблем'':70,71 ''провед'':72 ''прогрес'':73 ''продуктивн'':74 ''публікаці'':76 ''публікації'':77,78 ''після'':3C,79 ''реалізова'':80 ''ретельн'':81 ''ретельної'':82 ''розробк'':83 ''розробок'':84 ''рік'':85 ''сам'':86 ''самотужк'':87 ''стан'':59 ''створюват'':88 ''стикнул'':89 ''сьогоднішні'':90 ''також'':28 ''тепер'':91 ''тим'':75 ''тривалої'':4C ''фільтрації'':93 ''хронології'':94 ''це'':11,95 ''час'':96 ''частин'':97,98 ''чог'':99 ''швидкості'':100 ''що'':101 ''яв'':39 ''як'':103 ''є'':104 ''і'':7,105 ''іншої'':106 ''їх'':107', '', 1, 1, 0, 0);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."posts_id_seq"', 4, true);


--
-- Data for Name: posts_tags; Type: TABLE DATA; Schema: site; Owner: -
--



--
-- Data for Name: tags; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."tags" ("id", "name", "altname") VALUES (1, 'Тест', 'test');
INSERT INTO "site"."tags" ("id", "name", "altname") VALUES (2, 'Сайт', 'site');


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."tags_id_seq"', 2, true);


--
-- Data for Name: user_groups; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."user_groups" ("id", "name") VALUES (0, '--');
INSERT INTO "site"."user_groups" ("id", "name") VALUES (1, 'Администратор');


--
-- Name: user_groups_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."user_groups_id_seq"', 1, true);


--
-- Data for Name: user_ip_history; Type: TABLE DATA; Schema: site; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."users" ("id", "login", "password", "email", "last_ip", "token", "group_id") VALUES (0, '--', '--', 'root@cmska.org', '0.0.0.0', '0', 0);
INSERT INTO "site"."users" ("id", "login", "password", "email", "last_ip", "token", "group_id") VALUES (1, 'admin', '6b5d3fde336ba463eb445a2d5bcfc30e', 'admin@cmska.org', '192.168.2.104', '1d39db813f9c5d86255a2007e43ac51f', 1);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."users_id_seq"', 1, true);


--
-- Name: admin_menu_accesses_item_id_group_id_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_item_id_group_id_key" UNIQUE ("item_id", "group_id");


--
-- Name: admin_menu_accesses_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_pkey" PRIMARY KEY ("item_id", "group_id");


--
-- Name: admin_modules_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu"
    ADD CONSTRAINT "admin_modules_pkey" PRIMARY KEY ("id");


--
-- Name: categories_altname_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."categories"
    ADD CONSTRAINT "categories_altname_key" UNIQUE ("altname");


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts"
    ADD CONSTRAINT "posts_pkey" PRIMARY KEY ("id");


--
-- Name: posts_tags_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts_tags"
    ADD CONSTRAINT "posts_tags_pkey" PRIMARY KEY ("post_id", "tag_id");


--
-- Name: posts_tags_post_id_tag_id_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts_tags"
    ADD CONSTRAINT "posts_tags_post_id_tag_id_key" UNIQUE ("post_id", "tag_id");


--
-- Name: tags_altname_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."tags"
    ADD CONSTRAINT "tags_altname_key" UNIQUE ("altname");


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."tags"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");


--
-- Name: user_groups_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."user_groups"
    ADD CONSTRAINT "user_groups_pkey" PRIMARY KEY ("id");


--
-- Name: user_ip_history_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."user_ip_history"
    ADD CONSTRAINT "user_ip_history_pkey" PRIMARY KEY ("user_id");


--
-- Name: users_email_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");


--
-- Name: users_login_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_login_key" UNIQUE ("login");


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: users_token_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_token_key" UNIQUE ("token");


--
-- Name: admin_moduled_upd_ptree_after; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "admin_moduled_upd_ptree_after" AFTER INSERT OR DELETE OR UPDATE OF "id", "parent_id", "ptree", "level" ON "site"."admin_menu" FOR EACH ROW EXECUTE PROCEDURE "site"."GEN_PTREE_MULTILIST_AFTER"();


--
-- Name: admin_moduled_upd_ptree_before; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "admin_moduled_upd_ptree_before" BEFORE INSERT OR UPDATE OF "id", "parent_id", "ptree", "level" ON "site"."admin_menu" FOR EACH ROW EXECUTE PROCEDURE "site"."GEN_PTREE_MULTILIS_BEFORE"();


--
-- Name: before_ins_upd_posts; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "before_ins_upd_posts" BEFORE INSERT OR UPDATE OF "title", "descr", "full_post", "keywords" ON "site"."posts" FOR EACH ROW EXECUTE PROCEDURE "site"."before_ins_upd_posts"();


--
-- Name: categories_after_any; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "categories_after_any" AFTER INSERT OR DELETE OR UPDATE OF "id", "parent_id", "ptree", "level" ON "site"."categories" FOR EACH ROW EXECUTE PROCEDURE "site"."GEN_PTREE_MULTILIST_AFTER"();


--
-- Name: categories_before_ins_upd; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "categories_before_ins_upd" BEFORE INSERT OR UPDATE OF "id", "parent_id", "ptree", "level" ON "site"."categories" FOR EACH ROW EXECUTE PROCEDURE "site"."GEN_PTREE_MULTILIS_BEFORE"();


--
-- Name: admin_menu_accesses_group_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "site"."user_groups"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_menu_accesses_item_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "site"."admin_menu"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_author_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts"
    ADD CONSTRAINT "posts_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "site"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_category_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts"
    ADD CONSTRAINT "posts_category_fkey" FOREIGN KEY ("category") REFERENCES "site"."categories"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_tags_post_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts_tags"
    ADD CONSTRAINT "posts_tags_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "site"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts_tags"
    ADD CONSTRAINT "posts_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "site"."tags"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_ip_history_user_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."user_ip_history"
    ADD CONSTRAINT "user_ip_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "site"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users_group_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "site"."user_groups"("id") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- PostgreSQL database dump complete
--

