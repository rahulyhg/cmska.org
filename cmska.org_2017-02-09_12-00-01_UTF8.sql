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
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (2, 'Бла бла блаб лбалао afgsdfg ghd fghsd ahdhhf asdf bglisdfgds lbdskg ', 'some_text', 'fghfdh dsfgsd dfhdh', 'ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ', 'ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ывпа впрывр ывпр ыароыр ываправпр авыр ', 0, '2016-12-18 09:56:51.070228', '''afgsdfg'':8C ''ahdhhf'':11C ''asdf'':12C ''bglisdfgd'':13C ''dfhdh'':3B ''dsfgsd'':2B ''fghfdh'':1B ''fghsd'':10C ''ghd'':9C ''lbdskg'':14C ''авыр'':20,26,32,38,44,50,56,62,68,74,80,86,92,98,104,110,116,122,128,134,140,146,152,158,164,170,176 ''бла'':4C,5C ''блаб'':6C ''впрывр'':16,22,28,34,40,46,52,58,64,70,76,82,88,94,100,106,112,118,124,130,136,142,148,154,160,166,172 ''лбала'':7C ''ыароыр'':18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120,126,132,138,144,150,156,162,168,174 ''ываправпр'':19,25,31,37,43,49,55,61,67,73,79,85,91,97,103,109,115,121,127,133,139,145,151,157,163,169,175 ''ывп'':15,21,27,33,39,45,51,57,63,69,75,81,87,93,99,105,111,117,123,129,135,141,147,153,159,165,171 ''ывпр'':17,23,29,35,41,47,53,59,65,71,77,83,89,95,101,107,113,119,125,131,137,143,149,155,161,167,173', '', 2);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (3, '', '', '', '', '', 0, '2016-12-29 12:45:26.75792', '', '', 0);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (4, 'Дранг нах остен в ЧНУ від професора Чабана11111111111111111111111', 'test', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.', 'Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”. gdfg&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами.', 0, '2016-12-29 22:45:54.04113', '''2016'':74,138,231 ''9'':9B,40,105,198 ''gdfg'':56 ''yоutube'':168,261,290 ''август'':83,147,240 ''анатолі'':12B,43,60,108,124,201,217 ''вважає'':181,274,303 ''від'':30C ''відкрит'':18B,49,114,207 ''він'':180,273,302 ''георг'':82,146,239 ''геттінгенськ'':79,143,174,236,267,296 ''говор'':176,269,298 ''де'':169,262,291 ''досвід'':87,151,244 ''дранг'':25C ''друг'':57,121,214 ''з'':167,186,260,279,289,308 ''заклад'':68,132,225 ''й'':96,160,189,253,282,311 ''колег'':97,161,190,254,283,312 ''лекці'':19B,50,115,208 ''лекції'':63,127,220 ''листопад'':10B,41,106,199 ''лиш'':93,157,250 ''мандруюч'':170,263,292 ''мандрівник'':90,154,247 ''місією'':183,276,305 ''навчальн'':67,131,224 ''науковц'':89,153,246 ''науковця-мандрівник'':88,152,245 ''нах'':26C ''національн'':5B,36,101,194 ''нижні'':85,149,242 ''німецьк'':187,280,309 ''німеччин'':69,133,226 ''ост'':27C ''офіційн'':2B,33,98,191 ''очим'':23B,54,119,212 ''перейма'':91,155,248 ''побува'':77,141,234 ''повідом'':7B,38,103,196 ''поспіл'':59,123,216 ''провів'':15B,46,111,204 ''професор'':11B,31C,42,76,107,140,171,200,233,264,293 ''розповідає'':172,265,294 ''рок'':75,139,232 ''ролик'':166,259,288 ''рік'':58,122,215 ''сайт'':3B,34,99,192 ''сайті'':72,136,163,229,256,285 ''саксонії'':86,150,243 ''своє'':182,275,304 ''спілкуванні'':185,278,307 ''студент'':94,158,188,251,281,310 ''студентів'':65,129,222 ''те'':178,271,300 ''тем'':21B,52,117,210 ''україн'':22B,53,118,211 ''університет'':6B,37,102,175,195,268,297 ''університеті'':17B,48,80,113,144,206,237 ''чаба'':1A,14B,45,110,203 ''чабана11111111111111111111111'':32C ''черкаськ'':4B,35,100,193 ''читає'':62,126,219 ''читаєм'':70,134,227 ''чну'':29C,73,137,164,230,257,286 ''що'':8B,39,104,179,197,272,301 ''юзефович'':13B,44,61,109,125,202,218 ''є'':165,258,287 ''європейців'':24B,55,120,213 ''імені'':81,145,238', 'Чабан', 0);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (5, 'Дранг нах остен в ЧНУ від професора Чабанаdsfsdfsdfsdfsf', 'test', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.', 'Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”. gdfg&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами.', 0, '2016-12-29 22:47:35.812046', '''2016'':74,138,231 ''9'':9B,40,105,198 ''gdfg'':56 ''yоutube'':168,261,290 ''август'':83,147,240 ''анатолі'':12B,43,60,108,124,201,217 ''вважає'':181,274,303 ''від'':30C ''відкрит'':18B,49,114,207 ''він'':180,273,302 ''георг'':82,146,239 ''геттінгенськ'':79,143,174,236,267,296 ''говор'':176,269,298 ''де'':169,262,291 ''досвід'':87,151,244 ''дранг'':25C ''друг'':57,121,214 ''з'':167,186,260,279,289,308 ''заклад'':68,132,225 ''й'':96,160,189,253,282,311 ''колег'':97,161,190,254,283,312 ''лекці'':19B,50,115,208 ''лекції'':63,127,220 ''листопад'':10B,41,106,199 ''лиш'':93,157,250 ''мандруюч'':170,263,292 ''мандрівник'':90,154,247 ''місією'':183,276,305 ''навчальн'':67,131,224 ''науковц'':89,153,246 ''науковця-мандрівник'':88,152,245 ''нах'':26C ''національн'':5B,36,101,194 ''нижні'':85,149,242 ''німецьк'':187,280,309 ''німеччин'':69,133,226 ''ост'':27C ''офіційн'':2B,33,98,191 ''очим'':23B,54,119,212 ''перейма'':91,155,248 ''побува'':77,141,234 ''повідом'':7B,38,103,196 ''поспіл'':59,123,216 ''провів'':15B,46,111,204 ''професор'':11B,31C,42,76,107,140,171,200,233,264,293 ''розповідає'':172,265,294 ''рок'':75,139,232 ''ролик'':166,259,288 ''рік'':58,122,215 ''сайт'':3B,34,99,192 ''сайті'':72,136,163,229,256,285 ''саксонії'':86,150,243 ''своє'':182,275,304 ''спілкуванні'':185,278,307 ''студент'':94,158,188,251,281,310 ''студентів'':65,129,222 ''те'':178,271,300 ''тем'':21B,52,117,210 ''україн'':22B,53,118,211 ''університет'':6B,37,102,175,195,268,297 ''університеті'':17B,48,80,113,144,206,237 ''чаба'':1A,14B,45,110,203 ''чабанаdsfsdfsdfsdfsf'':32C ''черкаськ'':4B,35,100,193 ''читає'':62,126,219 ''читаєм'':70,134,227 ''чну'':29C,73,137,164,230,257,286 ''що'':8B,39,104,179,197,272,301 ''юзефович'':13B,44,61,109,125,202,218 ''є'':165,258,287 ''європейців'':24B,55,120,213 ''імені'':81,145,238', 'Чабан', 0);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (6, 'Дранг нах остен в ЧНУ від професора Чабана', 'test', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.', 'Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”. gdfg&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами.', 0, '2016-12-29 22:49:12.54006', '''2016'':74,138,231 ''9'':9B,40,105,198 ''gdfg'':56 ''yоutube'':168,261,290 ''август'':83,147,240 ''анатолі'':12B,43,60,108,124,201,217 ''вважає'':181,274,303 ''від'':30C ''відкрит'':18B,49,114,207 ''він'':180,273,302 ''георг'':82,146,239 ''геттінгенськ'':79,143,174,236,267,296 ''говор'':176,269,298 ''де'':169,262,291 ''досвід'':87,151,244 ''дранг'':25C ''друг'':57,121,214 ''з'':167,186,260,279,289,308 ''заклад'':68,132,225 ''й'':96,160,189,253,282,311 ''колег'':97,161,190,254,283,312 ''лекці'':19B,50,115,208 ''лекції'':63,127,220 ''листопад'':10B,41,106,199 ''лиш'':93,157,250 ''мандруюч'':170,263,292 ''мандрівник'':90,154,247 ''місією'':183,276,305 ''навчальн'':67,131,224 ''науковц'':89,153,246 ''науковця-мандрівник'':88,152,245 ''нах'':26C ''національн'':5B,36,101,194 ''нижні'':85,149,242 ''німецьк'':187,280,309 ''німеччин'':69,133,226 ''ост'':27C ''офіційн'':2B,33,98,191 ''очим'':23B,54,119,212 ''перейма'':91,155,248 ''побува'':77,141,234 ''повідом'':7B,38,103,196 ''поспіл'':59,123,216 ''провів'':15B,46,111,204 ''професор'':11B,31C,42,76,107,140,171,200,233,264,293 ''розповідає'':172,265,294 ''рок'':75,139,232 ''ролик'':166,259,288 ''рік'':58,122,215 ''сайт'':3B,34,99,192 ''сайті'':72,136,163,229,256,285 ''саксонії'':86,150,243 ''своє'':182,275,304 ''спілкуванні'':185,278,307 ''студент'':94,158,188,251,281,310 ''студентів'':65,129,222 ''те'':178,271,300 ''тем'':21B,52,117,210 ''україн'':22B,53,118,211 ''університет'':6B,37,102,175,195,268,297 ''університеті'':17B,48,80,113,144,206,237 ''чаба'':1A,14B,32C,45,110,203 ''черкаськ'':4B,35,100,193 ''читає'':62,126,219 ''читаєм'':70,134,227 ''чну'':29C,73,137,164,230,257,286 ''що'':8B,39,104,179,197,272,301 ''юзефович'':13B,44,61,109,125,202,218 ''є'':165,258,287 ''європейців'':24B,55,120,213 ''імені'':81,145,238', 'Чабан', 0);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (7, 'Дранг нах остен в ЧНУ від професора Чабанаa asdfasdfasdfasdfasf', 'test', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.', 'Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”. gdfg&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами.', 0, '2016-12-29 22:49:21.517993', '''2016'':75,139,232 ''9'':9B,41,106,199 ''asdfasdfasdfasdfasf'':33C ''gdfg'':57 ''yоutube'':169,262,291 ''август'':84,148,241 ''анатолі'':12B,44,61,109,125,202,218 ''вважає'':182,275,304 ''від'':30C ''відкрит'':18B,50,115,208 ''він'':181,274,303 ''георг'':83,147,240 ''геттінгенськ'':80,144,175,237,268,297 ''говор'':177,270,299 ''де'':170,263,292 ''досвід'':88,152,245 ''дранг'':25C ''друг'':58,122,215 ''з'':168,187,261,280,290,309 ''заклад'':69,133,226 ''й'':97,161,190,254,283,312 ''колег'':98,162,191,255,284,313 ''лекці'':19B,51,116,209 ''лекції'':64,128,221 ''листопад'':10B,42,107,200 ''лиш'':94,158,251 ''мандруюч'':171,264,293 ''мандрівник'':91,155,248 ''місією'':184,277,306 ''навчальн'':68,132,225 ''науковц'':90,154,247 ''науковця-мандрівник'':89,153,246 ''нах'':26C ''національн'':5B,37,102,195 ''нижні'':86,150,243 ''німецьк'':188,281,310 ''німеччин'':70,134,227 ''ост'':27C ''офіційн'':2B,34,99,192 ''очим'':23B,55,120,213 ''перейма'':92,156,249 ''побува'':78,142,235 ''повідом'':7B,39,104,197 ''поспіл'':60,124,217 ''провів'':15B,47,112,205 ''професор'':11B,31C,43,77,108,141,172,201,234,265,294 ''розповідає'':173,266,295 ''рок'':76,140,233 ''ролик'':167,260,289 ''рік'':59,123,216 ''сайт'':3B,35,100,193 ''сайті'':73,137,164,230,257,286 ''саксонії'':87,151,244 ''своє'':183,276,305 ''спілкуванні'':186,279,308 ''студент'':95,159,189,252,282,311 ''студентів'':66,130,223 ''те'':179,272,301 ''тем'':21B,53,118,211 ''україн'':22B,54,119,212 ''університет'':6B,38,103,176,196,269,298 ''університеті'':17B,49,81,114,145,207,238 ''чаба'':1A,14B,46,111,204 ''чабанаa'':32C ''черкаськ'':4B,36,101,194 ''читає'':63,127,220 ''читаєм'':71,135,228 ''чну'':29C,74,138,165,231,258,287 ''що'':8B,40,105,180,198,273,302 ''юзефович'':13B,45,62,110,126,203,219 ''є'':166,259,288 ''європейців'':24B,56,121,214 ''імені'':82,146,239', 'Чабан', 0);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (8, 'Дранг нах остен в ЧНУ від професора Чабана', 'test', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.', 'Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”. gdfg&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.&#10;&#10;- Другий рік поспіль Анатолій Юзефович читає лекції для студентів у навчальних закладах Німеччини, читаємо на сайті ЧНУ.  - 2016 року професор побував у Геттінгенському університеті імені Георга Августа в Нижній Саксонії. Досвід науковця-мандрівника переймали не лише студенти, а й колеги.&#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами. &#10;&#10;На сайті ЧНУ є ролик з YоuTube, де мандруючий професор розповідає про Геттінгенський університет, говорить про те, що він вважає своєю місією в спілкуванні з німецькими студентами й колегами.', 0, '2016-12-29 22:50:28.847359', '''2016'':74,138,231 ''9'':9B,40,105,198 ''gdfg'':56 ''yоutube'':168,261,290 ''август'':83,147,240 ''анатолі'':12B,43,60,108,124,201,217 ''вважає'':181,274,303 ''від'':30C ''відкрит'':18B,49,114,207 ''він'':180,273,302 ''георг'':82,146,239 ''геттінгенськ'':79,143,174,236,267,296 ''говор'':176,269,298 ''де'':169,262,291 ''досвід'':87,151,244 ''дранг'':25C ''друг'':57,121,214 ''з'':167,186,260,279,289,308 ''заклад'':68,132,225 ''й'':96,160,189,253,282,311 ''колег'':97,161,190,254,283,312 ''лекці'':19B,50,115,208 ''лекції'':63,127,220 ''листопад'':10B,41,106,199 ''лиш'':93,157,250 ''мандруюч'':170,263,292 ''мандрівник'':90,154,247 ''місією'':183,276,305 ''навчальн'':67,131,224 ''науковц'':89,153,246 ''науковця-мандрівник'':88,152,245 ''нах'':26C ''національн'':5B,36,101,194 ''нижні'':85,149,242 ''німецьк'':187,280,309 ''німеччин'':69,133,226 ''ост'':27C ''офіційн'':2B,33,98,191 ''очим'':23B,54,119,212 ''перейма'':91,155,248 ''побува'':77,141,234 ''повідом'':7B,38,103,196 ''поспіл'':59,123,216 ''провів'':15B,46,111,204 ''професор'':11B,31C,42,76,107,140,171,200,233,264,293 ''розповідає'':172,265,294 ''рок'':75,139,232 ''ролик'':166,259,288 ''рік'':58,122,215 ''сайт'':3B,34,99,192 ''сайті'':72,136,163,229,256,285 ''саксонії'':86,150,243 ''своє'':182,275,304 ''спілкуванні'':185,278,307 ''студент'':94,158,188,251,281,310 ''студентів'':65,129,222 ''те'':178,271,300 ''тем'':21B,52,117,210 ''україн'':22B,53,118,211 ''університет'':6B,37,102,175,195,268,297 ''університеті'':17B,48,80,113,144,206,237 ''чаба'':1A,14B,32C,45,110,203 ''черкаськ'':4B,35,100,193 ''читає'':62,126,219 ''читаєм'':70,134,227 ''чну'':29C,73,137,164,230,257,286 ''що'':8B,39,104,179,197,272,301 ''юзефович'':13B,44,61,109,125,202,218 ''є'':165,258,287 ''європейців'':24B,55,120,213 ''імені'':81,145,238', 'Чабан', 0);
INSERT INTO "posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category") VALUES (1, 'Дранг нах остен в ЧНУ від професора Чабана', 'test', 'Офіційний сайт Черкаського Національного університету повідомив, що 9 листопада професор Анатолій Юзефович Чабан провів в університеті відкриту лекцію на тему “Україна очима європейців”.', 'Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.  Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.', 'Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов м''ячиком, та фантазує без упину. Анатолій Юзефович яскраво продемонстрував, у чому полягає різниця між “їхньою” професурою, європейською - сухою, скрупульозною й невеселою — і вітчизняною, що жонглює фактами, мов мячиком, та фантазує без упину.', 0, '2016-11-10 20:58:30.33333', '''9'':9B ''анатолі'':12B,33,61 ''від'':30C ''відкрит'':18B ''вітчизнян'':50,78 ''дранг'':25C ''жонглює'':52,80 ''й'':47,75 ''лекці'':19B ''листопад'':10B ''м'':55 ''мов'':54,82 ''мячик'':83 ''між'':41,69 ''нах'':26C ''національн'':5B ''невесел'':48,76 ''ост'':27C ''офіційн'':2B ''очим'':23B ''повідом'':7B ''полягає'':39,67 ''провів'':15B ''продемонструва'':36,64 ''професор'':11B,31C ''професур'':43,71 ''різниц'':40,68 ''сайт'':3B ''скрупульозн'':46,74 ''сух'':45,73 ''та'':57,84 ''тем'':21B ''україн'':22B ''університет'':6B ''університеті'':17B ''упин'':60,87 ''факт'':53,81 ''фантазує'':58,85 ''чаба'':1A,14B,32C ''черкаськ'':4B ''чну'':29C ''чом'':38,66 ''що'':8B,51,79 ''юзефович'':13B,34,62 ''яскрав'':35,63 ''ячик'':56 ''європейськ'':44,72 ''європейців'':24B ''і'':49,77 ''їхньо'':42,70', 'Чабан', 3);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"posts_id_seq"', 8, true);


--
-- Data for Name: posts_tags; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "posts_tags" ("post_id", "tag_id") VALUES (2, 1);
INSERT INTO "posts_tags" ("post_id", "tag_id") VALUES (2, 2);


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
INSERT INTO "users" ("id", "login", "password", "email", "last_ip", "token", "group_id") VALUES (1, 'admin', '6b5d3fde336ba463eb445a2d5bcfc30e', 'admin@cmska.org', '185.103.42.183', '0f59ab6a3a6952b3c5ff5ad04cbf9198', 1);


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

