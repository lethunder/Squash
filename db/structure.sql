--
-- PostgreSQL database dump
--

-- Dumped from database version 10.17 (Ubuntu 10.17-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.17 (Ubuntu 10.17-0ubuntu0.18.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: bugs_calculate_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_calculate_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET number = (SELECT COALESCE(MAX(number), 0)+1 FROM bugs oc WHERE oc.environment_id = NEW.environment_id)
                  WHERE id = NEW.id;
                RETURN NEW;
              END;
            $$;


--
-- Name: bugs_decrement_comments_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_decrement_comments_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET comments_count = comments_count - 1
                  WHERE id = OLD.bug_id;
                RETURN OLD;
              END;
            $$;


--
-- Name: bugs_decrement_events_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_decrement_events_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET events_count = events_count - 1
                  WHERE id = OLD.bug_id;
                RETURN OLD;
              END;
            $$;


--
-- Name: bugs_decrement_occurrences_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_decrement_occurrences_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET occurrences_count = occurrences_count - 1
                  WHERE id = OLD.bug_id;
                RETURN OLD;
              END;
            $$;


--
-- Name: bugs_increment_comments_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_increment_comments_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET comments_count = comments_count + 1
                  WHERE id = NEW.bug_id;
                RETURN NEW;
              END;
            $$;


--
-- Name: bugs_increment_events_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_increment_events_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET events_count = events_count + 1
                  WHERE id = NEW.bug_id;
                RETURN NEW;
              END;
            $$;


--
-- Name: bugs_increment_occurrences_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_increment_occurrences_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET occurrences_count = occurrences_count + 1
                  WHERE id = NEW.bug_id;
                RETURN NEW;
              END;
            $$;


--
-- Name: bugs_move_comments_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_move_comments_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET comments_count = comments_count - 1
                  WHERE id = OLD.bug_id;
                UPDATE bugs
                  SET comments_count = comments_count + 1
                  WHERE id = NEW.bug_id;
                RETURN NEW;
              END;
            $$;


--
-- Name: bugs_move_events_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_move_events_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET events_count = events_count - 1
                  WHERE id = OLD.bug_id;
                UPDATE bugs
                  SET events_count = events_count + 1
                  WHERE id = NEW.bug_id;
                RETURN NEW;
              END;
            $$;


--
-- Name: bugs_move_occurrences_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_move_occurrences_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE bugs
                  SET occurrences_count = occurrences_count - 1
                  WHERE id = OLD.bug_id;
                UPDATE bugs
                  SET occurrences_count = occurrences_count + 1
                  WHERE id = NEW.bug_id;
                RETURN NEW;
              END;
            $$;


--
-- Name: bugs_new_crashed_occurrence(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_new_crashed_occurrence() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            UPDATE bugs
              SET any_occurrence_crashed = EXISTS(
                SELECT 1
                  FROM occurrences o
                  WHERE
                    o.bug_id = NEW.bug_id AND
                    o.crashed IS TRUE
              )
              WHERE id = NEW.bug_id;
            RETURN NEW;
          END;
        $$;


--
-- Name: bugs_old_crashed_occurrence(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bugs_old_crashed_occurrence() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            UPDATE bugs
              SET any_occurrence_crashed = EXISTS(
                SELECT 1
                  FROM occurrences o
                  WHERE
                    o.bug_id = OLD.bug_id AND
                    o.crashed IS TRUE
              )
              WHERE id = OLD.bug_id;
            RETURN OLD;
          END;
        $$;


--
-- Name: comments_calculate_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.comments_calculate_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE comments
                  SET number = (SELECT COALESCE(MAX(number), 0)+1 FROM comments cc WHERE cc.bug_id = NEW.bug_id)
                  WHERE id = NEW.id;
                RETURN NEW;
              END;
            $$;


--
-- Name: environments_change_bugs_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.environments_change_bugs_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                BEGIN
                  UPDATE environments
                    SET bugs_count = (
                      CASE WHEN NEW.fixed IS NOT TRUE AND NEW.irrelevant IS NOT TRUE
                        THEN bugs_count + 1
                        ELSE bugs_count - 1
                      END)
                    WHERE id = OLD.environment_id;
                  RETURN NEW;
                END;
              $$;


--
-- Name: environments_decrement_bugs_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.environments_decrement_bugs_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE environments
                  SET bugs_count = bugs_count - 1
                  WHERE id = OLD.environment_id;
                RETURN OLD;
              END;
            $$;


--
-- Name: environments_increment_bugs_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.environments_increment_bugs_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE environments
                  SET bugs_count = bugs_count + 1
                  WHERE id = NEW.environment_id;
                RETURN NEW;
              END;
            $$;


--
-- Name: environments_move_bugs_count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.environments_move_bugs_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE environments
                  SET bugs_count = bugs_count - (
                    CASE
                      WHEN (OLD.fixed IS NOT TRUE AND OLD.irrelevant IS NOT TRUE)
                      THEN 1
                      ELSE 0
                    END)
                  WHERE id = OLD.environment_id;
                UPDATE environments
                  SET bugs_count = bugs_count + (
                    CASE
                      WHEN (NEW.fixed IS NOT TRUE AND NEW.irrelevant IS NOT TRUE)
                      THEN 1
                      ELSE 0
                    END)
                  WHERE id = NEW.environment_id;
                RETURN NEW;
              END;
            $$;


--
-- Name: notify_bug_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_bug_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              DECLARE
                occurrences_changed CHARACTER VARYING(5);
                comments_changed CHARACTER VARYING(5);
                events_changed CHARACTER VARYING(5);
              BEGIN
                occurrences_changed := (CASE WHEN OLD.occurrences_count IS DISTINCT FROM NEW.occurrences_count THEN 'TRUE' ELSE 'FALSE' END);
                comments_changed    := (CASE WHEN OLD.comments_count    IS DISTINCT FROM NEW.comments_count    THEN 'TRUE' ELSE 'FALSE' END);
                events_changed      := (CASE WHEN OLD.events_count      IS DISTINCT FROM NEW.events_count      THEN 'TRUE' ELSE 'FALSE' END);
                PERFORM pg_notify('ws_env_' || NEW.environment_id, '{"table":"' || TG_TABLE_NAME || '","id":' || NEW.id || ',"occurrences_count_changed":' || occurrences_changed || ',"comments_count_changed":' || comments_changed || ',"events_count_changed":' || events_changed || '}');
                RETURN NEW;
              END;
            $$;


--
-- Name: notify_env_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_env_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              DECLARE
                bugs_changed CHARACTER VARYING(5);
              BEGIN
                bugs_changed := (CASE WHEN OLD.bugs_count IS DISTINCT FROM NEW.bugs_count THEN 'TRUE' ELSE 'FALSE' END);
                PERFORM pg_notify('ws_proj_' || NEW.project_id, '{"table":"' || TG_TABLE_NAME || '","id":' || NEW.id || ',"bugs_count_changed":' || bugs_changed || '}');
                RETURN NEW;
              END;
            $$;


--
-- Name: occurrences_calculate_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.occurrences_calculate_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
              BEGIN
                UPDATE occurrences
                  SET number = (SELECT COALESCE(MAX(number), 0)+1 FROM occurrences oc WHERE oc.bug_id = NEW.bug_id)
                  WHERE id = NEW.id;
                RETURN NEW;
              END;
            $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: blames; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.blames (
    id integer NOT NULL,
    repository_hash character(40) NOT NULL,
    revision character(40) NOT NULL,
    file character varying(255) NOT NULL,
    line integer NOT NULL,
    blamed_revision character varying(40) NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT blames_file_check CHECK ((char_length((file)::text) > 0)),
    CONSTRAINT blames_line_check CHECK ((line > 0))
);


--
-- Name: blames_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blames_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blames_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blames_id_seq OWNED BY public.blames.id;


--
-- Name: bugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bugs (
    id integer NOT NULL,
    assigned_user_id integer,
    blamed_revision character(40),
    class_name character varying(128) NOT NULL,
    client character varying(32) NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    deploy_id integer,
    duplicate_of_id integer,
    environment_id integer NOT NULL,
    events_count integer DEFAULT 0 NOT NULL,
    file character varying(255) NOT NULL,
    first_occurrence timestamp without time zone,
    fixed boolean DEFAULT false NOT NULL,
    fix_deployed boolean DEFAULT false NOT NULL,
    irrelevant boolean DEFAULT false NOT NULL,
    latest_occurrence timestamp without time zone,
    line integer NOT NULL,
    metadata text,
    number integer,
    occurrences_count integer DEFAULT 0 NOT NULL,
    resolution_revision character(40),
    revision character(40) NOT NULL,
    searchable_text tsvector,
    any_occurrence_crashed boolean DEFAULT false NOT NULL,
    CONSTRAINT bugs_check CHECK ((((fix_deployed IS TRUE) AND (fixed IS TRUE)) OR (fix_deployed IS FALSE))),
    CONSTRAINT bugs_class_name_check CHECK ((char_length((class_name)::text) > 0)),
    CONSTRAINT bugs_comments_count_check CHECK ((comments_count >= 0)),
    CONSTRAINT bugs_events_count_check CHECK ((events_count >= 0)),
    CONSTRAINT bugs_file_check CHECK ((char_length((file)::text) > 0)),
    CONSTRAINT bugs_line_check CHECK ((line > 0)),
    CONSTRAINT bugs_number_check CHECK ((number > 0)),
    CONSTRAINT bugs_occurrences_count_check CHECK ((occurrences_count >= 0))
);


--
-- Name: bugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bugs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bugs_id_seq OWNED BY public.bugs.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    bug_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    metadata text,
    number integer,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    CONSTRAINT comments_number_check CHECK ((number > 0))
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: deploys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploys (
    id integer NOT NULL,
    build character varying(40),
    deployed_at timestamp without time zone NOT NULL,
    environment_id integer NOT NULL,
    hostname character varying(126),
    revision character(40) NOT NULL,
    version character varying(126)
);


--
-- Name: deploys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deploys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deploys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deploys_id_seq OWNED BY public.deploys.id;


--
-- Name: device_bugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_bugs (
    bug_id integer NOT NULL,
    device_id character varying(126) NOT NULL
);


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
    id integer NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    email character varying(255) NOT NULL,
    project_id integer,
    user_id integer NOT NULL
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;


--
-- Name: environments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.environments (
    id integer NOT NULL,
    bugs_count integer DEFAULT 0 NOT NULL,
    name character varying(100) NOT NULL,
    project_id integer NOT NULL,
    metadata text,
    CONSTRAINT environments_bugs_count_check CHECK ((bugs_count >= 0)),
    CONSTRAINT environments_name_check CHECK ((char_length((name)::text) > 0))
);


--
-- Name: environments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.environments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: environments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.environments_id_seq OWNED BY public.environments.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id integer NOT NULL,
    bug_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    data text,
    kind character varying(32) NOT NULL,
    user_id integer
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    metadata text
);


--
-- Name: notification_thresholds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_thresholds (
    bug_id integer NOT NULL,
    user_id integer NOT NULL,
    last_tripped_at timestamp without time zone,
    period integer NOT NULL,
    threshold integer NOT NULL,
    CONSTRAINT notification_thresholds_period_check CHECK ((period > 0)),
    CONSTRAINT notification_thresholds_threshold_check CHECK ((threshold > 0))
);


--
-- Name: obfuscation_maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.obfuscation_maps (
    id integer NOT NULL,
    deploy_id integer NOT NULL,
    namespace text
);


--
-- Name: obfuscation_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.obfuscation_maps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: obfuscation_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.obfuscation_maps_id_seq OWNED BY public.obfuscation_maps.id;


--
-- Name: occurrences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.occurrences (
    id integer NOT NULL,
    bug_id integer NOT NULL,
    client character varying(32) NOT NULL,
    metadata text,
    number integer,
    occurred_at timestamp without time zone NOT NULL,
    redirect_target_id integer,
    revision character(40) NOT NULL,
    symbolication_id uuid,
    crashed boolean DEFAULT false NOT NULL,
    CONSTRAINT occurrences_number_check CHECK ((number > 0))
);


--
-- Name: occurrences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.occurrences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: occurrences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.occurrences_id_seq OWNED BY public.occurrences.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    api_key character(36) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    default_environment_id integer,
    metadata text,
    name character varying(126) NOT NULL,
    owner_id integer NOT NULL,
    repository_url character varying(255) NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT projects_name_check CHECK ((char_length((name)::text) > 0))
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slugs (
    id integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    scope character varying(126),
    slug character varying(126) NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(32) NOT NULL,
    CONSTRAINT slugs_slug_check CHECK ((char_length((slug)::text) > 0))
);


--
-- Name: slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slugs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slugs_id_seq OWNED BY public.slugs.id;


--
-- Name: source_maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_maps (
    id integer NOT NULL,
    environment_id integer NOT NULL,
    map text,
    revision character(40) NOT NULL,
    "from" character varying(24) DEFAULT 'minified'::character varying,
    "to" character varying(24) DEFAULT 'original'::character varying,
    filename character varying(255) NOT NULL,
    CONSTRAINT source_maps_from_check CHECK ((char_length(("from")::text) > 0)),
    CONSTRAINT source_maps_to_check CHECK ((char_length(("to")::text) > 0))
);


--
-- Name: source_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.source_maps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: source_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.source_maps_id_seq OWNED BY public.source_maps.id;


--
-- Name: symbolications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.symbolications (
    uuid uuid NOT NULL,
    lines text,
    symbols text
);


--
-- Name: user_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_events (
    event_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    metadata text,
    updated_at timestamp without time zone NOT NULL,
    username character varying(50) NOT NULL,
    CONSTRAINT users_username_check CHECK ((char_length((username)::text) > 0))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: watches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.watches (
    bug_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: blames id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blames ALTER COLUMN id SET DEFAULT nextval('public.blames_id_seq'::regclass);


--
-- Name: bugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bugs ALTER COLUMN id SET DEFAULT nextval('public.bugs_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: deploys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deploys ALTER COLUMN id SET DEFAULT nextval('public.deploys_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);


--
-- Name: environments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.environments ALTER COLUMN id SET DEFAULT nextval('public.environments_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: obfuscation_maps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obfuscation_maps ALTER COLUMN id SET DEFAULT nextval('public.obfuscation_maps_id_seq'::regclass);


--
-- Name: occurrences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.occurrences ALTER COLUMN id SET DEFAULT nextval('public.occurrences_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slugs ALTER COLUMN id SET DEFAULT nextval('public.slugs_id_seq'::regclass);


--
-- Name: source_maps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_maps ALTER COLUMN id SET DEFAULT nextval('public.source_maps_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: blames blames_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blames
    ADD CONSTRAINT blames_pkey PRIMARY KEY (id);


--
-- Name: bugs bugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bugs
    ADD CONSTRAINT bugs_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: deploys deploys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deploys
    ADD CONSTRAINT deploys_pkey PRIMARY KEY (id);


--
-- Name: device_bugs device_bugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_bugs
    ADD CONSTRAINT device_bugs_pkey PRIMARY KEY (bug_id, device_id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: environments environments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (project_id, user_id);


--
-- Name: notification_thresholds notification_thresholds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_thresholds
    ADD CONSTRAINT notification_thresholds_pkey PRIMARY KEY (bug_id, user_id);


--
-- Name: obfuscation_maps obfuscation_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obfuscation_maps
    ADD CONSTRAINT obfuscation_maps_pkey PRIMARY KEY (id);


--
-- Name: occurrences occurrences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.occurrences
    ADD CONSTRAINT occurrences_pkey PRIMARY KEY (id);


--
-- Name: projects projects_api_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_api_key_key UNIQUE (api_key);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: slugs slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slugs
    ADD CONSTRAINT slugs_pkey PRIMARY KEY (id);


--
-- Name: source_maps source_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_maps
    ADD CONSTRAINT source_maps_pkey PRIMARY KEY (id);


--
-- Name: symbolications symbolications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.symbolications
    ADD CONSTRAINT symbolications_pkey PRIMARY KEY (uuid);


--
-- Name: user_events user_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_pkey PRIMARY KEY (event_id, user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: watches watches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watches
    ADD CONSTRAINT watches_pkey PRIMARY KEY (bug_id, user_id);


--
-- Name: blames_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX blames_key ON public.blames USING btree (repository_hash, revision, file, line);


--
-- Name: blames_lru; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX blames_lru ON public.blames USING btree (updated_at);


--
-- Name: bugs_env_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX bugs_env_number ON public.bugs USING btree (environment_id, number);


--
-- Name: bugs_env_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_env_user ON public.bugs USING btree (environment_id, assigned_user_id, fixed, irrelevant);


--
-- Name: bugs_environment_textsearch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_environment_textsearch ON public.bugs USING gin (searchable_text);


--
-- Name: bugs_find_for_occ1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_find_for_occ1 ON public.bugs USING btree (environment_id, class_name, file, line, blamed_revision, deploy_id);


--
-- Name: bugs_find_for_occ2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_find_for_occ2 ON public.bugs USING btree (environment_id, class_name, file, line, blamed_revision, fixed);


--
-- Name: bugs_fixed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_fixed ON public.bugs USING btree (fixed);


--
-- Name: bugs_list_fo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_list_fo ON public.bugs USING btree (environment_id, deploy_id, assigned_user_id, fixed, irrelevant, any_occurrence_crashed, first_occurrence, number);


--
-- Name: bugs_list_lo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_list_lo ON public.bugs USING btree (environment_id, deploy_id, assigned_user_id, fixed, irrelevant, any_occurrence_crashed, latest_occurrence, number);


--
-- Name: bugs_list_oc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_list_oc ON public.bugs USING btree (environment_id, deploy_id, assigned_user_id, fixed, irrelevant, any_occurrence_crashed, occurrences_count, number);


--
-- Name: bugs_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_user ON public.bugs USING btree (assigned_user_id, fixed, irrelevant);


--
-- Name: bugs_user_recency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bugs_user_recency ON public.bugs USING btree (assigned_user_id, latest_occurrence, number);


--
-- Name: comments_bug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_bug ON public.comments USING btree (bug_id, created_at);


--
-- Name: comments_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX comments_number ON public.comments USING btree (bug_id, number);


--
-- Name: deploys_env_build; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX deploys_env_build ON public.deploys USING btree (environment_id, build);


--
-- Name: deploys_env_revision; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX deploys_env_revision ON public.deploys USING btree (environment_id, revision, deployed_at);


--
-- Name: deploys_env_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX deploys_env_time ON public.deploys USING btree (environment_id, deployed_at);


--
-- Name: emails_email_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX emails_email_user ON public.emails USING btree (lower((email)::text), project_id, user_id);


--
-- Name: emails_primary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX emails_primary ON public.emails USING btree (user_id, "primary");


--
-- Name: environments_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX environments_name ON public.environments USING btree (project_id, lower((name)::text));


--
-- Name: events_bug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_bug ON public.events USING btree (bug_id, created_at);


--
-- Name: index_source_maps_on_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_source_maps_on_filename ON public.source_maps USING btree (filename);


--
-- Name: occurrences_bug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX occurrences_bug ON public.occurrences USING btree (bug_id, occurred_at);


--
-- Name: occurrences_bug_redirect; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX occurrences_bug_redirect ON public.occurrences USING btree (bug_id, redirect_target_id);


--
-- Name: occurrences_bug_revision; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX occurrences_bug_revision ON public.occurrences USING btree (bug_id, revision, occurred_at);


--
-- Name: occurrences_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX occurrences_number ON public.occurrences USING btree (bug_id, number);


--
-- Name: projects_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_name ON public.projects USING btree (lower((name)::text) text_pattern_ops);


--
-- Name: projects_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_owner ON public.projects USING btree (owner_id);


--
-- Name: slugs_for_record; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX slugs_for_record ON public.slugs USING btree (sluggable_type, sluggable_id, active);


--
-- Name: slugs_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX slugs_unique ON public.slugs USING btree (sluggable_type, lower((scope)::text), lower((slug)::text));


--
-- Name: source_maps_env_revision; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX source_maps_env_revision ON public.source_maps USING btree (environment_id, revision, "from");


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: user_events_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_events_time ON public.user_events USING btree (event_id, created_at);


--
-- Name: users_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_username ON public.users USING btree (lower((username)::text) text_pattern_ops);


--
-- Name: occurrences occurrences_set_first; Type: RULE; Schema: public; Owner: -
--

CREATE RULE occurrences_set_first AS
    ON INSERT TO public.occurrences DO  UPDATE public.bugs SET first_occurrence = new.occurred_at
  WHERE ((bugs.id = new.bug_id) AND (bugs.first_occurrence IS NULL));


--
-- Name: occurrences occurrences_set_latest; Type: RULE; Schema: public; Owner: -
--

CREATE RULE occurrences_set_latest AS
    ON INSERT TO public.occurrences DO  UPDATE public.bugs SET latest_occurrence = new.occurred_at
  WHERE ((bugs.id = new.bug_id) AND ((bugs.latest_occurrence IS NULL) OR (bugs.latest_occurrence < new.occurred_at)));


--
-- Name: comments bugs_comments_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_comments_delete AFTER DELETE ON public.comments FOR EACH ROW EXECUTE PROCEDURE public.bugs_decrement_comments_count();


--
-- Name: comments bugs_comments_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_comments_insert AFTER INSERT ON public.comments FOR EACH ROW EXECUTE PROCEDURE public.bugs_increment_comments_count();


--
-- Name: comments bugs_comments_move; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_comments_move AFTER UPDATE ON public.comments FOR EACH ROW WHEN ((old.bug_id <> new.bug_id)) EXECUTE PROCEDURE public.bugs_move_comments_count();


--
-- Name: events bugs_events_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_events_delete AFTER DELETE ON public.events FOR EACH ROW EXECUTE PROCEDURE public.bugs_decrement_events_count();


--
-- Name: events bugs_events_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_events_insert AFTER INSERT ON public.events FOR EACH ROW EXECUTE PROCEDURE public.bugs_increment_events_count();


--
-- Name: events bugs_events_move; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_events_move AFTER UPDATE ON public.events FOR EACH ROW WHEN ((old.bug_id <> new.bug_id)) EXECUTE PROCEDURE public.bugs_move_events_count();


--
-- Name: bugs bugs_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_notify AFTER UPDATE ON public.bugs FOR EACH ROW WHEN (((old.occurrences_count IS DISTINCT FROM new.occurrences_count) OR (old.comments_count IS DISTINCT FROM new.comments_count) OR (old.events_count IS DISTINCT FROM new.events_count))) EXECUTE PROCEDURE public.notify_bug_update();


--
-- Name: occurrences bugs_occurrences_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_occurrences_delete AFTER DELETE ON public.occurrences FOR EACH ROW EXECUTE PROCEDURE public.bugs_decrement_occurrences_count();


--
-- Name: occurrences bugs_occurrences_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_occurrences_insert AFTER INSERT ON public.occurrences FOR EACH ROW EXECUTE PROCEDURE public.bugs_increment_occurrences_count();


--
-- Name: occurrences bugs_occurrences_move; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_occurrences_move AFTER UPDATE ON public.occurrences FOR EACH ROW WHEN ((old.bug_id <> new.bug_id)) EXECUTE PROCEDURE public.bugs_move_occurrences_count();


--
-- Name: bugs bugs_set_number; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bugs_set_number AFTER INSERT ON public.bugs FOR EACH ROW EXECUTE PROCEDURE public.bugs_calculate_number();


--
-- Name: comments comments_set_number; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER comments_set_number AFTER INSERT ON public.comments FOR EACH ROW EXECUTE PROCEDURE public.comments_calculate_number();


--
-- Name: bugs environments_bugs_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER environments_bugs_delete AFTER DELETE ON public.bugs FOR EACH ROW WHEN (((old.fixed IS NOT TRUE) AND (old.irrelevant IS NOT TRUE))) EXECUTE PROCEDURE public.environments_decrement_bugs_count();


--
-- Name: bugs environments_bugs_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER environments_bugs_insert AFTER INSERT ON public.bugs FOR EACH ROW WHEN (((new.fixed IS NOT TRUE) AND (new.irrelevant IS NOT TRUE))) EXECUTE PROCEDURE public.environments_increment_bugs_count();


--
-- Name: bugs environments_bugs_move; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER environments_bugs_move AFTER UPDATE ON public.bugs FOR EACH ROW WHEN ((old.environment_id <> new.environment_id)) EXECUTE PROCEDURE public.environments_move_bugs_count();


--
-- Name: bugs environments_bugs_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER environments_bugs_update AFTER UPDATE ON public.bugs FOR EACH ROW WHEN (((old.environment_id = new.environment_id) AND (((old.fixed IS NOT TRUE) AND (old.irrelevant IS NOT TRUE) AND (NOT ((new.fixed IS NOT TRUE) AND (new.irrelevant IS NOT TRUE)))) OR ((new.fixed IS NOT TRUE) AND (new.irrelevant IS NOT TRUE) AND (NOT ((old.fixed IS NOT TRUE) AND (old.irrelevant IS NOT TRUE))))))) EXECUTE PROCEDURE public.environments_change_bugs_count();


--
-- Name: environments environments_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER environments_notify AFTER UPDATE ON public.environments FOR EACH ROW WHEN ((old.bugs_count IS DISTINCT FROM new.bugs_count)) EXECUTE PROCEDURE public.notify_env_update();


--
-- Name: occurrences occurrences_crashed_bug_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER occurrences_crashed_bug_deleted AFTER DELETE ON public.occurrences FOR EACH ROW EXECUTE PROCEDURE public.bugs_old_crashed_occurrence();


--
-- Name: occurrences occurrences_crashed_bug_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER occurrences_crashed_bug_updated AFTER INSERT OR UPDATE ON public.occurrences FOR EACH ROW EXECUTE PROCEDURE public.bugs_new_crashed_occurrence();


--
-- Name: occurrences occurrences_set_number; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER occurrences_set_number AFTER INSERT ON public.occurrences FOR EACH ROW EXECUTE PROCEDURE public.occurrences_calculate_number();


--
-- Name: bugs bugs_assigned_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bugs
    ADD CONSTRAINT bugs_assigned_user_id_fkey FOREIGN KEY (assigned_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: bugs bugs_deploy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bugs
    ADD CONSTRAINT bugs_deploy_id_fkey FOREIGN KEY (deploy_id) REFERENCES public.deploys(id) ON DELETE SET NULL;


--
-- Name: bugs bugs_duplicate_of_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bugs
    ADD CONSTRAINT bugs_duplicate_of_id_fkey FOREIGN KEY (duplicate_of_id) REFERENCES public.bugs(id) ON DELETE CASCADE;


--
-- Name: bugs bugs_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bugs
    ADD CONSTRAINT bugs_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environments(id) ON DELETE CASCADE;


--
-- Name: comments comments_bug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_bug_id_fkey FOREIGN KEY (bug_id) REFERENCES public.bugs(id) ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: deploys deploys_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deploys
    ADD CONSTRAINT deploys_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environments(id) ON DELETE CASCADE;


--
-- Name: device_bugs device_bugs_bug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_bugs
    ADD CONSTRAINT device_bugs_bug_id_fkey FOREIGN KEY (bug_id) REFERENCES public.bugs(id) ON DELETE CASCADE;


--
-- Name: emails emails_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: emails emails_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: environments environments_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: events events_bug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_bug_id_fkey FOREIGN KEY (bug_id) REFERENCES public.bugs(id) ON DELETE CASCADE;


--
-- Name: events events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: memberships memberships_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: memberships memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notification_thresholds notification_thresholds_bug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_thresholds
    ADD CONSTRAINT notification_thresholds_bug_id_fkey FOREIGN KEY (bug_id) REFERENCES public.bugs(id) ON DELETE CASCADE;


--
-- Name: notification_thresholds notification_thresholds_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_thresholds
    ADD CONSTRAINT notification_thresholds_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: obfuscation_maps obfuscation_maps_deploy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obfuscation_maps
    ADD CONSTRAINT obfuscation_maps_deploy_id_fkey FOREIGN KEY (deploy_id) REFERENCES public.deploys(id) ON DELETE CASCADE;


--
-- Name: occurrences occurrences_bug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.occurrences
    ADD CONSTRAINT occurrences_bug_id_fkey FOREIGN KEY (bug_id) REFERENCES public.bugs(id) ON DELETE CASCADE;


--
-- Name: occurrences occurrences_redirect_target_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.occurrences
    ADD CONSTRAINT occurrences_redirect_target_id_fkey FOREIGN KEY (redirect_target_id) REFERENCES public.occurrences(id) ON DELETE CASCADE;


--
-- Name: projects projects_default_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_default_environment_id_fkey FOREIGN KEY (default_environment_id) REFERENCES public.environments(id) ON DELETE SET NULL;


--
-- Name: projects projects_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: source_maps source_maps_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_maps
    ADD CONSTRAINT source_maps_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environments(id) ON DELETE CASCADE;


--
-- Name: user_events user_events_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: user_events user_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: watches watches_bug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watches
    ADD CONSTRAINT watches_bug_id_fkey FOREIGN KEY (bug_id) REFERENCES public.bugs(id) ON DELETE CASCADE;


--
-- Name: watches watches_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watches
    ADD CONSTRAINT watches_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('20130125021927');

INSERT INTO schema_migrations (version) VALUES ('20130131002457');

INSERT INTO schema_migrations (version) VALUES ('20130131002503');

INSERT INTO schema_migrations (version) VALUES ('20130215185809');

INSERT INTO schema_migrations (version) VALUES ('20130221020818');

INSERT INTO schema_migrations (version) VALUES ('20130222055524');

INSERT INTO schema_migrations (version) VALUES ('20140130012355');

INSERT INTO schema_migrations (version) VALUES ('20151126022941');

