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
		setweight( coalesce( to_tsvector( 'ukrainian', lower(NEW.keywords) ),''),'A') || ' ' || 
		setweight( coalesce( to_tsvector( 'ukrainian', lower(NEW.descr)),''),'B') || ' ' ||
		setweight( coalesce( to_tsvector( 'ukrainian', lower(NEW.title)),''),'C') || ' ' ||
		setweight( coalesce( to_tsvector( 'ukrainian', lower( STXT )),''),'D');

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
    "category" integer DEFAULT 0 NOT NULL
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
-- Data for Name: posts; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (0, '', '', '', '', '', 0, '2016-11-08 23:22:58', '', '', 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (1, 'Нова розробка - нова історія', 'nova_rozrobka_cms_z_visokim_rivnem_zahistu', '', 'Це перша публікація в даній CMS. В ній я розповім про нову структуру, можливості та особливості сайту. Також постараюсь трішки торкнутись історії та розповім про причини створення даного ресурсу.', '<p class=\"bb_p\">Розпочнемо мабуть з початку, а саме з причин створення як ресурсу в цілому так і його серверної частини. Доречі в рамках історичного екскурсу можуть зачіпатись теми, які багатьом припікають сраки, тому хто вже відчуває нестабільність температурного режиму - далі не читайте :)</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.1.0 - <span class=\"bb_span\" title="Всім похуй">Nemo curat</span></h2>&#10;<p class=\"bb_p\">Історія ресурсу cmska.org розпочалась в далекому 2007 році з реєстрації доменного імені "cmska.org.ua". Спочатку це був аматорський сайт двох студентів, яким було просто цікаво дізнатись як працюють сайти. Наступним кроком була спеціалізація контенту - в якості каркасу для сайту було обрано CMS DLE (тоді ще не загиджений), а сам сайт цілком перетворено на сайт підтримки даної CMS.</p>&#10;<p class=\"bb_p\">Так тривало довго. Змінювався склад аматорів, змінювався зовнішній вигляд сайту, незмінною були лише домен та тематика. І тривало так до моменту виходу в світ першої розробки від одного з авторів "cmska.org.ua".</p>&#10;<p class=\"bb_p\">Перша розробка дала рушійну силу (WMZ) і розуміння того, що web-сфера не заповнена в необхідній мірі, а виходячи з того, що знайовся покупець на відверту аматорську роботу - web-сфера вимагала продовження.</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.2.0 - <span class=\"bb_span\" title="Довіряй, але дивись кому">Fide, sed cui fidas, vide</span></h2>&#10;<p class=\"bb_p\">В 2009 році було придбано домен "cmska.org". На цей період авторський склад час від часу випускав модулі для CMS DLE та приймав активну участь у тодішньому main-stream - створення автоматизованої системи для швидкого і якісного генерування сайтів. Останнє заняття давало значну фінансову підтримку - вміння генерувати "унікальний" контент + володіння навичками SEO завжди давали гарний прибуток.</p>&#10;<p class=\"bb_p\">На початку 10-х серед авторського складу проекту cmska стався перший розкол - всі чотири учасники вирішили розпочати власний шлях... і жоден не хотів продовжувати попередню тематику. Причина проста - зі збільшенням популярності проекту, збільшувались і випадки витоку платного контенту, в результаті чого місяці розробки втрачали можливість бути оплачуваними. Тематика CMS DLE втратила актуальність як неоплачувана.</p>&#10;<p class=\"bb_p\">Весь проект, всі вихідні коди залишились в одного з співавторів - в мене. Я завжди притримувався ідей публічності та допомоги починаючим web-розробникам, а тому через деякий час після припинення діяльності було прийняте рішення "відродити" проект - продовжити створення унікального функціоналу та контенту. Але все ж слід приймати до уваги, що тематика "неофіційної підтримки" комерційного програмного засобу - ідея абсурдна. Тому...</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.3.0 - <span class=\"bb_span\" title="Все змінюється, ніщо не зникає безслідно">Omnia mutantur, nihil interit</span></h2>&#10;<p class=\"bb_p\">З середини 2015 року було розпочато розробку нової CMS - некомерційного продукту з відкритим вихідним кодом, який би враховував не примхи й забаганки "project manager", а рекомендації щодо безпеки та продуктивності.</p>&#10;&#10;', 1, '2017-02-12 16:38:41.175227', '''10'':234 ''2007'':55 ''2009'':178 ''2015'':353 ''cms'':89,104,195,280,359 ''cmska'':240 ''cmska.org'':45,51,170,183,345 ''cmska.org.ua'':61,135 ''cui'':174 ''curat'':48 ''dle'':90,196,281 ''fida'':175 ''fide'':172 ''interit'':350 ''main'':204 ''main-stream'':203 ''manag'':374 ''mutantur'':348 ''nemo'':47 ''nihil'':349 ''omnia'':347 ''project'':373 ''sed'':173 ''seo'':227 ''stream'':205 ''v.1.0'':46 ''v.2.0'':171 ''v.3.0'':346 ''vide'':176 ''web'':147,166,307 ''web-розробник'':306 ''web-сфер'':146,165 ''wmz'':141 ''абсурдн'':343 ''автоматизованої'':207 ''авторськ'':187,237 ''авторів'':134 ''активн'':199 ''актуальніст'':283 ''ал'':328 ''аматорськ'':65,163 ''аматорів'':110 ''багат'':32 ''безпек'':378 ''би'':367 ''був'':64 ''бул'':70,79,87,116,180,317,355 ''бут'':277 ''ве'':286 ''вже'':37 ''вигляд'':113 ''вимага'':168 ''випадк'':266 ''випуска'':192 ''виріш'':247 ''виток'':267 ''виход'':126 ''виходяч'':155 ''вихідн'':364 ''вихідні'':289 ''власн'':249 ''вміння'':221 ''володін'':225 ''враховува'':368 ''всі'':244,288 ''втрат'':282 ''втрача'':275 ''від'':131,190 ''відверт'':162 ''відкрит'':363 ''відродит'':320 ''відчуває'':38 ''гарн'':230 ''генеруван'':213 ''генеруват'':222 ''дава'':217,229 ''дал'':138 ''далек'':54 ''далі'':42 ''даної'':103 ''двох'':67 ''деяк'':312 ''довг'':107 ''дом'':118,182 ''домен'':59 ''допомог'':304 ''доречі'':23 ''дізнат'':73 ''діяльності'':316 ''екскурс'':27 ''жод'':252 ''з'':7,11,57,133,156,294,351,362 ''забаганк'':372 ''завжд'':228,299 ''загиджен'':94 ''залиш'':291 ''занятт'':216 ''заповн'':150 ''засоб'':341 ''зачіпат'':29 ''збільшен'':261 ''збільшува'':264 ''змінював'':108,111 ''знай'':159 ''значн'':218 ''зовнішні'':112 ''зі'':260 ''й'':371 ''йог'':20 ''каркас'':84 ''код'':290,365 ''комерційн'':339 ''контент'':81,224,269,327 ''крок'':78 ''лиш'':117 ''мабут'':6 ''мен'':297 ''модулі'':193 ''можливіст'':276 ''можут'':28 ''момент'':125 ''мірі'':153 ''місяці'':273 ''навичк'':226 ''наступн'':77 ''незмін'':115 ''некомерційн'':360 ''необхідні'':152 ''неоплачува'':285 ''неофіційної'':337 ''нестабільніст'':39 ''нов'':1C,3C ''нової'':358 ''обра'':88 ''одн'':132,293 ''оплачуван'':278 ''останнє'':215 ''перетвор'':99 ''перш'':136,242 ''першої'':129 ''період'':186 ''платн'':268 ''покупец'':160 ''попередн'':256 ''популярності'':262 ''початк'':8,233 ''починаюч'':305 ''працюют'':75 ''прибуток'':231 ''придба'':181 ''прийма'':198 ''приймат'':332 ''прийнят'':318 ''примх'':370 ''припинен'':315 ''припікают'':33 ''притримував'':300 ''причин'':12,258 ''програмн'':340 ''продовжен'':169 ''продовжит'':322 ''продовжуват'':255 ''продукт'':361 ''продуктивності'':380 ''проект'':239,263,287,321 ''прост'':71,259 ''публічності'':302 ''підтримк'':102,220,338 ''після'':314 ''рамк'':25 ''режим'':41 ''результаті'':271 ''рекомендації'':376 ''ресурс'':15,50 ''реєстрації'':58 ''робот'':164 ''розкол'':243 ''розпоча'':52 ''розпочат'':248,356 ''розпочнем'':5 ''розробк'':2C,130,137,274,357 ''розробник'':308 ''розумін'':143 ''рок'':354 ''році'':56,179 ''рушійн'':139 ''рішен'':319 ''сайт'':66,76,86,97,101,114 ''сайтів'':214 ''сам'':10 ''світ'':128 ''серверної'':21 ''серед'':236 ''середин'':352 ''сил'':140 ''систем'':208 ''склад'':109,188,238 ''слід'':331 ''спеціалізаці'':80 ''спочатк'':62 ''співавторів'':295 ''срак'':34 ''став'':241 ''створен'':13,206,323 ''студентів'':68 ''сфер'':148,167 ''та'':119,197,303,326,379 ''тем'':30 ''тематик'':120,257,279,336 ''температурн'':40 ''тоді'':91 ''тодішн'':202 ''том'':35,310,344 ''трива'':106,122 ''уваг'':334 ''унікальн'':223,324 ''учасник'':246 ''участ'':200 ''функціонал'':325 ''фінансов'':219 ''х'':235 ''хотів'':254 ''хто'':36 ''це'':63,185 ''цікав'':72 ''цілком'':98 ''цілом'':17 ''час'':189,191,313 ''частин'':22 ''чита'':44 ''чог'':272 ''чотир'':245 ''швидк'':210 ''шлях'':250 ''ще'':92 ''що'':145,158,335 ''щод'':377 ''як'':14,69,74,284,366 ''якості'':83 ''які'':31 ''якісн'':212 ''і'':19,121,142,211,251,265 ''іде'':301,342 ''імені'':60 ''історичн'':26 ''історі'':4C,49', '', 1);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (3, 'Навіщо ще одна CMS?', 'navishho_shhe_odna_sistema_keruvannya_kontentom', '', 'Це питання особисто мені задають всі хто вперше дізнається про розробку чогось нового. Особливо якщо людина знайома з поняттям CMS. Але все не так просто, як здається на перший погляд...', '<p class=\"bb_p\">За основу можна взяти будь-що, але видивитись переваги й недоліки можна тільки після детального аналізу роботи. Якщо глянути список доступних для використання CMS, то бере сумнів в тому, що ніхто раніше не реалізовував щось подібне. Але... Є нюанси!</p>&#10;<h2 class=\"bb_h2\">Content-Security-Policy</h2>&#10;<p class=\"bb_p\">CSP рекомендується консорціумом W3C. CSP намагаються використовувати web-гіганти, але натикаються на проблеми, що витікають з принципу базової розробки. А в сфері систем керування контентом ситуація значно гірша. Встановіть CSP на найвищий рівень:</p>&#10;<code class="bb_code">Content-Security-Policy&colon; default-src &apos;self&apos;&semi;</code>&#10;<p class=\"bb_p\">і ви не знайдете CMS, яка б адекватно працювала. Про роботу в режимі "production" мова не заводиться взагалі.</p>&#10;<h2 class=\"bb_h2\">PostgreSQL</h2>&#10;<p class=\"bb_p\">Більшість розробників CMS, з метою підтримки якомога більшої кількості СУБД, користуються лише тими функціональними можливостями, які притаманні всім СУБД. Інші ж реалізовують лише підтримку MySQL.</p>&#10;<p class=\"bb_p\">Мати в розпорядженні СУБД, але користуватись тільки можливостями занесення/зчитування даних - безглуздо.</p>&#10;<p class=\"bb_p\">Ми реалізовуємо лише підтримку PostgreSQL з використанням більшості доступних особливостей цієї ОСУБД.</p>&#10;&#10;<h2 class=\"bb_h2\">php 7</h2>&#10;<p class=\"bb_p\">Зрозуміло, що використання php останньої версії не новинка в сфері написання коду, але як і з CSP важливими є налаштування. Переведемо PHP  в режим коли розробнику не сходять з рук дрібні помилки:</p>&#10;<code class="bb_code">error&lowbar;reporting &lpar; E&lowbar;ALL &rpar;&semi;</code>&#10;<p class=\"bb_p\">і ситуація буде такою ж як і з CSP - знайти CMS, яка працюватиме, буде вкрай складно, а в "production" тільки після власноручного допилювання.</p>&#10;<h2 class=\"bb_h2\">Шаблони</h2>&#10;<p class=\"bb_p\">Хто користувався різними CMS мабуть неодноразово помічав, що іноді розробники спрощують метод виведення інформації в шаблон, розміщуючи в останньому елементи PHP. В такому випадку, розробка шаблону для власного сайту є задачею не по зубах для людини, яка не володіє необхідною мовою програмування.</p>&#10;<p class=\"bb_p\">Ми використовуємо чисті HTML шаблони, інформація в які вноситься за кодовими мітками. Це не новинка, але це важливо.</p>&#10;<h2 class=\"bb_h2\">Використання серверної пам''яті</h2>&#10;<p class=\"bb_p\">Наш результат - до 1Mb при завантаженні будь-якої сторінки сайту.</p>', 1, '2017-02-12 23:54:53.664647', '''1mb'':352 ''7'':196 ''bb'':7,51,59,105,127,132,161,177,193,199,239,266,271,317,339,347 ''class'':6,50,58,104,126,131,160,176,192,198,238,265,270,316,338,346 ''cms'':4C,33,111,136,251,276 ''content'':54,96 ''content-security-polici'':53,95 ''csp'':61,65,91,217,249 ''default'':100 ''default-src'':99 ''e'':235 ''error'':233 ''h2'':49,52,125,128,191,194,264,267,337,340 ''html'':322 ''mysql'':158 ''p'':5,8,57,60,103,106,130,133,159,162,175,178,197,200,237,240,269,272,315,318,345,348 ''php'':195,204,222,293 ''polici'':56,98 ''postgresql'':129,183 ''product'':120,259 ''report'':234 ''secur'':55,97 ''self'':102 ''src'':101 ''w3c'':64 ''web'':69 ''web-гігант'':68 ''адекватн'':114 ''ал'':16,46,71,167,213,334 ''аналіз'':25 ''б'':113 ''базової'':79 ''безглузд'':174 ''бер'':35 ''буд'':14,243,254,356 ''будь-щ'':13 ''будь-якої'':355 ''більшості'':186 ''більшої'':141 ''більшість'':134 ''важлив'':218,336 ''версії'':206 ''взагалі'':124 ''взят'':12 ''ви'':108 ''виведен'':285 ''видивит'':17 ''використан'':32,185,203,341 ''використовуват'':67 ''використовуєм'':320 ''випадк'':296 ''витікают'':76 ''вкра'':255 ''власн'':300 ''власноручн'':262 ''внос'':327 ''володіє'':311 ''встановіт'':90 ''всім'':151 ''глянут'':28 ''гігант'':70 ''гірша'':89 ''дан'':173 ''детальн'':24 ''допилюван'':263 ''доступн'':30,187 ''дрібні'':231 ''елемент'':292 ''з'':77,137,184,216,229,248 ''завантаженні'':354 ''завод'':123 ''задач'':303 ''занесен'':171 ''знайдет'':110 ''знайт'':250 ''значн'':88 ''зрозуміл'':201 ''зуб'':306 ''зчитуван'':172 ''й'':19 ''керуван'':85 ''код'':212 ''кодов'':329 ''кол'':225 ''консорціум'':63 ''контент'':86 ''користував'':274 ''користуват'':168 ''користуют'':144 ''кількості'':142 ''лиш'':145,156,181 ''людин'':308 ''мабут'':277 ''мат'':163 ''мет'':138 ''метод'':284 ''ми'':179,319 ''мов'':121,313 ''можлив'':148,170 ''можн'':11,21 ''міткам'':330 ''навіщ'':1C ''найвищ'':93 ''налаштуван'':220 ''намагают'':66 ''написан'':211 ''натикают'':72 ''наш'':349 ''недолік'':20 ''необхідн'':312 ''неодноразов'':278 ''новинк'':208,333 ''нюанс'':48 ''ніхто'':40 ''одн'':3C ''основ'':10 ''особлив'':188 ''останн'':291 ''останньої'':205 ''осубд'':190 ''пам'':343 ''переваг'':18 ''переведем'':221 ''подібн'':45 ''помилк'':232 ''поміча'':279 ''працюва'':115 ''працюватим'':253 ''принцип'':78 ''притаманні'':150 ''проблем'':74 ''програмуван'':314 ''підтримк'':139,157,182 ''після'':23,261 ''раніш'':41 ''реалізовува'':43 ''реалізовуют'':155 ''реалізовуєм'':180 ''реж'':224 ''режимі'':119 ''результат'':350 ''рекомендуєт'':62 ''робот'':26,117 ''розміщуюч'':289 ''розпорядженні'':165 ''розробк'':80,297 ''розробник'':226,282 ''розробників'':135 ''рук'':230 ''рівен'':94 ''різним'':275 ''сайт'':301,359 ''серверної'':342 ''сист'':84 ''ситуаці'':87,242 ''складн'':256 ''список'':29 ''спрощуют'':283 ''сторінк'':358 ''субд'':143,152,166 ''сумнів'':36 ''сфері'':83,210 ''сходя'':228 ''так'':244,295 ''тим'':146 ''том'':38 ''тільки'':22,169,260 ''функціональн'':147 ''хто'':273 ''це'':331,335 ''цієї'':189 ''чисті'':321 ''шаблон'':268,288,298,323 ''ще'':2C ''що'':15,39,44,75,202,280 ''як'':112,214,246,252,309 ''якомог'':140 ''якої'':357 ''якщ'':27 ''які'':149,326 ''яті'':344 ''є'':47,219,302 ''і'':107,215,241,247 ''іноді'':281 ''інформаці'':324 ''інформації'':286 ''інші'':153', '', 1);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (2, 'define', 'define', '', 'В даній публікації я познайомлю Вас з деякими парадигмами, константами CMS яку ми пишемо.', '<code class="bb_code">define&lpar; &apos;open&lowbar;source&apos;&comma; true &rpar;&semi;</code>&#10;<p class=\"bb_p\">Дана CMS є розробкою з відкритим вихідним кодом, тобто кожен бажаючий може використовувати її в власних цілях. Група розробників сайту "cmska.org" залишає за собою право розробки та супроводу даного програмного продукту.</p>&#10;<br>&#10;<code class="bb_code">define&lpar; &apos;language&apos;&comma; &apos;&Ucy;&kcy;&rcy;&acy;&yicy;&ncy;&scy;&softcy;&kcy;&acy;&apos; &rpar;&semi;</code>&#10;<p class=\"bb_p\">Розробники "cmska.org" є громадянами України, а тому на даному ресурсі та в розробці використовується лише Українська мова.</p>&#10;<br>&#10;<code class="bb_code">define&lpar; &apos;security&lowbar;level&apos;&comma; &apos;&Ncy;&acy;&jcy;&vcy;&icy;&shchcy;&icy;&jcy;&apos; &rpar;&semi;</code>&#10;<p class=\"bb_p\">В своїй діяльності розробники керуються принципом максимальної захищеності як користувачів так і сайту. З метою здійснення цього принципу розробники зобов''язуються в межах своєї компетенції використовувати всі методи підвищення рівня захисту.</p>', 1, '2017-02-12 22:03:08.457754', '''cms'':7 ''cmska.org'':26,40 ''defin'':1C,2,37,56 ''languag'':38 ''level'':58 ''open'':3 ''secur'':57 ''sourc'':4 ''true'':5 ''бажаюч'':16 ''використовуват'':18,84 ''використовуєт'':52 ''вихідн'':12 ''власн'':21 ''всі'':85 ''відкрит'':11 ''громадян'':42 ''груп'':23 ''дан'':6,34,47 ''діяльності'':61 ''з'':10,72 ''залишає'':27 ''захист'':89 ''захищеності'':66 ''здійснен'':74 ''зоб'':78 ''керуют'':63 ''код'':13 ''кож'':15 ''компетенції'':83 ''користувачів'':68 ''лиш'':53 ''максимальної'':65 ''меж'':81 ''мет'':73 ''метод'':86 ''мов'':55 ''мож'':17 ''прав'':30 ''принцип'':64,76 ''програмн'':35 ''продукт'':36 ''підвищен'':87 ''ресурсі'':48 ''розробк'':9,31 ''розробник'':39,62,77 ''розробників'':24 ''розробці'':51 ''рівня'':88 ''сайт'':25,71 ''своєї'':82 ''свої'':60 ''соб'':29 ''супровод'':33 ''та'':32,49 ''тобт'':14 ''том'':45 ''україн'':43 ''українськ'':54 ''цьог'':75 ''цілях'':22 ''язуют'':79 ''як'':67 ''є'':8,41 ''і'':70 ''її'':19', '', 1);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (4, 'Оновлена версія після тривалої паузи', 'onovlena_versiya_pislya_trivalo_pauzi', '', 'На сьогоднішній день ми стикнулись з проблемою, що притаманна мабуть переважній більшості не комерційних авторських розробок - вихід оновлень.', '<p class=\"bb_p\">На сьогоднішній день ми стикнулись з проблемою, що притаманна мабуть переважній більшості не комерційних авторських розробок - вихід оновлень.</p>&#10;<p class=\"bb_p\">Станом на час написання даної публікації, розробкою займаюсь я самотужки. І як можна побачити з хронології публікацій - цей рік видався не дуже продуктивним.</p>&#10;<p class=\"bb_p\">Тим не менш, прогрес є! За минулий рік було реалізовано велику кількість базових класів після чого проведена їх ретельна оптимізація. Це досить важливо, оскільки частина класів отримує вхідні дані й вимагає їх ретельної фільтрації, до іншої ж частини висуваються досить жорстокі вимоги до швидкості відпрацювання.</p>&#10;<p class=\"bb_p\">Також "допиляна" частина адміністративної панелі і тепер зручніше створювати публікації. Але тут з''явилась проблема - мені перестав подобатись зовнішній вигляд адміністративної панелі, а саме меню навігації.</p>', 1, '2018-03-04 22:28:45.333495', '''авторськ'':13 ''адміністративної'':14 ''ал'':8 ''базов'':15 ''бул'':16 ''більшості'':17 ''важлив'':18 ''велик'':19 ''версі'':2C ''вигляд'':20 ''видав'':21 ''вимагає'':22 ''вимог'':23 ''висувают'':24 ''вихід'':25 ''вхідні'':26 ''відпрацюван'':27 ''даної'':29 ''дані'':30 ''ден'':31 ''допиля'':6 ''дос'':33 ''дуж'':34 ''жорстокі'':36 ''з'':37,38 ''займа'':40 ''зовнішні'':41 ''зручніш'':42 ''й'':43 ''класів'':44 ''комерційн'':45 ''кількість'':46 ''мабут'':47 ''мен'':49 ''менш'':48 ''мені'':50 ''ми'':51 ''минул'':52 ''можн'':53 ''навігації'':55 ''написан'':56 ''оновл'':1C ''оновлен'':58 ''оптимізаці'':60 ''оскільк'':61 ''отримує'':62 ''панелі'':63,64 ''пауз'':5C ''переважні'':65 ''переста'':66 ''побачит'':67 ''подобат'':68 ''притаман'':69 ''проблем'':70,71 ''провед'':72 ''прогрес'':73 ''продуктивн'':74 ''публікаці'':76 ''публікації'':77,78 ''після'':3C,79 ''реалізова'':80 ''ретельн'':81 ''ретельної'':82 ''розробк'':83 ''розробок'':84 ''рік'':85 ''сам'':86 ''самотужк'':87 ''стан'':59 ''створюват'':88 ''стикнул'':89 ''сьогоднішні'':90 ''також'':28 ''тепер'':91 ''тим'':75 ''тривалої'':4C ''фільтрації'':93 ''хронології'':94 ''це'':11,95 ''час'':96 ''частин'':97,98 ''чог'':99 ''швидкості'':100 ''що'':101 ''яв'':39 ''як'':103 ''є'':104 ''і'':7,105 ''іншої'':106 ''їх'':107', '', 1);


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
INSERT INTO "site"."users" ("id", "login", "password", "email", "last_ip", "token", "group_id") VALUES (1, 'admin', '6b5d3fde336ba463eb445a2d5bcfc30e', 'admin@cmska.org', '185.103.40.135', 'b7920ab9c5ee1eb08defdb8901702fdf', 1);


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

