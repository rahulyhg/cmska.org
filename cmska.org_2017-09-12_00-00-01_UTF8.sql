--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.9
-- Dumped by pg_dump version 9.5.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
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


SET search_path = "site", pg_catalog;

--
-- Name: GEN_PTREE_MULTILIST_AFTER(); Type: FUNCTION; Schema: site; Owner: -
--

CREATE FUNCTION "GEN_PTREE_MULTILIST_AFTER"() RETURNS "trigger"
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

CREATE FUNCTION "GEN_PTREE_MULTILIS_BEFORE"() RETURNS "trigger"
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

CREATE FUNCTION "before_ins_upd_posts"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$DECLARE
	


BEGIN

	NEW.svector = 
		setweight( coalesce( to_tsvector( lower(NEW.keywords) ),''),'A') || ' ' || 
		setweight( coalesce( to_tsvector( lower(NEW.descr)),''),'B') || ' ' ||
		setweight( coalesce( to_tsvector( lower(NEW.title)),''),'C') || ' ' ||
		setweight( coalesce( to_tsvector( lower(NEW.full_post)),''),'D');

  RETURN NEW;
END;$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin_menu; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "admin_menu" (
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

CREATE TABLE "admin_menu_accesses" (
    "item_id" integer DEFAULT 0 NOT NULL,
    "group_id" integer DEFAULT 0 NOT NULL
);


--
-- Name: admin_menu_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "admin_menu_id_seq"
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "admin_menu_id_seq" OWNED BY "admin_menu"."id";


--
-- Name: categories; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "categories" (
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

CREATE SEQUENCE "categories_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "categories_id_seq" OWNED BY "categories"."id";


--
-- Name: posts; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "posts" (
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
    "category" integer DEFAULT 0 NOT NULL
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "posts_id_seq"
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "posts_id_seq" OWNED BY "posts"."id";


--
-- Name: posts_tags; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "posts_tags" (
    "post_id" bigint DEFAULT 0 NOT NULL,
    "tag_id" bigint DEFAULT 0 NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "tags" (
    "id" bigint NOT NULL,
    "name" character varying(255) DEFAULT ''::character varying NOT NULL,
    "altname" character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "tags_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "tags_id_seq" OWNED BY "tags"."id";


--
-- Name: user_groups; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "user_groups" (
    "id" integer NOT NULL,
    "name" character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: user_groups_id_seq; Type: SEQUENCE; Schema: site; Owner: -
--

CREATE SEQUENCE "user_groups_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "user_groups_id_seq" OWNED BY "user_groups"."id";


--
-- Name: user_ip_history; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "user_ip_history" (
    "user_id" bigint DEFAULT 0 NOT NULL,
    "ip" character varying(16) DEFAULT '0.0.0.0'::character varying NOT NULL,
    "ts" timestamp without time zone DEFAULT "now"() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "users" (
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

CREATE SEQUENCE "users_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: site; Owner: -
--

ALTER SEQUENCE "users_id_seq" OWNED BY "users"."id";


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "admin_menu" ALTER COLUMN "id" SET DEFAULT "nextval"('"admin_menu_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "categories" ALTER COLUMN "id" SET DEFAULT "nextval"('"categories_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "posts" ALTER COLUMN "id" SET DEFAULT "nextval"('"posts_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "tags" ALTER COLUMN "id" SET DEFAULT "nextval"('"tags_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "user_groups" ALTER COLUMN "id" SET DEFAULT "nextval"('"user_groups_id_seq"'::"regclass");


--
-- Name: id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "users" ALTER COLUMN "id" SET DEFAULT "nextval"('"users_id_seq"'::"regclass");


--
-- Data for Name: admin_menu; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (0, 0, '0', 0, '--', '--', 1, 0, '', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (1, 0, '0', 0, 'Система', '', 1, 2, 'system', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (3, 1, '0-1', 1, 'Реклама', '', 1, 4, 'ads', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (12, 0, '0', 0, 'Головна', '', 1, 1, 'main', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (6, 0, '0', 0, 'Публікації', '', 1, 3, 'posts', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (2, 1, '0-1', 1, 'Налаштування', '', 1, 1, 'config', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (4, 1, '0-1', 1, 'Керування БД', '', 1, 2, 'database', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (7, 6, '0-6', 1, 'Додати', '', 1, 1, 'add', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (10, 6, '0-6', 1, 'Додаткові поля', '', 1, 3, 'fields', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (9, 6, '0-6', 1, 'Категорії', '', 1, 4, 'categ', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (14, 1, '0-1', 1, 'Адмінпанель', '', 1, 5, 'admin', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (15, 0, '0', 0, 'Контент', '', 1, 4, 'content', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (5, 15, '0-15', 1, 'Теги', '', 1, 3, 'tags', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (11, 15, '0-15', 1, 'Голосування', '', 1, 5, 'votes', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (16, 0, '0', 0, 'Користувачі', '', 1, 5, 'users', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (17, 16, '0-16', 1, 'Групи', '', 1, 3, 'groups', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (18, 16, '0-16', 1, 'Додаткові поля', '', 1, 4, 'fields', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (19, 16, '0-16', 1, 'Налаштування', '', 1, 2, 'config', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (8, 6, '0-6', 1, 'Редагувати', '', 0, 2, 'edit', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (20, 6, '0-6', 1, 'Список', '', 1, 2, 'list', 0);
INSERT INTO "admin_menu" ("id", "parent_id", "ptree", "level", "name", "descr", "show_at_nav", "position", "altname", "is_default") VALUES (13, 12, '0-12', 1, 'Статистика', '', 1, 1, 'stats', 1);


--
-- Data for Name: admin_menu_accesses; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (1, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (5, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (3, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (13, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (12, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (6, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (2, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (4, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (7, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (8, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (10, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (9, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (11, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (14, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (15, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (16, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (18, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (17, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (19, 1);
INSERT INTO "admin_menu_accesses" ("item_id", "group_id") VALUES (20, 1);


--
-- Name: admin_menu_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"admin_menu_id_seq"', 20, true);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (0, '--', '--', 0, '', 0, 0);
INSERT INTO "categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (4, 'maincateg', 'Розділ 1', 0, '0', 0, 0);
INSERT INTO "categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (1, 'categ1', 'Категорія 1', 4, '0-4', 0, 1);
INSERT INTO "categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (2, 'categ1_1', 'Категорія 1-1', 1, '0-4-1', 0, 2);
INSERT INTO "categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (3, 'categ1_1_1', 'Категорія 1-1-1', 2, '0-4-1-2', 0, 3);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"categories_id_seq"', 4, true);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (0, '', '', '', '', '', 0, '2016-11-08 23:22:58', '', '', 0);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (2, 'define', 'define', '', 'В даній публікації я познайомлю Вас з деякими парадигмами, константами CMS яку ми пишемо.', '<code class="bb_code">define&lpar; &apos;open&lowbar;source&apos;&comma; true &rpar;&semi;</code>&#10;<p class=\"bb_p\">Дана CMS є розробкою з відкритим вихідним кодом, тобто кожен бажаючий може використовувати її в власних цілях. Група розробників сайту "cmska.org" залишає за собою право розробки та супроводу даного програмного продукту.</p>&#10;<br>&#10;<code class="bb_code">define&lpar; &apos;language&apos;&comma; &apos;&Ucy;&kcy;&rcy;&acy;&yicy;&ncy;&scy;&softcy;&kcy;&acy;&apos; &rpar;&semi;</code>&#10;<p class=\"bb_p\">Розробники "cmska.org" є громадянами України, а тому на даному ресурсі та в розробці використовується лише Українська мова.</p>&#10;<br>&#10;<code class="bb_code">define&lpar; &apos;security&lowbar;level&apos;&comma; &apos;&Ncy;&acy;&jcy;&vcy;&icy;&shchcy;&icy;&jcy;&apos; &rpar;&semi;</code>&#10;<p class=\"bb_p\">В своїй діяльності розробники керуються принципом максимальної захищеності як користувачів так і сайту. З метою здійснення цього принципу розробники зобов''язуються в межах своєї компетенції використовувати всі методи підвищення рівня захисту.</p>', 1, '2017-02-12 22:03:08.457754', '''bb'':8,45,69 ''class'':7,44,68 ''cms'':11 ''cmska.org'':30,48 ''defin'':1C,2,41,64 ''languag'':42 ''level'':66 ''open'':3 ''p'':6,9,43,46,67,70 ''secur'':65 ''sourc'':4 ''true'':5 ''бажаюч'':20 ''використовуват'':22,96 ''використовуєт'':60 ''вихідн'':16 ''власн'':25 ''всі'':97 ''відкрит'':15 ''громадян'':50 ''груп'':27 ''дан'':10,38,55 ''діяльності'':73 ''з'':14,84 ''залишає'':31 ''захист'':101 ''захищеності'':78 ''здійснен'':86 ''зоб'':90 ''керуют'':75 ''код'':17 ''кож'':19 ''компетенції'':95 ''користувачів'':80 ''лиш'':61 ''максимальної'':77 ''меж'':93 ''мет'':85 ''метод'':98 ''мов'':63 ''мож'':21 ''прав'':34 ''принцип'':76,88 ''програмн'':39 ''продукт'':40 ''підвищен'':99 ''ресурсі'':56 ''розробк'':13,35 ''розробник'':47,74,89 ''розробників'':28 ''розробці'':59 ''рівня'':100 ''сайт'':29,83 ''своєї'':94 ''свої'':72 ''соб'':33 ''супровод'':37 ''та'':36,57 ''тобт'':18 ''том'':53 ''україн'':51 ''українськ'':62 ''цьог'':87 ''цілях'':26 ''язуют'':91 ''як'':79 ''є'':12,49 ''і'':82 ''її'':23', '', 1);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (3, 'Навіщо ще одна система керування контентом?', 'navishho_shhe_odna_sistema_keruvannya_kontentom', '', 'Це питання особисто мені задають всі хто вперше дізнається про розробку чогось нового. Особливо якщо людина знайома з поняттям CMS.', '<p class=\"bb_p\">За основу можна взяти будь-що, але видивитись переваги й недоліки можна тільки після детального аналізу роботи. Якщо глянути список доступних для використання CMS, то бере сумнів в тому, що ніхто раніше не реалізовував щось подібне. Але... Є нюанси!</p>&#10;<h2 class=\"bb_h2\">Content-Security-Policy</h2>&#10;<p class=\"bb_p\">CSP рекомендується консорціумом W3C. CSP намагаються використовувати web-гіганти, але натикаються на проблеми, що витікають з принципу базової розробки. А в сфері систем керування контентом ситуація значно гірша. Встановіть CSP на найвищий рівень:</p>&#10;<code class="bb_code">Content-Security-Policy&colon; default-src &apos;self&apos;&semi;</code>&#10;<p class=\"bb_p\">і ви не знайдете CMS, яка б адекватно працювала. Про роботу в режимі "production" мова не заводиться взагалі.</p>&#10;<h2 class=\"bb_h2\">PostgreSQL</h2>&#10;<p class=\"bb_p\">Більшість розробників CMS, з метою підтримки якомога більшої кількості СУБД, користуються лише тими функціональними можливостями, які притаманні всім СУБД. Інші ж реалізовують лише підтримку MySQL.</p>&#10;<p class=\"bb_p\">Мати в розпорядженні СУБД, але користуватись тільки можливостями занесення/зчитування даних - безглуздо.</p>&#10;<p class=\"bb_p\">Ми реалізовуємо лише підтримку PostgreSQL з використанням більшості доступних особливостей цієї ОСУБД.</p>&#10;&#10;<h2 class=\"bb_h2\">php 7</h2>&#10;<p class=\"bb_p\">Зрозуміло, що використання php останньої версії не новинка в сфері написання коду, але як і з CSP важливими є налаштування. Переведемо PHP  в режим коли розробнику не сходять з рук дрібні помилки:</p>&#10;<code class="bb_code">error&lowbar;reporting &lpar; E&lowbar;ALL &rpar;&semi;</code>&#10;<p class=\"bb_p\">і ситуація буде такою ж як і з CSP - знайти CMS яка працюватиме буде вкрай складно, а в "production" тільки після власноручного допилювання.</p>&#10;<h2 class=\"bb_h2\">Шаблони</h2>&#10;<p class=\"bb_p\">Хто користувався різними CMS мабуть неодноразово помічав, що іноді розробники спрощують метод виведення інформації в шаблон, розміщуючи в останньому елементи PHP. В такому випадку, розробка шаблону для власного сайту є задачею не по зубах для людини, яка не володіє необхідною мовою програмування.</p>&#10;<p class=\"bb_p\">Ми використовуємо чисті HTML шаблони, інформація в які вноситься за кодовими мітками. Це не новинка, але це важливо.</p>&#10;<h2 class=\"bb_h2\">Використання серверної пам''яті</h2>&#10;<p class=\"bb_p\">Наш результат - до 1Mb при завантаженні будь-якої сторінки сайту.</p>', 1, '2017-02-12 23:54:53.664647', '''1mb'':354 ''7'':198 ''bb'':9,53,61,107,129,134,163,179,195,201,241,268,273,319,341,349 ''class'':8,52,60,106,128,133,162,178,194,200,240,267,272,318,340,348 ''cms'':35,113,138,253,278 ''content'':56,98 ''content-security-polici'':55,97 ''csp'':63,67,93,219,251 ''default'':102 ''default-src'':101 ''e'':237 ''error'':235 ''h2'':51,54,127,130,193,196,266,269,339,342 ''html'':324 ''mysql'':160 ''p'':7,10,59,62,105,108,132,135,161,164,177,180,199,202,239,242,271,274,317,320,347,350 ''php'':197,206,224,295 ''polici'':58,100 ''postgresql'':131,185 ''product'':122,261 ''report'':236 ''secur'':57,99 ''self'':104 ''src'':103 ''w3c'':66 ''web'':71 ''web-гігант'':70 ''адекватн'':116 ''ал'':18,48,73,169,215,336 ''аналіз'':27 ''б'':115 ''базової'':81 ''безглузд'':176 ''бер'':37 ''буд'':16,245,256,358 ''будь-щ'':15 ''будь-якої'':357 ''більшості'':188 ''більшої'':143 ''більшість'':136 ''важлив'':220,338 ''версії'':208 ''взагалі'':126 ''взят'':14 ''ви'':110 ''виведен'':287 ''видивит'':19 ''використан'':34,187,205,343 ''використовуват'':69 ''використовуєм'':322 ''випадк'':298 ''витікают'':78 ''вкра'':257 ''власн'':302 ''власноручн'':264 ''внос'':329 ''володіє'':313 ''встановіт'':92 ''всім'':153 ''глянут'':30 ''гігант'':72 ''гірша'':91 ''дан'':175 ''детальн'':26 ''допилюван'':265 ''доступн'':32,189 ''дрібні'':233 ''елемент'':294 ''з'':79,139,186,218,231,250 ''завантаженні'':356 ''завод'':125 ''задач'':305 ''занесен'':173 ''знайдет'':112 ''знайт'':252 ''значн'':90 ''зрозуміл'':203 ''зуб'':308 ''зчитуван'':174 ''й'':21 ''керуван'':5C,87 ''код'':214 ''кодов'':331 ''кол'':227 ''консорціум'':65 ''контент'':6C,88 ''користував'':276 ''користуват'':170 ''користуют'':146 ''кількості'':144 ''лиш'':147,158,183 ''людин'':310 ''мабут'':279 ''мат'':165 ''мет'':140 ''метод'':286 ''ми'':181,321 ''мов'':123,315 ''можлив'':150,172 ''можн'':13,23 ''міткам'':332 ''навіщ'':1C ''найвищ'':95 ''налаштуван'':222 ''намагают'':68 ''написан'':213 ''натикают'':74 ''наш'':351 ''недолік'':22 ''необхідн'':314 ''неодноразов'':280 ''новинк'':210,335 ''нюанс'':50 ''ніхто'':42 ''одн'':3C ''основ'':12 ''особлив'':190 ''останн'':293 ''останньої'':207 ''осубд'':192 ''пам'':345 ''переваг'':20 ''переведем'':223 ''подібн'':47 ''помилк'':234 ''поміча'':281 ''працюва'':117 ''працюватим'':255 ''принцип'':80 ''притаманні'':152 ''проблем'':76 ''програмуван'':316 ''підтримк'':141,159,184 ''після'':25,263 ''раніш'':43 ''реалізовува'':45 ''реалізовуют'':157 ''реалізовуєм'':182 ''реж'':226 ''режимі'':121 ''результат'':352 ''рекомендуєт'':64 ''робот'':28,119 ''розміщуюч'':291 ''розпорядженні'':167 ''розробк'':82,299 ''розробник'':228,284 ''розробників'':137 ''рук'':232 ''рівен'':96 ''різним'':277 ''сайт'':303,361 ''серверної'':344 ''сист'':86 ''систем'':4C ''ситуаці'':89,244 ''складн'':258 ''список'':31 ''спрощуют'':285 ''сторінк'':360 ''субд'':145,154,168 ''сумнів'':38 ''сфері'':85,212 ''сходя'':230 ''так'':246,297 ''тим'':148 ''том'':40 ''тільки'':24,171,262 ''функціональн'':149 ''хто'':275 ''це'':333,337 ''цієї'':191 ''чисті'':323 ''шаблон'':270,290,300,325 ''ще'':2C ''що'':17,41,46,77,204,282 ''як'':114,216,248,254,311 ''якомог'':142 ''якої'':359 ''якщ'':29 ''які'':151,328 ''яті'':346 ''є'':49,221,304 ''і'':109,217,243,249 ''іноді'':283 ''інформаці'':326 ''інформації'':288 ''інші'':155', '', 1);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (1, 'Нова розробка - нова історія', 'nova_rozrobka_cms_z_visokim_rivnem_zahistu', '', 'Це перша публікація в даній CMS. В ній я розповім про нову структуру, можливості та особливості сайту. Також постараюсь трішки торкнутись історії та розповім про причини створення даного ресурсу.', '<p class=\"bb_p\">Розпочнемо мабуть з початку, а саме з причин створення як ресурсу в цілому так і його серверної частини. Доречі в рамках історичного екскурсу можуть зачіпатись теми, які багатьом припікають сраки, тому хто вже відчуває нестабільність температурного режиму - далі не читайте :)</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.1.0 - <span class=\"bb_span\" title="Всім похуй">Nemo curat</span></h2>&#10;<p class=\"bb_p\">Історія ресурсу cmska.org розпочалась в далекому 2007 році з реєстрації доменного імені "cmska.org.ua". Спочатку це був аматорський сайт двох студентів, яким було просто цікаво дізнатись як працюють сайти. Наступним кроком була спеціалізація контенту - в якості каркасу для сайту було обрано CMS DLE (тоді ще не загиджений), а сам сайт цілком перетворено на сайт підтримки даної CMS.</p>&#10;<p class=\"bb_p\">Так тривало довго. Змінювався склад аматорів, змінювався зовнішній вигляд сайту, незмінною були лише домен та тематика. І тривало так до моменту виходу в світ першої розробки від одного з авторів "cmska.org.ua".</p>&#10;<p class=\"bb_p\">Перша розробка дала рушійну силу (WMZ) і розуміння того, що web-сфера не заповнена в необхідній мірі, а виходячи з того, що знайовся покупець на відверту аматорську роботу - web-сфера вимагала продовження.</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.2.0 - <span class=\"bb_span\" title="Довіряй, але дивись кому">Fide, sed cui fidas, vide</span></h2>&#10;<p class=\"bb_p\">В 2009 році було придбано домен "cmska.org". На цей період авторський склад час від часу випускав модулі для CMS DLE та приймав активну участь у тодішньому main-stream - створення автоматизованої системи для швидкого і якісного генерування сайтів. Останнє заняття давало значну фінансову підтримку - вміння генерувати "унікальний" контент + володіння навичками SEO завжди давали гарний прибуток.</p>&#10;<p class=\"bb_p\">На початку 10-х серед авторського складу проекту cmska стався перший розкол - всі чотири учасники вирішили розпочати власний шлях... і жоден не хотів продовжувати попередню тематику. Причина проста - зі збільшенням популярності проекту, збільшувались і випадки витоку платного контенту, в результаті чого місяці розробки втрачали можливість бути оплачуваними. Тематика CMS DLE втратила актуальність як неоплачувана.</p>&#10;<p class=\"bb_p\">Весь проект, всі вихідні коди залишились в одного з співавторів - в мене. Я завжди притримувався ідей публічності та допомоги починаючим web-розробникам, а тому через деякий час після припинення діяльності було прийняте рішення "відродити" проект - продовжити створення унікального функціоналу та контенту. Але все ж слід приймати до уваги, що тематика "неофіційної підтримки" комерційного програмного засобу - ідея абсурдна. Тому...</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.3.0 - <span class=\"bb_span\" title="Все змінюється, ніщо не зникає безслідно">Omnia mutantur, nihil interit</span></h2>&#10;<p class=\"bb_p\">З середини 2015 року було розпочато розробку нової CMS - некомерційного продукту з відкритим вихідним кодом, який би враховував не примхи й забаганки "project manager", а рекомендації щодо безпеки та продуктивності.</p>&#10;&#10;', 1, '2017-02-12 16:38:41.175227', '''10'':282 ''2007'':74 ''2009'':222 ''2015'':424 ''bb'':7,51,57,66,126,161,199,205,219,278,336,399,405,420 ''class'':6,50,56,65,125,160,198,204,218,277,335,398,404,419 ''cms'':108,123,239,328,430 ''cmska'':288 ''cmska.org'':53,70,201,227,401 ''cmska.org.ua'':80,158 ''cui'':214 ''curat'':63 ''dle'':109,240,329 ''fida'':215 ''fide'':212 ''h2'':49,52,197,200,397,400 ''interit'':417 ''main'':248 ''main-stream'':247 ''manag'':445 ''mutantur'':415 ''nemo'':62 ''nihil'':416 ''omnia'':414 ''p'':5,8,64,67,124,127,159,162,217,220,276,279,334,337,418,421 ''project'':444 ''sed'':213 ''seo'':271 ''span'':55,58,203,206,403,406 ''stream'':249 ''titl'':59,207,407 ''v.1.0'':54 ''v.2.0'':202 ''v.3.0'':402 ''vide'':216 ''web'':174,193,359 ''web-розробник'':358 ''web-сфер'':173,192 ''wmz'':168 ''абсурдн'':395 ''автоматизованої'':251 ''авторськ'':231,285 ''авторів'':157 ''активн'':243 ''актуальніст'':331 ''ал'':209,380 ''аматорськ'':84,190 ''аматорів'':133 ''багат'':36 ''безпек'':449 ''безслідн'':413 ''би'':438 ''був'':83 ''бул'':89,98,106,139,224,369,426 ''бут'':325 ''ве'':338 ''вже'':41 ''вигляд'':136 ''вимага'':195 ''випадк'':314 ''випуска'':236 ''виріш'':295 ''виток'':315 ''виход'':149 ''виходяч'':182 ''вихідн'':435 ''вихідні'':341 ''власн'':297 ''вміння'':265 ''володін'':269 ''враховува'':439 ''всі'':292,340 ''всім'':60 ''втрат'':330 ''втрача'':323 ''від'':154,234 ''відверт'':189 ''відкрит'':434 ''відродит'':372 ''відчуває'':42 ''гарн'':274 ''генеруван'':257 ''генеруват'':266 ''дава'':261,273 ''дал'':165 ''далек'':73 ''далі'':46 ''даної'':122 ''двох'':86 ''деяк'':364 ''див'':210 ''довг'':130 ''довіря'':208 ''дом'':141,226 ''домен'':78 ''допомог'':356 ''доречі'':27 ''дізнат'':92 ''діяльності'':368 ''екскурс'':31 ''жод'':300 ''з'':11,15,76,156,183,346,422,433 ''забаганк'':443 ''завжд'':272,351 ''загиджен'':113 ''залиш'':343 ''занятт'':260 ''заповн'':177 ''засоб'':393 ''зачіпат'':33 ''збільшен'':309 ''збільшува'':312 ''змінював'':131,134 ''змінюєт'':409 ''знай'':186 ''значн'':262 ''зникає'':412 ''зовнішні'':135 ''зі'':308 ''й'':442 ''йог'':24 ''каркас'':103 ''код'':342,436 ''ком'':211 ''комерційн'':391 ''контент'':100,268,317,379 ''крок'':97 ''лиш'':140 ''мабут'':10 ''мен'':349 ''модулі'':237 ''можливіст'':324 ''можут'':32 ''момент'':148 ''мірі'':180 ''місяці'':321 ''навичк'':270 ''наступн'':96 ''незмін'':138 ''некомерційн'':431 ''необхідні'':179 ''неоплачува'':333 ''неофіційної'':389 ''нестабільніст'':43 ''нов'':1C,3C ''нової'':429 ''ніщо'':410 ''обра'':107 ''одн'':155,345 ''оплачуван'':326 ''останнє'':259 ''перетвор'':118 ''перш'':163,290 ''першої'':152 ''період'':230 ''платн'':316 ''покупец'':187 ''попередн'':304 ''популярності'':310 ''пох'':61 ''початк'':12,281 ''починаюч'':357 ''працюют'':94 ''прибуток'':275 ''придба'':225 ''прийма'':242 ''приймат'':384 ''прийнят'':370 ''примх'':441 ''припинен'':367 ''припікают'':37 ''притримував'':352 ''причин'':16,306 ''програмн'':392 ''продовжен'':196 ''продовжит'':374 ''продовжуват'':303 ''продукт'':432 ''продуктивності'':451 ''проект'':287,311,339,373 ''прост'':90,307 ''публічності'':354 ''підтримк'':121,264,390 ''після'':366 ''рамк'':29 ''режим'':45 ''результаті'':319 ''рекомендації'':447 ''ресурс'':19,69 ''реєстрації'':77 ''робот'':191 ''розкол'':291 ''розпоча'':71 ''розпочат'':296,427 ''розпочнем'':9 ''розробк'':2C,153,164,322,428 ''розробник'':360 ''розумін'':170 ''рок'':425 ''році'':75,223 ''рушійн'':166 ''рішен'':371 ''сайт'':85,95,105,116,120,137 ''сайтів'':258 ''сам'':14 ''світ'':151 ''серверної'':25 ''серед'':284 ''середин'':423 ''сил'':167 ''систем'':252 ''склад'':132,232,286 ''слід'':383 ''спеціалізаці'':99 ''спочатк'':81 ''співавторів'':347 ''срак'':38 ''став'':289 ''створен'':17,250,375 ''студентів'':87 ''сфер'':175,194 ''та'':142,241,355,378,450 ''тем'':34 ''тематик'':143,305,327,388 ''температурн'':44 ''тоді'':110 ''тодішн'':246 ''том'':39,362,396 ''трива'':129,145 ''уваг'':386 ''унікальн'':267,376 ''учасник'':294 ''участ'':244 ''функціонал'':377 ''фінансов'':263 ''х'':283 ''хотів'':302 ''хто'':40 ''це'':82,229 ''цікав'':91 ''цілком'':117 ''цілом'':21 ''час'':233,235,365 ''частин'':26 ''чита'':48 ''чог'':320 ''чотир'':293 ''швидк'':254 ''шлях'':298 ''ще'':111 ''що'':172,185,387 ''щод'':448 ''як'':18,88,93,332,437 ''якості'':102 ''які'':35 ''якісн'':256 ''і'':23,144,169,255,299,313 ''іде'':353,394 ''імені'':79 ''історичн'':30 ''історі'':4C,68', '', 1);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"posts_id_seq"', 3, true);


--
-- Data for Name: posts_tags; Type: TABLE DATA; Schema: site; Owner: -
--



--
-- Data for Name: tags; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "tags" ("id", "name", "altname") VALUES (1, 'Тест', 'test');
INSERT INTO "tags" ("id", "name", "altname") VALUES (2, 'Сайт', 'site');


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"tags_id_seq"', 2, true);


--
-- Data for Name: user_groups; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "user_groups" ("id", "name") VALUES (0, '--');
INSERT INTO "user_groups" ("id", "name") VALUES (1, 'Администратор');


--
-- Name: user_groups_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"user_groups_id_seq"', 1, true);


--
-- Data for Name: user_ip_history; Type: TABLE DATA; Schema: site; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "users" ("id", "login", "password", "email", "last_ip", "token", "group_id") VALUES (0, '--', '--', 'root@cmska.org', '0.0.0.0', '0', 0);
INSERT INTO "users" ("id", "login", "password", "email", "last_ip", "token", "group_id") VALUES (1, 'admin', '6b5d3fde336ba463eb445a2d5bcfc30e', 'admin@cmska.org', '217.115.103.1', 'c74c16be735c3b089187e19cd193f9be', 1);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"users_id_seq"', 1, true);


--
-- Name: admin_menu_accesses_item_id_group_id_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_item_id_group_id_key" UNIQUE ("item_id", "group_id");


--
-- Name: admin_menu_accesses_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_pkey" PRIMARY KEY ("item_id", "group_id");


--
-- Name: admin_modules_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "admin_menu"
    ADD CONSTRAINT "admin_modules_pkey" PRIMARY KEY ("id");


--
-- Name: categories_altname_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "categories"
    ADD CONSTRAINT "categories_altname_key" UNIQUE ("altname");


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "posts"
    ADD CONSTRAINT "posts_pkey" PRIMARY KEY ("id");


--
-- Name: posts_tags_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "posts_tags"
    ADD CONSTRAINT "posts_tags_pkey" PRIMARY KEY ("post_id", "tag_id");


--
-- Name: posts_tags_post_id_tag_id_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "posts_tags"
    ADD CONSTRAINT "posts_tags_post_id_tag_id_key" UNIQUE ("post_id", "tag_id");


--
-- Name: tags_altname_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "tags"
    ADD CONSTRAINT "tags_altname_key" UNIQUE ("altname");


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "tags"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");


--
-- Name: user_groups_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "user_groups"
    ADD CONSTRAINT "user_groups_pkey" PRIMARY KEY ("id");


--
-- Name: user_ip_history_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "user_ip_history"
    ADD CONSTRAINT "user_ip_history_pkey" PRIMARY KEY ("user_id");


--
-- Name: users_email_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");


--
-- Name: users_login_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "users"
    ADD CONSTRAINT "users_login_key" UNIQUE ("login");


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: users_token_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "users"
    ADD CONSTRAINT "users_token_key" UNIQUE ("token");


--
-- Name: admin_moduled_upd_ptree_after; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "admin_moduled_upd_ptree_after" AFTER INSERT OR DELETE OR UPDATE OF "id", "parent_id", "ptree", "level" ON "admin_menu" FOR EACH ROW EXECUTE PROCEDURE "GEN_PTREE_MULTILIST_AFTER"();


--
-- Name: admin_moduled_upd_ptree_before; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "admin_moduled_upd_ptree_before" BEFORE INSERT OR UPDATE OF "id", "parent_id", "ptree", "level" ON "admin_menu" FOR EACH ROW EXECUTE PROCEDURE "GEN_PTREE_MULTILIS_BEFORE"();


--
-- Name: before_ins_upd_posts; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "before_ins_upd_posts" BEFORE INSERT OR UPDATE OF "title", "descr", "full_post", "svector", "keywords" ON "posts" FOR EACH ROW EXECUTE PROCEDURE "before_ins_upd_posts"();


--
-- Name: categories_after_any; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "categories_after_any" AFTER INSERT OR DELETE OR UPDATE OF "id", "parent_id", "ptree", "level" ON "categories" FOR EACH ROW EXECUTE PROCEDURE "GEN_PTREE_MULTILIST_AFTER"();


--
-- Name: categories_before_ins_upd; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "categories_before_ins_upd" BEFORE INSERT OR UPDATE OF "id", "parent_id", "ptree", "level" ON "categories" FOR EACH ROW EXECUTE PROCEDURE "GEN_PTREE_MULTILIS_BEFORE"();


--
-- Name: admin_menu_accesses_group_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "user_groups"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_menu_accesses_item_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "admin_menu"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_author_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "posts"
    ADD CONSTRAINT "posts_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_category_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "posts"
    ADD CONSTRAINT "posts_category_fkey" FOREIGN KEY ("category") REFERENCES "categories"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_tags_post_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "posts_tags"
    ADD CONSTRAINT "posts_tags_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "posts_tags"
    ADD CONSTRAINT "posts_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_ip_history_user_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "user_ip_history"
    ADD CONSTRAINT "user_ip_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users_group_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "users"
    ADD CONSTRAINT "users_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "user_groups"("id") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- PostgreSQL database dump complete
--

