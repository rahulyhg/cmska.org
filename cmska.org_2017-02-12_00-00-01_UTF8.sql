--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.5

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
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
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
    "group_id" integer DEFAULT 0 NOT NULL,
    "rsakey" "text" DEFAULT ''::"text" NOT NULL
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
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (22, 'тест 2', 'test_2', '', 'тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест', '<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>&#10;<p class=\"bb_p\"><i class=\"bb_i\">тест тест тест тест</i> тест <b class=\"bb_b\">тест тест тест тест тест тест</b> тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест тест</p>', 0, '2017-02-11 22:44:08.908414', '''2'':2C ''b'':16,19,66,69,116,119,166,169,216,219,266,269,316,319,366,369,416,419,466,469,516,519,566,569,616,619 ''bb'':5,9,18,55,59,68,105,109,118,155,159,168,205,209,218,255,259,268,305,309,318,355,359,368,405,409,418,455,459,468,505,509,518,555,559,568,605,609,618 ''class'':4,8,17,54,58,67,104,108,117,154,158,167,204,208,217,254,258,267,304,308,317,354,358,367,404,408,417,454,458,467,504,508,517,554,558,567,604,608,617 ''p'':3,6,53,56,103,106,153,156,203,206,253,256,303,306,353,356,403,406,453,456,503,506,553,556,603,606 ''тест'':1C,11,12,13,14,15,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,61,62,63,64,65,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,111,112,113,114,115,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,161,162,163,164,165,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,211,212,213,214,215,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,261,262,263,264,265,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,311,312,313,314,315,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,339,340,341', '', 3);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"posts_id_seq"', 22, true);


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

INSERT INTO "users" ("id", "login", "password", "email", "last_ip", "token", "group_id", "rsakey") VALUES (0, '--', '--', 'root@cmska.org', '0.0.0.0', '0', 0, '');
INSERT INTO "users" ("id", "login", "password", "email", "last_ip", "token", "group_id", "rsakey") VALUES (1, 'admin', '6b5d3fde336ba463eb445a2d5bcfc30e', 'admin@cmska.org', '109.227.107.124', 'c395ec76239541333afce135bd936004', 1, 'MIICQDCCASgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDJTYK7ypcC&#38;#13;&#38;#10;uP2z6Te+UNJGEa1cZLZMEnEPZXBb2jeMAj6o6aPbpYtYX8dGrQGpHtfUipgyEkQG&#38;#13;&#38;#10;3hUlxft2zefyf471OeWthrE5OznORaK4VuyoqkystaZrUmd8CbCPkfsQFpNiTqYI&#38;#13;&#38;#10;ta8FpCWasBQwXC2GGHvOFNvfVE+My+Gf7tLZq257Se/hMrnNF3VVctHF4V9aUvdL&#38;#13;&#38;#10;/+ZMOOg/QQJ/8xrpVgl7Yf8odw0Ixxmo/BPK4BOgTXJZYAS6m7ZGlOKEl2lBCUaK&#38;#13;&#38;#10;FZ3+zHapSgojk3zH4pe/nud6FYHxcFwJS1hL1iQK3eG23krMOx3yM8IOEVAgcWBf&#38;#13;&#38;#10;Djdn1frIA3ozAgMBAAEWADANBgkqhkiG9w0BAQQFAAOCAQEAqGJ0oerG0MVf3A6v&#38;#13;&#38;#10;6i2g0qownLVxD1IQvKBJ+27V9kidTEUoTKNDv53gO9XgSeOuwhPACiH3H1TwenKQ&#38;#13;&#38;#10;CSGdTpTqyba2wAUKwvWPRwMdZ+hV3mdlDYIuUnB0Y2rl/X0/FgKJZCmCpZGrCT34&#38;#13;&#38;#10;/QoNHrKgamHWtrlJfrmbiQCqpv0XalVOviUJPy6JO0IzGOhf22zGvTsTmM9z1EnP&#38;#13;&#38;#10;f7wD89PEuxyScAYnni06PHdd7Sh3VZODGtWw+4XxiUNA9K5riIrgUflCfHxiNHaZ&#38;#13;&#38;#10;Vhy1Gids9ZAkzISQiWbEEoTTWlNFgEWm1fs+0qmsG8zh5J2dmc0nqlaixEMVgBxU&#38;#13;&#38;#10;IrA4fQ==');


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

