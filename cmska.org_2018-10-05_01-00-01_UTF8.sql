--
-- PostgreSQL database dump
--

-- Dumped from database version 10.5 (Debian 10.5-1.pgdg80+1)
-- Dumped by pg_dump version 10.5 (Debian 10.5-1.pgdg80+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
SET idle_in_transaction_session_timeout = 0;
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

	STXT = NEW.full_post;

	NEW.svector = 
		setweight( coalesce( to_tsvector( lower(NEW.keywords) ),''),'A') || ' ' || 
		setweight( coalesce( to_tsvector( lower(NEW.descr)),''),'B') || ' ' ||
		setweight( coalesce( to_tsvector( lower(NEW.title)),''),'C') || ' ' ||
		setweight( coalesce( to_tsvector( lower( STXT )),''),'D');

  RETURN NEW;
END;$$;


--
-- Name: upd_token_time(); Type: FUNCTION; Schema: site; Owner: -
--

CREATE FUNCTION "site"."upd_token_time"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
	DECLARE

BEGIN

  NEW.token_upd_time = NOW()::timestamp;
  RETURN NEW;
	
END
$$;


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
    "md5" character varying(32) DEFAULT ''::character varying NOT NULL,
    "load_time" timestamp without time zone DEFAULT ("now"())::timestamp without time zone NOT NULL,
    "orig_name" character varying(255) DEFAULT ''::character varying NOT NULL,
    "size" integer DEFAULT 0 NOT NULL,
    "user_id" bigint DEFAULT 0 NOT NULL,
    "post_id" bigint DEFAULT 0 NOT NULL,
    "mime" character varying(255) DEFAULT ''::character varying NOT NULL,
    "encoded" smallint DEFAULT 0 NOT NULL,
    "keyring" character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: images; Type: TABLE; Schema: site; Owner: -
--

CREATE TABLE "site"."images" (
    "post_id" bigint DEFAULT 0 NOT NULL,
    "user_id" bigint DEFAULT 0 NOT NULL,
    "serv_name" character varying(32) DEFAULT ''::character varying NOT NULL,
    "load_time" timestamp without time zone DEFAULT ("now"())::timestamp without time zone NOT NULL,
    "is_mini" smallint DEFAULT 0 NOT NULL,
    "md5" character varying(32) DEFAULT ''::character varying NOT NULL
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
    "group_id" integer DEFAULT 0 NOT NULL,
    "token_upd_time" timestamp without time zone DEFAULT (("now"() - '1 day'::interval))::timestamp without time zone NOT NULL
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
-- Name: admin_menu id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."admin_menu_id_seq"'::"regclass");


--
-- Name: categories id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."categories" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."categories_id_seq"'::"regclass");


--
-- Name: posts id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."posts_id_seq"'::"regclass");


--
-- Name: tags id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."tags" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."tags_id_seq"'::"regclass");


--
-- Name: user_groups id; Type: DEFAULT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."user_groups" ALTER COLUMN "id" SET DEFAULT "nextval"('"site"."user_groups_id_seq"'::"regclass");


--
-- Name: users id; Type: DEFAULT; Schema: site; Owner: -
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
-- Data for Name: categories; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (0, '--', '--', 0, '', 0, 0);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (1, 'blog', 'Блог розробників', 0, '0', 0, 0);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (2, 'release', 'Релізи', 0, '0', 0, 0);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (3, 'addon', 'Доповнення', 0, '0', 0, 0);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (4, 'hack', 'Дрібні хаки', 3, '0-3', 0, 1);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (5, 'tpl', 'Зовнішній вигляд', 3, '0-3', 0, 1);
INSERT INTO "site"."categories" ("id", "altname", "name", "parent_id", "ptree", "position", "level") VALUES (6, 'newfunc', 'Нові функції', 1, '0-1', 0, 1);


--
-- Data for Name: files; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."files" ("md5", "load_time", "orig_name", "size", "user_id", "post_id", "mime", "encoded", "keyring") VALUES ('e3fc5cea3153f5864423a48f617c93d0', '2018-09-20 09:58:39', 'praktika_setevogo_administrirovaniya_2018.pdf', 1041774, 1, 13, 'application/pdf', 1, '3=*u1eb4xifkos^t+r6gjdl{@zvw8m$y0a-ch5n2p}&7997&}p2n5hc-a0y$m8wvz@{ldjg6r+t^sokfix4be1u*=3');


--
-- Data for Name: images; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."images" ("post_id", "user_id", "serv_name", "load_time", "is_mini", "md5") VALUES (4, 1, '21-26-14-f1cbda65.png', '2018-09-18 21:26:17', 0, '31de518cfef91db5be3690e5cb67adcd');
INSERT INTO "site"."images" ("post_id", "user_id", "serv_name", "load_time", "is_mini", "md5") VALUES (4, 1, '21-28-56-cf1f5bbf.png', '2018-09-18 21:28:56', 0, 'aeaeb8cf96b67a3689daa9bcabb9b959');
INSERT INTO "site"."images" ("post_id", "user_id", "serv_name", "load_time", "is_mini", "md5") VALUES (13, 1, '21-47-13-e3b88107.png', '2018-09-18 21:47:13', 0, '0dc32614374f07209eae913e78ea656a');
INSERT INTO "site"."images" ("post_id", "user_id", "serv_name", "load_time", "is_mini", "md5") VALUES (4, 1, '14-58-25-1aa82125.png', '2018-09-20 14:58:26', 0, '1a8a494cc2eb36e360c5b62407453b16');
INSERT INTO "site"."images" ("post_id", "user_id", "serv_name", "load_time", "is_mini", "md5") VALUES (3, 1, '15-03-59-a1f10908.png', '2018-09-20 15:03:59', 0, '93220405e38aa305e1e7280d21e0cdb8');
INSERT INTO "site"."images" ("post_id", "user_id", "serv_name", "load_time", "is_mini", "md5") VALUES (2, 1, '15-07-27-3240a001.png', '2018-09-20 15:07:27', 0, 'd5b374573ca214500287a69f4c0b3484');
INSERT INTO "site"."images" ("post_id", "user_id", "serv_name", "load_time", "is_mini", "md5") VALUES (1, 1, '15-22-47-22678c58.png', '2018-09-20 15:22:47', 0, '255113cbf69316682757ab092c5d9915');
INSERT INTO "site"."images" ("post_id", "user_id", "serv_name", "load_time", "is_mini", "md5") VALUES (13, 1, '11-43-47-3722bee6.png', '2018-09-23 11:43:48', 0, '9116ff3d26f7e6f4a50cba13efc99d69');


--
-- Data for Name: posts; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (0, '', '', '', '', '', 0, '2016-11-08 23:22:58', '', '', 0, 0, 0, 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (3, 'Навіщо ще одна CMS?', 'navishho_shhe_odna_sistema_keruvannya_kontentom', '', 'Це питання особисто мені задають всі хто вперше дізнається про розробку чогось нового. Особливо якщо людина знайома з поняттям CMS. Але все не так просто, як здається на перший погляд...&#10;&#10;<img class="post_img" src="/uploads/images/2018-09-20/15-03-59-a1f10908.png" alt="" title="" />', '<p class=\"bb_p\">За основу можна взяти будь-що, але видивитись переваги й недоліки можна тільки після детального аналізу роботи. Якщо глянути список доступних для використання CMS, то бере сумнів в тому, що ніхто раніше не реалізовував щось подібне. Але... Є нюанси!</p>&#10;<h2 class=\"bb_h2\">Content-Security-Policy</h2>&#10;<p class=\"bb_p\">CSP рекомендується консорціумом W3C. CSP намагаються використовувати web-гіганти, але натикаються на проблеми, що витікають з принципу базової розробки. А в сфері систем керування контентом ситуація значно гірша. Встановіть CSP на найвищий рівень:</p>&#10;<code class="bb_code">Content-Security-Policy&colon; default-src &apos;self&apos;&semi;</code>&#10;<p class=\"bb_p\">і ви не знайдете CMS, яка б адекватно працювала. Про роботу в режимі "production" мова не заводиться взагалі.</p>&#10;<h2 class=\"bb_h2\">PostgreSQL</h2>&#10;<p class=\"bb_p\">Більшість розробників CMS, з метою підтримки якомога більшої кількості СУБД, користуються лише тими функціональними можливостями, які притаманні всім СУБД. Інші ж реалізовують лише підтримку MySQL.</p>&#10;<p class=\"bb_p\">Мати в розпорядженні СУБД, але користуватись тільки можливостями занесення/зчитування даних - безглуздо.</p>&#10;<p class=\"bb_p\">Ми реалізовуємо лише підтримку PostgreSQL з використанням більшості доступних особливостей цієї ОСУБД.</p>&#10;&#10;<h2 class=\"bb_h2\">php 7</h2>&#10;<p class=\"bb_p\">Зрозуміло, що використання php останньої версії не новинка в сфері написання коду, але як і з CSP важливими є налаштування. Переведемо PHP  в режим коли розробнику не сходять з рук дрібні помилки:</p>&#10;<code class="bb_code">error&lowbar;reporting &lpar; E&lowbar;ALL &rpar;&semi;</code>&#10;<p class=\"bb_p\">і ситуація буде такою ж як і з CSP - знайти CMS, яка працюватиме, буде вкрай складно, а в "production" тільки після власноручного допилювання.</p>&#10;<h2 class=\"bb_h2\">Шаблони</h2>&#10;<p class=\"bb_p\">Хто користувався різними CMS мабуть неодноразово помічав, що іноді розробники спрощують метод виведення інформації в шаблон, розміщуючи в останньому елементи PHP. В такому випадку, розробка шаблону для власного сайту є задачею не по зубах для людини, яка не володіє необхідною мовою програмування.</p>&#10;<p class=\"bb_p\">Ми використовуємо чисті HTML шаблони, інформація в які вноситься за кодовими мітками. Це не новинка, але це важливо.</p>&#10;<h2 class=\"bb_h2\">Використання серверної пам''яті</h2>&#10;<p class=\"bb_p\">Наш результат - до 1Mb при завантаженні будь-якої сторінки сайту.</p>', 1, '2017-02-12 23:54:53.664647', '''1mb'':352 ''7'':196 ''bb'':7,51,59,105,127,132,161,177,193,199,239,266,271,317,339,347 ''class'':6,50,58,104,126,131,160,176,192,198,238,265,270,316,338,346 ''cms'':4C,33,111,136,251,276 ''content'':54,96 ''content-security-polici'':53,95 ''csp'':61,65,91,217,249 ''default'':100 ''default-src'':99 ''e'':235 ''error'':233 ''h2'':49,52,125,128,191,194,264,267,337,340 ''html'':322 ''mysql'':158 ''p'':5,8,57,60,103,106,130,133,159,162,175,178,197,200,237,240,269,272,315,318,345,348 ''php'':195,204,222,293 ''polici'':56,98 ''postgresql'':129,183 ''product'':120,259 ''report'':234 ''secur'':55,97 ''self'':102 ''src'':101 ''w3c'':64 ''web'':69 ''web-гігант'':68 ''адекватн'':114 ''ал'':16,46,71,167,213,334 ''аналіз'':25 ''б'':113 ''базової'':79 ''безглузд'':174 ''бер'':35 ''буд'':14,243,254,356 ''будь-щ'':13 ''будь-якої'':355 ''більшості'':186 ''більшої'':141 ''більшість'':134 ''важлив'':218,336 ''версії'':206 ''взагалі'':124 ''взят'':12 ''ви'':108 ''виведен'':285 ''видивит'':17 ''використан'':32,185,203,341 ''використовуват'':67 ''використовуєм'':320 ''випадк'':296 ''витікают'':76 ''вкра'':255 ''власн'':300 ''власноручн'':262 ''внос'':327 ''володіє'':311 ''встановіт'':90 ''всім'':151 ''глянут'':28 ''гігант'':70 ''гірша'':89 ''дан'':173 ''детальн'':24 ''допилюван'':263 ''доступн'':30,187 ''дрібні'':231 ''елемент'':292 ''з'':77,137,184,216,229,248 ''завантаженні'':354 ''завод'':123 ''задач'':303 ''занесен'':171 ''знайдет'':110 ''знайт'':250 ''значн'':88 ''зрозуміл'':201 ''зуб'':306 ''зчитуван'':172 ''й'':19 ''керуван'':85 ''код'':212 ''кодов'':329 ''кол'':225 ''консорціум'':63 ''контент'':86 ''користував'':274 ''користуват'':168 ''користуют'':144 ''кількості'':142 ''лиш'':145,156,181 ''людин'':308 ''мабут'':277 ''мат'':163 ''мет'':138 ''метод'':284 ''ми'':179,319 ''мов'':121,313 ''можлив'':148,170 ''можн'':11,21 ''міткам'':330 ''навіщ'':1C ''найвищ'':93 ''налаштуван'':220 ''намагают'':66 ''написан'':211 ''натикают'':72 ''наш'':349 ''недолік'':20 ''необхідн'':312 ''неодноразов'':278 ''новинк'':208,333 ''нюанс'':48 ''ніхто'':40 ''одн'':3C ''основ'':10 ''особлив'':188 ''останн'':291 ''останньої'':205 ''осубд'':190 ''пам'':343 ''переваг'':18 ''переведем'':221 ''подібн'':45 ''помилк'':232 ''поміча'':279 ''працюва'':115 ''працюватим'':253 ''принцип'':78 ''притаманні'':150 ''проблем'':74 ''програмуван'':314 ''підтримк'':139,157,182 ''після'':23,261 ''раніш'':41 ''реалізовува'':43 ''реалізовуют'':155 ''реалізовуєм'':180 ''реж'':224 ''режимі'':119 ''результат'':350 ''рекомендуєт'':62 ''робот'':26,117 ''розміщуюч'':289 ''розпорядженні'':165 ''розробк'':80,297 ''розробник'':226,282 ''розробників'':135 ''рук'':230 ''рівен'':94 ''різним'':275 ''сайт'':301,359 ''серверної'':342 ''сист'':84 ''ситуаці'':87,242 ''складн'':256 ''список'':29 ''спрощуют'':283 ''сторінк'':358 ''субд'':143,152,166 ''сумнів'':36 ''сфері'':83,210 ''сходя'':228 ''так'':244,295 ''тим'':146 ''том'':38 ''тільки'':22,169,260 ''функціональн'':147 ''хто'':273 ''це'':331,335 ''цієї'':189 ''чисті'':321 ''шаблон'':268,288,298,323 ''ще'':2C ''що'':15,39,44,75,202,280 ''як'':112,214,246,252,309 ''якомог'':140 ''якої'':357 ''якщ'':27 ''які'':149,326 ''яті'':344 ''є'':47,219,302 ''і'':107,215,241,247 ''іноді'':281 ''інформаці'':324 ''інформації'':286 ''інші'':153', '', 1, 1, 0, 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (2, 'define', 'define', '', 'В даній публікації я познайомлю Вас з деякими парадигмами, константами CMS яку ми пишемо.&#10;&#10;<img class="post_img" src="/uploads/images/2018-09-20/15-07-27-3240a001.png" alt="" title="" />', '<code class="bb_code">define&lpar; &apos;open&lowbar;source&apos;&comma; true &rpar;&semi;</code>&#10;<p class=\"bb_p\">Дана CMS є розробкою з відкритим вихідним кодом, тобто кожен бажаючий може використовувати її в власних цілях. Група розробників сайту "cmska.org" залишає за собою право розробки та супроводу даного програмного продукту.</p>&#10;<br>&#10;<code class="bb_code">define&lpar; &apos;language&apos;&comma; &apos;&Ucy;&kcy;&rcy;&acy;&yicy;&ncy;&scy;&softcy;&kcy;&acy;&apos; &rpar;&semi;</code>&#10;<p class=\"bb_p\">Розробники "cmska.org" є громадянами України, а тому на даному ресурсі та в розробці використовується лише Українська мова.</p>&#10;<br>&#10;<code class="bb_code">define&lpar; &apos;security&lowbar;level&apos;&comma; &apos;&Ncy;&acy;&jcy;&vcy;&icy;&shchcy;&icy;&jcy;&apos; &rpar;&semi;</code>&#10;<p class=\"bb_p\">В своїй діяльності розробники керуються принципом максимальної захищеності як користувачів так і сайту. З метою здійснення цього принципу розробники зобов''язуються в межах своєї компетенції використовувати всі методи підвищення рівня захисту.</p>', 1, '2017-02-12 22:03:08.457754', '''bb'':8,45,69 ''class'':7,44,68 ''cms'':11 ''cmska.org'':30,48 ''defin'':1C,2,41,64 ''languag'':42 ''level'':66 ''open'':3 ''p'':6,9,43,46,67,70 ''secur'':65 ''sourc'':4 ''true'':5 ''бажаюч'':20 ''використовуват'':22,96 ''використовуєт'':60 ''вихідн'':16 ''власн'':25 ''всі'':97 ''відкрит'':15 ''громадян'':50 ''груп'':27 ''дан'':10,38,55 ''діяльності'':73 ''з'':14,84 ''залишає'':31 ''захист'':101 ''захищеності'':78 ''здійснен'':86 ''зоб'':90 ''керуют'':75 ''код'':17 ''кож'':19 ''компетенції'':95 ''користувачів'':80 ''лиш'':61 ''максимальної'':77 ''меж'':93 ''мет'':85 ''метод'':98 ''мов'':63 ''мож'':21 ''прав'':34 ''принцип'':76,88 ''програмн'':39 ''продукт'':40 ''підвищен'':99 ''ресурсі'':56 ''розробк'':13,35 ''розробник'':47,74,89 ''розробників'':28 ''розробці'':59 ''рівня'':100 ''сайт'':29,83 ''своєї'':94 ''свої'':72 ''соб'':33 ''супровод'':37 ''та'':36,57 ''тобт'':18 ''том'':53 ''україн'':51 ''українськ'':62 ''цьог'':87 ''цілях'':26 ''язуют'':91 ''як'':79 ''є'':12,49 ''і'':82 ''її'':23', '', 1, 1, 0, 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (1, 'Нова розробка - нова історія', 'nova_rozrobka_cms_z_visokim_rivnem_zahistu', '', 'Це перша публікація в даній CMS. В ній я розповім про нову структуру, можливості та особливості сайту. Також постараюсь трішки торкнутись історії та розповім про причини створення даного ресурсу.&#10;&#10;<img class="post_img" src="/uploads/images/2018-09-20/15-22-47-22678c58.png" alt="" title="" />', '<p class=\"bb_p\">Розпочнемо мабуть з початку, а саме з причин створення як ресурсу в цілому так і його серверної частини. Доречі в рамках історичного екскурсу можуть зачіпатись теми, які багатьом припікають сраки, тому хто вже відчуває нестабільність температурного режиму - далі не читайте :)</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.1.0 - <span class=\"bb_span\" title="Всім похуй">Nemo curat</span></h2>&#10;<p class=\"bb_p\">Історія ресурсу cmska.org розпочалась в далекому 2007 році з реєстрації доменного імені "cmska.org.ua". Спочатку це був аматорський сайт двох студентів, яким було просто цікаво дізнатись як працюють сайти. Наступним кроком була спеціалізація контенту - в якості каркасу для сайту було обрано CMS DLE (тоді ще не загиджений), а сам сайт цілком перетворено на сайт підтримки даної CMS.</p>&#10;<p class=\"bb_p\">Так тривало довго. Змінювався склад аматорів, змінювався зовнішній вигляд сайту, незмінною були лише домен та тематика. І тривало так до моменту виходу в світ першої розробки від одного з авторів "cmska.org.ua".</p>&#10;<p class=\"bb_p\">Перша розробка дала рушійну силу (WMZ) і розуміння того, що web-сфера не заповнена в необхідній мірі, а виходячи з того, що знайовся покупець на відверту аматорську роботу - web-сфера вимагала продовження.</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.2.0 - <span class=\"bb_span\" title="Довіряй, але дивись кому">Fide, sed cui fidas, vide</span></h2>&#10;<p class=\"bb_p\">В 2009 році було придбано домен "cmska.org". На цей період авторський склад час від часу випускав модулі для CMS DLE та приймав активну участь у тодішньому main-stream - створення автоматизованої системи для швидкого і якісного генерування сайтів. Останнє заняття давало значну фінансову підтримку - вміння генерувати "унікальний" контент + володіння навичками SEO завжди давали гарний прибуток.</p>&#10;<p class=\"bb_p\">На початку 10-х серед авторського складу проекту cmska стався перший розкол - всі чотири учасники вирішили розпочати власний шлях... і жоден не хотів продовжувати попередню тематику. Причина проста - зі збільшенням популярності проекту, збільшувались і випадки витоку платного контенту, в результаті чого місяці розробки втрачали можливість бути оплачуваними. Тематика CMS DLE втратила актуальність як неоплачувана.</p>&#10;<p class=\"bb_p\">Весь проект, всі вихідні коди залишились в одного з співавторів - в мене. Я завжди притримувався ідей публічності та допомоги починаючим web-розробникам, а тому через деякий час після припинення діяльності було прийняте рішення "відродити" проект - продовжити створення унікального функціоналу та контенту. Але все ж слід приймати до уваги, що тематика "неофіційної підтримки" комерційного програмного засобу - ідея абсурдна. Тому...</p>&#10;&#10;<h2 class=\"bb_h2\">CMSka.org v.3.0 - <span class=\"bb_span\" title="Все змінюється, ніщо не зникає безслідно">Omnia mutantur, nihil interit</span></h2>&#10;<p class=\"bb_p\">З середини 2015 року було розпочато розробку нової CMS - некомерційного продукту з відкритим вихідним кодом, який би враховував не примхи й забаганки "project manager", а рекомендації щодо безпеки та продуктивності.</p>&#10;&#10;', 1, '2017-02-12 16:38:41.175227', '''10'':282 ''2007'':74 ''2009'':222 ''2015'':424 ''bb'':7,51,57,66,126,161,199,205,219,278,336,399,405,420 ''class'':6,50,56,65,125,160,198,204,218,277,335,398,404,419 ''cms'':108,123,239,328,430 ''cmska'':288 ''cmska.org'':53,70,201,227,401 ''cmska.org.ua'':80,158 ''cui'':214 ''curat'':63 ''dle'':109,240,329 ''fida'':215 ''fide'':212 ''h2'':49,52,197,200,397,400 ''interit'':417 ''main'':248 ''main-stream'':247 ''manag'':445 ''mutantur'':415 ''nemo'':62 ''nihil'':416 ''omnia'':414 ''p'':5,8,64,67,124,127,159,162,217,220,276,279,334,337,418,421 ''project'':444 ''sed'':213 ''seo'':271 ''span'':55,58,203,206,403,406 ''stream'':249 ''titl'':59,207,407 ''v.1.0'':54 ''v.2.0'':202 ''v.3.0'':402 ''vide'':216 ''web'':174,193,359 ''web-розробник'':358 ''web-сфер'':173,192 ''wmz'':168 ''абсурдн'':395 ''автоматизованої'':251 ''авторськ'':231,285 ''авторів'':157 ''активн'':243 ''актуальніст'':331 ''ал'':209,380 ''аматорськ'':84,190 ''аматорів'':133 ''багат'':36 ''безпек'':449 ''безслідн'':413 ''би'':438 ''був'':83 ''бул'':89,98,106,139,224,369,426 ''бут'':325 ''ве'':338 ''вже'':41 ''вигляд'':136 ''вимага'':195 ''випадк'':314 ''випуска'':236 ''виріш'':295 ''виток'':315 ''виход'':149 ''виходяч'':182 ''вихідн'':435 ''вихідні'':341 ''власн'':297 ''вміння'':265 ''володін'':269 ''враховува'':439 ''всі'':292,340 ''всім'':60 ''втрат'':330 ''втрача'':323 ''від'':154,234 ''відверт'':189 ''відкрит'':434 ''відродит'':372 ''відчуває'':42 ''гарн'':274 ''генеруван'':257 ''генеруват'':266 ''дава'':261,273 ''дал'':165 ''далек'':73 ''далі'':46 ''даної'':122 ''двох'':86 ''деяк'':364 ''див'':210 ''довг'':130 ''довіря'':208 ''дом'':141,226 ''домен'':78 ''допомог'':356 ''доречі'':27 ''дізнат'':92 ''діяльності'':368 ''екскурс'':31 ''жод'':300 ''з'':11,15,76,156,183,346,422,433 ''забаганк'':443 ''завжд'':272,351 ''загиджен'':113 ''залиш'':343 ''занятт'':260 ''заповн'':177 ''засоб'':393 ''зачіпат'':33 ''збільшен'':309 ''збільшува'':312 ''змінював'':131,134 ''змінюєт'':409 ''знай'':186 ''значн'':262 ''зникає'':412 ''зовнішні'':135 ''зі'':308 ''й'':442 ''йог'':24 ''каркас'':103 ''код'':342,436 ''ком'':211 ''комерційн'':391 ''контент'':100,268,317,379 ''крок'':97 ''лиш'':140 ''мабут'':10 ''мен'':349 ''модулі'':237 ''можливіст'':324 ''можут'':32 ''момент'':148 ''мірі'':180 ''місяці'':321 ''навичк'':270 ''наступн'':96 ''незмін'':138 ''некомерційн'':431 ''необхідні'':179 ''неоплачува'':333 ''неофіційної'':389 ''нестабільніст'':43 ''нов'':1C,3C ''нової'':429 ''ніщо'':410 ''обра'':107 ''одн'':155,345 ''оплачуван'':326 ''останнє'':259 ''перетвор'':118 ''перш'':163,290 ''першої'':152 ''період'':230 ''платн'':316 ''покупец'':187 ''попередн'':304 ''популярності'':310 ''пох'':61 ''початк'':12,281 ''починаюч'':357 ''працюют'':94 ''прибуток'':275 ''придба'':225 ''прийма'':242 ''приймат'':384 ''прийнят'':370 ''примх'':441 ''припинен'':367 ''припікают'':37 ''притримував'':352 ''причин'':16,306 ''програмн'':392 ''продовжен'':196 ''продовжит'':374 ''продовжуват'':303 ''продукт'':432 ''продуктивності'':451 ''проект'':287,311,339,373 ''прост'':90,307 ''публічності'':354 ''підтримк'':121,264,390 ''після'':366 ''рамк'':29 ''режим'':45 ''результаті'':319 ''рекомендації'':447 ''ресурс'':19,69 ''реєстрації'':77 ''робот'':191 ''розкол'':291 ''розпоча'':71 ''розпочат'':296,427 ''розпочнем'':9 ''розробк'':2C,153,164,322,428 ''розробник'':360 ''розумін'':170 ''рок'':425 ''році'':75,223 ''рушійн'':166 ''рішен'':371 ''сайт'':85,95,105,116,120,137 ''сайтів'':258 ''сам'':14 ''світ'':151 ''серверної'':25 ''серед'':284 ''середин'':423 ''сил'':167 ''систем'':252 ''склад'':132,232,286 ''слід'':383 ''спеціалізаці'':99 ''спочатк'':81 ''співавторів'':347 ''срак'':38 ''став'':289 ''створен'':17,250,375 ''студентів'':87 ''сфер'':175,194 ''та'':142,241,355,378,450 ''тем'':34 ''тематик'':143,305,327,388 ''температурн'':44 ''тоді'':110 ''тодішн'':246 ''том'':39,362,396 ''трива'':129,145 ''уваг'':386 ''унікальн'':267,376 ''учасник'':294 ''участ'':244 ''функціонал'':377 ''фінансов'':263 ''х'':283 ''хотів'':302 ''хто'':40 ''це'':82,229 ''цікав'':91 ''цілком'':117 ''цілом'':21 ''час'':233,235,365 ''частин'':26 ''чита'':48 ''чог'':320 ''чотир'':293 ''швидк'':254 ''шлях'':298 ''ще'':111 ''що'':172,185,387 ''щод'':448 ''як'':18,88,93,332,437 ''якості'':102 ''які'':35 ''якісн'':256 ''і'':23,144,169,255,299,313 ''іде'':353,394 ''імені'':79 ''історичн'':30 ''історі'':4C,68', '', 1, 1, 0, 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (4, 'Оновлена версія після тривалої паузи', 'onovlena_versiya_pislya_trivaloi_pauzi', '', 'На сьогоднішній день ми стикнулись з проблемою, що притаманна мабуть переважній більшості не комерційних авторських розробок - вихід оновлень.&#10;&#10;<img class="post_img" src="/uploads/images/2018-09-20/14-58-25-1aa82125.png" alt="" title="" />', '<p class=\"bb_p\">На сьогоднішній день ми стикнулись з проблемою, що притаманна мабуть переважній більшості не комерційних авторських розробок - вихід оновлень.</p>&#10;<p class=\"bb_p\">Станом на час написання даної публікації, розробкою займаюсь я самотужки. І як можна побачити з хронології публікацій - цей рік видався не дуже продуктивним.</p>&#10;&#10;<p class=\"bb_p align_center\"><img class="post_img" src="/uploads/images/2018-09-18/21-26-14-f1cbda65.png" alt="" title="" /></p>&#10;&#10;<p class=\"bb_p\">Тим не менш, прогрес є! За минулий рік було реалізовано велику кількість базових класів після чого проведена їх ретельна оптимізація. Це досить важливо, оскільки частина класів отримує вхідні дані й вимагає їх ретельної фільтрації, до іншої ж частини висуваються досить жорстокі вимоги до швидкості відпрацювання.</p>&#10;<p class=\"bb_p\">Також "допиляна" частина адміністративної панелі і тепер зручніше створювати публікації. Але тут з''явилась проблема - мені перестав подобатись зовнішній вигляд адміністративної панелі, а саме меню навігації.</p>&#10;&#10;<p class=\"bb_p align_center\"><img class="post_img" src="/uploads/images/2018-09-18/21-28-56-cf1f5bbf.png" alt="" title="" /></p>', 1, '2018-03-04 22:28:45.333495', '''align'':59,144 ''bb'':8,30,57,63,112,142 ''center'':60,145 ''class'':7,29,56,62,111,141 ''p'':6,9,28,31,55,58,61,64,110,113,140,143 ''авторськ'':24 ''адміністративної'':117,134 ''ал'':124 ''базов'':77 ''бул'':73 ''більшості'':21 ''важлив'':87 ''велик'':75 ''версі'':2C ''вигляд'':133 ''видав'':51 ''вимагає'':95 ''вимог'':106 ''висувают'':103 ''вихід'':26 ''вхідні'':92 ''відпрацюван'':109 ''даної'':36 ''дані'':93 ''ден'':12 ''допиля'':115 ''дос'':86,104 ''дуж'':53 ''жорстокі'':105 ''з'':15,46,126 ''займа'':39 ''зовнішні'':132 ''зручніш'':121 ''й'':94 ''класів'':78,90 ''комерційн'':23 ''кількість'':76 ''мабут'':19 ''мен'':138 ''менш'':67 ''мені'':129 ''ми'':13 ''минул'':71 ''можн'':44 ''навігації'':139 ''написан'':35 ''оновл'':1C ''оновлен'':27 ''оптимізаці'':84 ''оскільк'':88 ''отримує'':91 ''панелі'':118,135 ''пауз'':5C ''переважні'':20 ''переста'':130 ''побачит'':45 ''подобат'':131 ''притаман'':18 ''проблем'':16,128 ''провед'':81 ''прогрес'':68 ''продуктивн'':54 ''публікаці'':48 ''публікації'':37,123 ''після'':3C,79 ''реалізова'':74 ''ретельн'':83 ''ретельної'':97 ''розробк'':38 ''розробок'':25 ''рік'':50,72 ''сам'':137 ''самотужк'':41 ''стан'':32 ''створюват'':122 ''стикнул'':14 ''сьогоднішні'':11 ''також'':114 ''тепер'':120 ''тим'':65 ''тривалої'':4C ''фільтрації'':98 ''хронології'':47 ''це'':49,85 ''час'':34 ''частин'':89,102,116 ''чог'':80 ''швидкості'':108 ''що'':17 ''яв'':127 ''як'':43 ''є'':69 ''і'':42,119 ''іншої'':100 ''їх'':82,96', '', 1, 1, 0, 0);
INSERT INTO "site"."posts" ("id", "title", "alt_title", "descr", "short_post", "full_post", "author_id", "created_time", "svector", "keywords", "category", "posted", "fixed", "static") VALUES (13, 'Нова система завантажень!', 'nova_sistema_zavantazhen', '', 'В останні декілька днів завершено розробку модулів завантаження зображень/файлів до публікацій, чи... чого завгодно, система абсолютно ідентична для всіх частин сайту&#10;&#10;<img class="post_img" src="/uploads/images/2018-09-23/11-43-47-3722bee6.png" alt="" title="" />', '<p class=\"bb_p\">В останні декілька днів завершено розробку модулів завантаження зображень/файлів до публікацій, чи... чого завгодно, система абсолютно ідентична для всіх частин сайту :)</p>&#10;&#10;<p class=\"bb_p align_center\"><img class="post_img" src="/uploads/images/2018-09-18/21-47-13-e3b88107.png" alt="" title="" /></p>&#10;&#10;<p class=\"bb_p\">Варто зауважити декілька нюансів:</p>&#10;<p class=\"bb_p\">1. На перший погляд система дещо примітивна, але тут відсутні фрейми чи щось подібне... тільки сучасний AJAX і тільки ті технології, що працюють з CSP в режимі параноїка;</p>&#10;<p class=\"bb_p\">2. Всі зображення зберігаються тільки в PNG. Дослідження показали, що відмінність в розмірі між JPEG та PNG не суттєві між зображеннями до 1024px, а от в плані візуальної якості JPEG тихенько покурює десь в стороні;</p>&#10;<p class=\"bb_p\">3. Всі зображення перейменовуються в нову унікальну назву без можливості впливу на неї;</p>&#10;<p class=\"bb_p\">4. Завантажені файли (не зображення) автоматично шифруються й зберігаються в шифрованому вигляді, дешифрування здійснюється при завантаженні (приклад: [attach]e3fc5cea3153f5864423a48f617c93d0[/attach]);</p>&#10;<p class=\"bb_p\">5. Зображення додатково обробляються стороннім засобом "pngquant", що дозволяє максимально ефективно їх стискати. Ефективне стиснення зображень є досить важливою деталлю оскільки в подальшому впливає на швидкість завантаження сторінок сайту.</p>', 1, '2018-06-24 01:23:45.979602', '''/attach'':155 ''1'':48 ''1024px'':102 ''2'':80 ''3'':119 ''4'':136 ''5'':160 ''ajax'':64 ''align'':34 ''attach'':153 ''bb'':6,32,38,46,78,117,134,158 ''center'':35 ''class'':5,31,37,45,77,116,133,157 ''csp'':72 ''e3fc5cea3153f5864423a48f617c93d0'':154 ''jpeg'':94,109 ''p'':4,7,30,33,36,39,44,47,76,79,115,118,132,135,156,159 ''png'':86,96 ''pngquant'':166 ''абсолютн'':24 ''автоматичн'':141 ''ал'':55 ''важлив'':178 ''варт'':40 ''вигляді'':147 ''вплив'':129 ''впливає'':183 ''всі'':81,120 ''всіх'':27 ''відмінність'':90 ''відсутні'':57 ''візуальної'':107 ''де'':112 ''декільк'':10,42 ''деталл'':179 ''дешифруван'':148 ''дещ'':53 ''днів'':11 ''додатков'':162 ''дозволяє'':168 ''дос'':177 ''досліджен'':87 ''ефективн'':170,173 ''з'':71 ''завантажен'':3C,15,186 ''завантаженні'':151 ''завантажені'':137 ''завгодн'':22 ''заверш'':12 ''засоб'':165 ''зауважит'':41 ''зберігают'':83,144 ''здійснюєт'':149 ''зображен'':16,82,100,121,140,161,175 ''й'':143 ''максимальн'':169 ''модулів'':14 ''можливості'':128 ''між'':93,99 ''назв'':126 ''неї'':131 ''нов'':1C,124 ''нюансів'':43 ''обробляют'':163 ''оскільк'':180 ''останні'':9 ''параноїк'':75 ''перейменовуют'':122 ''перш'':50 ''плані'':106 ''погляд'':51 ''подальш'':182 ''подібн'':61 ''показа'':88 ''покурює'':111 ''працюют'':70 ''приклад'':152 ''примітивн'':54 ''публікаці'':19 ''режимі'':74 ''розмірі'':92 ''розробк'':13 ''сайт'':29,188 ''систем'':2C,23,52 ''стискат'':172 ''стиснен'':174 ''стороннім'':164 ''стороні'':114 ''сторінок'':187 ''суттєві'':98 ''сучасн'':63 ''та'':95 ''технології'':68 ''тихеньк'':110 ''ті'':67 ''тільки'':62,66,84 ''унікальн'':125 ''файл'':138 ''файлів'':17 ''фрейм'':58 ''частин'':28 ''чи'':20,59 ''чог'':21 ''швидкіст'':185 ''шифрован'':146 ''шифруют'':142 ''що'':60,69,89,167 ''якості'':108 ''є'':176 ''і'':65 ''ідентичн'':25 ''їх'':171', '', 1, 1, 0, 0);


--
-- Data for Name: posts_tags; Type: TABLE DATA; Schema: site; Owner: -
--



--
-- Data for Name: tags; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."tags" ("id", "name", "altname") VALUES (1, 'Тест', 'test');
INSERT INTO "site"."tags" ("id", "name", "altname") VALUES (2, 'Сайт', 'site');


--
-- Data for Name: user_groups; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."user_groups" ("id", "name") VALUES (0, '--');
INSERT INTO "site"."user_groups" ("id", "name") VALUES (1, 'Администратор');


--
-- Data for Name: user_ip_history; Type: TABLE DATA; Schema: site; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: site; Owner: -
--

INSERT INTO "site"."users" ("id", "login", "password", "email", "last_ip", "token", "group_id", "token_upd_time") VALUES (0, '--', '--', 'root@cmska.org', '0.0.0.0', '0', 0, '2018-09-20 13:40:23.769809');
INSERT INTO "site"."users" ("id", "login", "password", "email", "last_ip", "token", "group_id", "token_upd_time") VALUES (1, 'admin', '5729c5f66821340f23f4559243a8a2eb', 'admin@cmska.org', '192.168.2.104', 'd82b44cb11dcf377e7e2cccda1175c02', 1, '2018-10-04 12:04:19.19874');


--
-- Name: admin_menu_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."admin_menu_id_seq"', 20, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."categories_id_seq"', 6, true);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."posts_id_seq"', 13, true);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."tags_id_seq"', 2, true);


--
-- Name: user_groups_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."user_groups_id_seq"', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: site; Owner: -
--

SELECT pg_catalog.setval('"site"."users_id_seq"', 1, true);


--
-- Name: admin_menu_accesses admin_menu_accesses_item_id_group_id_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_item_id_group_id_key" UNIQUE ("item_id", "group_id");


--
-- Name: admin_menu_accesses admin_menu_accesses_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_pkey" PRIMARY KEY ("item_id", "group_id");


--
-- Name: admin_menu admin_modules_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu"
    ADD CONSTRAINT "admin_modules_pkey" PRIMARY KEY ("id");


--
-- Name: categories categories_altname_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."categories"
    ADD CONSTRAINT "categories_altname_key" UNIQUE ("altname");


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."images"
    ADD CONSTRAINT "images_pkey" PRIMARY KEY ("md5");


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts"
    ADD CONSTRAINT "posts_pkey" PRIMARY KEY ("id");


--
-- Name: posts_tags posts_tags_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts_tags"
    ADD CONSTRAINT "posts_tags_pkey" PRIMARY KEY ("post_id", "tag_id");


--
-- Name: posts_tags posts_tags_post_id_tag_id_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts_tags"
    ADD CONSTRAINT "posts_tags_post_id_tag_id_key" UNIQUE ("post_id", "tag_id");


--
-- Name: tags tags_altname_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."tags"
    ADD CONSTRAINT "tags_altname_key" UNIQUE ("altname");


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."tags"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."user_groups"
    ADD CONSTRAINT "user_groups_pkey" PRIMARY KEY ("id");


--
-- Name: user_ip_history user_ip_history_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."user_ip_history"
    ADD CONSTRAINT "user_ip_history_pkey" PRIMARY KEY ("user_id");


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");


--
-- Name: users users_login_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_login_key" UNIQUE ("login");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: users users_token_key; Type: CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_token_key" UNIQUE ("token");


--
-- Name: admin_menu admin_moduled_upd_ptree_after; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "admin_moduled_upd_ptree_after" AFTER INSERT OR DELETE OR UPDATE OF "id", "parent_id", "ptree", "level" ON "site"."admin_menu" FOR EACH ROW EXECUTE PROCEDURE "site"."GEN_PTREE_MULTILIST_AFTER"();


--
-- Name: admin_menu admin_moduled_upd_ptree_before; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "admin_moduled_upd_ptree_before" BEFORE INSERT OR UPDATE OF "id", "parent_id", "ptree", "level" ON "site"."admin_menu" FOR EACH ROW EXECUTE PROCEDURE "site"."GEN_PTREE_MULTILIS_BEFORE"();


--
-- Name: posts before_ins_upd_posts; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "before_ins_upd_posts" BEFORE INSERT OR UPDATE OF "title", "descr", "full_post", "keywords" ON "site"."posts" FOR EACH ROW EXECUTE PROCEDURE "site"."before_ins_upd_posts"();


--
-- Name: categories categories_after_any; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "categories_after_any" AFTER INSERT OR DELETE OR UPDATE OF "id", "parent_id", "ptree", "level" ON "site"."categories" FOR EACH ROW EXECUTE PROCEDURE "site"."GEN_PTREE_MULTILIST_AFTER"();


--
-- Name: categories categories_before_ins_upd; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "categories_before_ins_upd" BEFORE INSERT OR UPDATE OF "id", "parent_id", "ptree", "level" ON "site"."categories" FOR EACH ROW EXECUTE PROCEDURE "site"."GEN_PTREE_MULTILIS_BEFORE"();


--
-- Name: users upd_token_time; Type: TRIGGER; Schema: site; Owner: -
--

CREATE TRIGGER "upd_token_time" BEFORE INSERT OR UPDATE OF "token", "last_ip" ON "site"."users" FOR EACH ROW EXECUTE PROCEDURE "site"."upd_token_time"();


--
-- Name: admin_menu_accesses admin_menu_accesses_group_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "site"."user_groups"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_menu_accesses admin_menu_accesses_item_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."admin_menu_accesses"
    ADD CONSTRAINT "admin_menu_accesses_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "site"."admin_menu"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: files files_post_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."files"
    ADD CONSTRAINT "files_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "site"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: files files_user_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."files"
    ADD CONSTRAINT "files_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "site"."users"("id") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: images images_post_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."images"
    ADD CONSTRAINT "images_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "site"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: images images_user_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."images"
    ADD CONSTRAINT "images_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "site"."users"("id") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: posts posts_author_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts"
    ADD CONSTRAINT "posts_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "site"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts posts_category_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts"
    ADD CONSTRAINT "posts_category_fkey" FOREIGN KEY ("category") REFERENCES "site"."categories"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_tags posts_tags_post_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts_tags"
    ADD CONSTRAINT "posts_tags_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "site"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts_tags posts_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."posts_tags"
    ADD CONSTRAINT "posts_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "site"."tags"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_ip_history user_ip_history_user_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."user_ip_history"
    ADD CONSTRAINT "user_ip_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "site"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_group_id_fkey; Type: FK CONSTRAINT; Schema: site; Owner: -
--

ALTER TABLE ONLY "site"."users"
    ADD CONSTRAINT "users_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "site"."user_groups"("id") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- PostgreSQL database dump complete
--

