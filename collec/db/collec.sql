--
-- WRITE by Christine Plumejeaud
-- initialize IRSTEA/collec database
-- 
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.6
-- Dumped by pg_dump version 9.5.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: gacl; Type: SCHEMA; Schema: -; Owner: collec
--

CREATE SCHEMA gacl;


ALTER SCHEMA gacl OWNER TO collec;

--
-- Name: zaalpes; Type: SCHEMA; Schema: -; Owner: collec
--

CREATE SCHEMA zaalpes;


ALTER SCHEMA zaalpes OWNER TO collec;

SET search_path = gacl, pg_catalog;

--
-- Name: create_groups(character varying, character varying); Type: FUNCTION; Schema: gacl; Owner: collec
--

CREATE FUNCTION create_groups(gacl_schema character varying, appli_name character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	appli_id INTEGER :=-1;
	aco_id INTEGER;
	group_id INTEGER;

	test VARCHAR;
	appli_table VARCHAR := gacl_schema||'.'||'aclappli';
	aco_table VARCHAR := gacl_schema||'.'||'aclaco';
	group_table VARCHAR := gacl_schema||'.'||'aclgroup';
	aco_group_table VARCHAR := gacl_schema||'.'||'aclacl';
	login_group_table VARCHAR := gacl_schema||'.'||'acllogingroup';
BEGIN
	-- Find the unique id of the appli in the schema gacl
	EXECUTE 'SELECT aclappli_id FROM '||appli_table||' where appli = '''||appli_name||''' ' INTO appli_id;
	-- raise notice 'Mon identifiant appli %', appli_id;

	IF appli_id is NULL THEN
	        BEGIN
			    RAISE NOTICE 'Insert application % into  %', appli_name, gacl_schema;
				EXECUTE 'INSERT  into '||appli_table||' (appli) values ('''||appli_name ||''')';
			EXCEPTION
				WHEN OTHERS THEN
					RAISE NOTICE 'Error during create_groups on insert application: % / %.', SQLERRM, SQLSTATE;
					RETURN -1;
			END;
	END IF;

	EXECUTE 'SELECT aclappli_id FROM '||appli_table||' where appli = '''||appli_name||''' ' INTO appli_id;
	raise notice 'Mon identifiant appli %', appli_id;

	-- First, insert new corresponding rights for this application (values are invariant, hardcoded in PHP code)
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''admin'');';
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''param'');';
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''projet'');';
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''gestion'');';
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''consult'');';


	-- Second, insert new groups for this application (values are free, but coded in a readable manner for this code)
	-- test := 'insert into '||group_table||'  (groupe) values ( ''param_group'');';
	--raise notice 'insert GROUP %', test;
	EXECUTE 'insert into '||group_table||'  (groupe) values ( ''admin_group'');';
	EXECUTE 'insert into '||group_table||'  (groupe) values ( ''param_group'');';
	EXECUTE 'insert into '||group_table||'  (groupe) values ( ''projet_group'');';
	EXECUTE 'insert into '||group_table||'  (groupe) values ( ''gestion_group'');';
	EXECUTE 'insert into '||group_table||'  (groupe) values ( ''consult_group'');';

	-- Third associate those group to their corresponding rights

	-- Associate the right ''admin'' with the admin_group
    EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''admin'' ' INTO aco_id ;
    EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''admin_group'' ' INTO group_id ;
    EXECUTE 'insert into '||aco_group_table||' (aclaco_id, aclgroup_id) values ('||aco_id||','||group_id||') ;';

	-- Associate the right ''param'' with the param_group
    EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''param'' ' INTO aco_id ;
    EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''param_group'' ' INTO group_id ;
    EXECUTE 'insert into '||aco_group_table||' (aclaco_id, aclgroup_id) values ('||aco_id||','||group_id||') ;';

    --  Associate the right ''projet'' with the projet_group
    EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''projet'' ' INTO aco_id ;
    EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''projet_group'' ' INTO group_id ;
    EXECUTE 'insert into '||aco_group_table||' (aclaco_id, aclgroup_id) values ('||aco_id||','||group_id||') ;';

    -- Associate  the right ''gestion'' with the gestion_group
    EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''gestion'' ' INTO aco_id ;
    EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''gestion_group'' ' INTO group_id ;
    EXECUTE 'insert into '||aco_group_table||' (aclaco_id, aclgroup_id) values ('||aco_id||','||group_id||') ;';

    --  Associate the right ''consult'' with the consult_group
    EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''consult'' ' INTO aco_id ;
    EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''consult_group'' ' INTO group_id ;
    EXECUTE 'insert into '||aco_group_table||' (aclaco_id, aclgroup_id) values ('||aco_id||','||group_id||') ;';

    RETURN appli_id;
END;
$$;


ALTER FUNCTION gacl.create_groups(gacl_schema character varying, appli_name character varying) OWNER TO collec;

--
-- Name: create_rights_for_user(character varying, character varying, integer); Type: FUNCTION; Schema: gacl; Owner: collec
--

CREATE FUNCTION create_rights_for_user(gacl_schema character varying, appli_name character varying, userid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	appli_id INTEGER;
	aco_id INTEGER;
	group_id INTEGER;

	test VARCHAR;
	appli_table VARCHAR := gacl_schema||'.'||'aclappli';
	aco_table VARCHAR := gacl_schema||'.'||'aclaco';
	group_table VARCHAR := gacl_schema||'.'||'aclgroup';
	aco_group_table VARCHAR := gacl_schema||'.'||'aclacl';
	login_group_table VARCHAR := gacl_schema||'.'||'acllogingroup';
BEGIN
	-- Find the unique id of the appli in the schema gacl
	EXECUTE 'SELECT aclappli_id FROM '||appli_table||' where appli = '''||appli_name||''' ' INTO appli_id;
	raise notice 'Mon identifiant appli %', appli_id;

	-- First, insert new corresponding rights for this application (values are invariant, hardcoded in PHP code)
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''admin'');';
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''param'');';
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''projet'');';
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''gestion'');';
	EXECUTE 'insert into '||aco_table||' (aclappli_id, aco) values ( '||appli_id ||', ''consult'');';


	-- Second, insert new groups for this application (values are free, but coded in a readable manner for this code)
	-- test := 'insert into '||group_table||'  (groupe) values ( ''param_group'');';
	--raise notice 'insert GROUP %', test;
	EXECUTE 'insert into '||group_table||'  (groupe) values ( ''param_group'');';
	EXECUTE 'insert into '||group_table||'  (groupe) values ( ''projet_group'');';
	EXECUTE 'insert into '||group_table||'  (groupe) values ( ''gestion_group'');';
	EXECUTE 'insert into '||group_table||'  (groupe) values ( ''consult_group'');';

	-- Third associate those group to their corresponding rights and put the user admin into the group

	-- Associate the right ''param'' with the user
    EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''param'' ' INTO aco_id ;
    EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''param_group'' ' INTO group_id ;
    EXECUTE 'insert into '||aco_group_table||' (aclaco_id, aclgroup_id) values ('||aco_id||','||group_id||') ;';
    EXECUTE 'insert into '||login_group_table||' (acllogin_id, aclgroup_id) values ('||userid||','||group_id||') ;';

    --  Associate the right ''projet'' with the user
    EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''projet'' ' INTO aco_id ;
    EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''projet_group'' ' INTO group_id ;
    EXECUTE 'insert into '||aco_group_table||' (aclaco_id, aclgroup_id) values ('||aco_id||','||group_id||') ;';
    EXECUTE 'insert into '||login_group_table||' (acllogin_id, aclgroup_id) values ('||userid||','||group_id||') ;';

    -- Associate  the right ''gestion'' with the user
    EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''gestion'' ' INTO aco_id ;
    EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''gestion_group'' ' INTO group_id ;
    EXECUTE 'insert into '||aco_group_table||' (aclaco_id, aclgroup_id) values ('||aco_id||','||group_id||') ;';
    EXECUTE 'insert into '||login_group_table||' (acllogin_id, aclgroup_id) values ('||userid||','||group_id||') ;';

    --  Associate the right ''consult'' with the user
    EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''consult'' ' INTO aco_id ;
    EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''consult_group'' ' INTO group_id ;
    EXECUTE 'insert into '||aco_group_table||' (aclaco_id, aclgroup_id) values ('||aco_id||','||group_id||') ;';
    EXECUTE 'insert into '||login_group_table||' (acllogin_id, aclgroup_id) values ('||userid||','||group_id||') ;';

    RETURN appli_id;
END;
$$;


ALTER FUNCTION gacl.create_rights_for_user(gacl_schema character varying, appli_name character varying, userid integer) OWNER TO collec;

--
-- Name: set_rights_to_appli(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: gacl; Owner: collec
--

CREATE FUNCTION set_rights_to_appli(gacl_schema character varying, appli_name character varying, login character varying, level character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    userid INTEGER := -1;
	appli_id INTEGER;
	aco_id INTEGER;
	group_id INTEGER;

	test VARCHAR;
	login_table VARCHAR := gacl_schema||'.'||'acllogin';
	appli_table VARCHAR := gacl_schema||'.'||'aclappli';
	aco_table VARCHAR := gacl_schema||'.'||'aclaco';
	group_table VARCHAR := gacl_schema||'.'||'aclgroup';
	aco_group_table VARCHAR := gacl_schema||'.'||'aclacl';
	login_group_table VARCHAR := gacl_schema||'.'||'acllogingroup';
BEGIN
	-- First, Find the unique id of the appli in the schema gacl
	EXECUTE 'SELECT aclappli_id FROM '||appli_table||' where appli = '''||appli_name||''' ' INTO appli_id;
	raise notice 'Application identifier : %', appli_id;

	-- Second, Find the unique id of the user in the schema gacl
	-- insert into acllogin (acllogin_id, login, logindetail) values (1, 'admin', 'admin');
	EXECUTE 'SELECT acllogin_id FROM '||login_table||' where login = '''||login||''' ' INTO userid;
	raise notice 'User identifier :  %', userid;

	-- Third associate the user with the selected level of ACL

    if level = 'all' or level = 'admin'  THEN
        -- Associate the right ''admin'' with the user
        EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''admin'' ' INTO aco_id ;
        EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''admin_group'' ' INTO group_id ;
        EXECUTE 'insert into '||login_group_table||' (acllogin_id, aclgroup_id) values ('||userid||','||group_id||') ;';
    END IF;


    if level = 'all' or level = 'param'  THEN
        -- Associate the right ''param'' with the user
        EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''param'' ' INTO aco_id ;
        EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''param_group'' ' INTO group_id ;
        EXECUTE 'insert into '||login_group_table||' (acllogin_id, aclgroup_id) values ('||userid||','||group_id||') ;';
    END IF;

    if level = 'all' or level = 'projet'  THEN
        --  Associate the right ''projet'' with the user
        EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''projet'' ' INTO aco_id ;
        EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''projet_group'' ' INTO group_id ;
        EXECUTE 'insert into '||login_group_table||' (acllogin_id, aclgroup_id) values ('||userid||','||group_id||') ;';
    END IF;

    if level = 'all' or level = 'gestion'  THEN
        -- Associate  the right ''gestion'' with the user
        EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''gestion'' ' INTO aco_id ;
        EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''gestion_group'' ' INTO group_id ;
        EXECUTE 'insert into '||login_group_table||' (acllogin_id, aclgroup_id) values ('||userid||','||group_id||') ;';
    END IF;

    if level = 'all' or level = 'consult'  THEN
        --  Associate the right ''consult'' with the user
        EXECUTE 'select aclaco_id from '||aco_table||' where aclappli_id = '||appli_id ||' and aco = ''consult'' ' INTO aco_id ;
        EXECUTE 'select aclgroup_id from '||group_table||' where groupe = ''consult_group'' ' INTO group_id ;
        EXECUTE 'insert into '||login_group_table||' (acllogin_id, aclgroup_id) values ('||userid||','||group_id||') ;';
    END IF;

    RETURN userid;
END;
$$;


ALTER FUNCTION gacl.set_rights_to_appli(gacl_schema character varying, appli_name character varying, login character varying, level character varying) OWNER TO collec;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: aclgroup; Type: TABLE; Schema: gacl; Owner: collec
--

CREATE TABLE aclgroup (
    aclgroup_id integer NOT NULL,
    groupe character varying NOT NULL,
    aclgroup_id_parent integer
);


ALTER TABLE aclgroup OWNER TO collec;

--
-- Name: TABLE aclgroup; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON TABLE aclgroup IS 'Groupes des logins';


--
-- Name: aclacl; Type: TABLE; Schema: gacl; Owner: collec
--

CREATE TABLE aclacl (
    aclaco_id integer NOT NULL,
    aclgroup_id integer NOT NULL
);


ALTER TABLE aclacl OWNER TO collec;

--
-- Name: TABLE aclacl; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON TABLE aclacl IS 'Table des droits attribués';


--
-- Name: aclaco; Type: TABLE; Schema: gacl; Owner: collec
--

CREATE TABLE aclaco (
    aclaco_id integer NOT NULL,
    aclappli_id integer NOT NULL,
    aco character varying NOT NULL
);


ALTER TABLE aclaco OWNER TO collec;

--
-- Name: TABLE aclaco; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON TABLE aclaco IS 'Table des droits gérés';


--
-- Name: aclaco_aclaco_id_seq; Type: SEQUENCE; Schema: gacl; Owner: collec
--

CREATE SEQUENCE aclaco_aclaco_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aclaco_aclaco_id_seq OWNER TO collec;

--
-- Name: aclaco_aclaco_id_seq; Type: SEQUENCE OWNED BY; Schema: gacl; Owner: collec
--

ALTER SEQUENCE aclaco_aclaco_id_seq OWNED BY aclaco.aclaco_id;


--
-- Name: aclappli; Type: TABLE; Schema: gacl; Owner: collec
--

CREATE TABLE aclappli (
    aclappli_id integer NOT NULL,
    appli character varying NOT NULL,
    applidetail character varying
);


ALTER TABLE aclappli OWNER TO collec;

--
-- Name: TABLE aclappli; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON TABLE aclappli IS 'Table des applications gérées';


--
-- Name: COLUMN aclappli.appli; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON COLUMN aclappli.appli IS 'Nom de l''application pour la gestion des droits';


--
-- Name: COLUMN aclappli.applidetail; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON COLUMN aclappli.applidetail IS 'Description de l''application';


--
-- Name: aclappli_aclappli_id_seq; Type: SEQUENCE; Schema: gacl; Owner: collec
--

CREATE SEQUENCE aclappli_aclappli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aclappli_aclappli_id_seq OWNER TO collec;

--
-- Name: aclappli_aclappli_id_seq; Type: SEQUENCE OWNED BY; Schema: gacl; Owner: collec
--

ALTER SEQUENCE aclappli_aclappli_id_seq OWNED BY aclappli.aclappli_id;


--
-- Name: aclgroup_aclgroup_id_seq; Type: SEQUENCE; Schema: gacl; Owner: collec
--

CREATE SEQUENCE aclgroup_aclgroup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aclgroup_aclgroup_id_seq OWNER TO collec;

--
-- Name: aclgroup_aclgroup_id_seq; Type: SEQUENCE OWNED BY; Schema: gacl; Owner: collec
--

ALTER SEQUENCE aclgroup_aclgroup_id_seq OWNED BY aclgroup.aclgroup_id;


--
-- Name: acllogin; Type: TABLE; Schema: gacl; Owner: collec
--

CREATE TABLE acllogin (
    acllogin_id integer NOT NULL,
    login character varying NOT NULL,
    logindetail character varying NOT NULL
);


ALTER TABLE acllogin OWNER TO collec;

--
-- Name: TABLE acllogin; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON TABLE acllogin IS 'Table des logins des utilisateurs autorisés';


--
-- Name: COLUMN acllogin.logindetail; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON COLUMN acllogin.logindetail IS 'Nom affiché';


--
-- Name: acllogin_acllogin_id_seq; Type: SEQUENCE; Schema: gacl; Owner: collec
--

CREATE SEQUENCE acllogin_acllogin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE acllogin_acllogin_id_seq OWNER TO collec;

--
-- Name: acllogin_acllogin_id_seq; Type: SEQUENCE OWNED BY; Schema: gacl; Owner: collec
--

ALTER SEQUENCE acllogin_acllogin_id_seq OWNED BY acllogin.acllogin_id;


--
-- Name: acllogingroup; Type: TABLE; Schema: gacl; Owner: collec
--

CREATE TABLE acllogingroup (
    acllogin_id integer NOT NULL,
    aclgroup_id integer NOT NULL
);


ALTER TABLE acllogingroup OWNER TO collec;

--
-- Name: TABLE acllogingroup; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON TABLE acllogingroup IS 'Table des relations entre les logins et les groupes';


--
-- Name: log; Type: TABLE; Schema: gacl; Owner: collec
--

CREATE TABLE log (
    log_id integer NOT NULL,
    login character varying(32) NOT NULL,
    nom_module character varying,
    log_date timestamp without time zone NOT NULL,
    commentaire character varying,
    ipaddress character varying
);


ALTER TABLE log OWNER TO collec;

--
-- Name: TABLE log; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON TABLE log IS 'Liste des connexions ou des actions enregistrées';


--
-- Name: COLUMN log.log_date; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON COLUMN log.log_date IS 'Heure de connexion';


--
-- Name: COLUMN log.commentaire; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON COLUMN log.commentaire IS 'Donnees complementaires enregistrees';


--
-- Name: COLUMN log.ipaddress; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON COLUMN log.ipaddress IS 'Adresse IP du client';


--
-- Name: log_log_id_seq; Type: SEQUENCE; Schema: gacl; Owner: collec
--

CREATE SEQUENCE log_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE log_log_id_seq OWNER TO collec;

--
-- Name: log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: gacl; Owner: collec
--

ALTER SEQUENCE log_log_id_seq OWNED BY log.log_id;


--
-- Name: seq_logingestion_id; Type: SEQUENCE; Schema: gacl; Owner: collec
--

CREATE SEQUENCE seq_logingestion_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE seq_logingestion_id OWNER TO collec;

--
-- Name: login_oldpassword; Type: TABLE; Schema: gacl; Owner: collec
--

CREATE TABLE login_oldpassword (
    login_oldpassword_id integer NOT NULL,
    id integer DEFAULT nextval('seq_logingestion_id'::regclass) NOT NULL,
    password character varying(255)
);


ALTER TABLE login_oldpassword OWNER TO collec;

--
-- Name: TABLE login_oldpassword; Type: COMMENT; Schema: gacl; Owner: collec
--

COMMENT ON TABLE login_oldpassword IS 'Table contenant les anciens mots de passe';


--
-- Name: login_oldpassword_login_oldpassword_id_seq; Type: SEQUENCE; Schema: gacl; Owner: collec
--

CREATE SEQUENCE login_oldpassword_login_oldpassword_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE login_oldpassword_login_oldpassword_id_seq OWNER TO collec;

--
-- Name: login_oldpassword_login_oldpassword_id_seq; Type: SEQUENCE OWNED BY; Schema: gacl; Owner: collec
--

ALTER SEQUENCE login_oldpassword_login_oldpassword_id_seq OWNED BY login_oldpassword.login_oldpassword_id;


--
-- Name: logingestion; Type: TABLE; Schema: gacl; Owner: collec
--

CREATE TABLE logingestion (
    id integer DEFAULT nextval('seq_logingestion_id'::regclass) NOT NULL,
    login character varying(32) NOT NULL,
    password character varying(255),
    nom character varying(32),
    prenom character varying(32),
    mail character varying(255),
    datemodif date,
    actif smallint DEFAULT 1
);


ALTER TABLE logingestion OWNER TO collec;

SET search_path = zaalpes, pg_catalog;

--
-- Name: aclgroup; Type: VIEW; Schema: zaalpes; Owner: collec
--

CREATE VIEW aclgroup AS
 SELECT aclgroup.aclgroup_id,
    aclgroup.groupe,
    aclgroup.aclgroup_id_parent
   FROM gacl.aclgroup;


ALTER TABLE aclgroup OWNER TO collec;

--
-- Name: booking; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE booking (
    booking_id integer NOT NULL,
    uid integer NOT NULL,
    booking_date timestamp without time zone NOT NULL,
    date_from timestamp without time zone NOT NULL,
    date_to timestamp without time zone NOT NULL,
    booking_comment character varying,
    booking_login character varying NOT NULL
);


ALTER TABLE booking OWNER TO collec;

--
-- Name: TABLE booking; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE booking IS 'Table des réservations d''objets';


--
-- Name: COLUMN booking.booking_date; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN booking.booking_date IS 'Date de la réservation';


--
-- Name: COLUMN booking.date_from; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN booking.date_from IS 'Date-heure de début de la réservation';


--
-- Name: COLUMN booking.date_to; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN booking.date_to IS 'Date-heure de fin de la réservation';


--
-- Name: COLUMN booking.booking_comment; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN booking.booking_comment IS 'Commentaire';


--
-- Name: COLUMN booking.booking_login; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN booking.booking_login IS 'Compte ayant réalisé la réservation';


--
-- Name: booking_booking_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE booking_booking_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE booking_booking_id_seq OWNER TO collec;

--
-- Name: booking_booking_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE booking_booking_id_seq OWNED BY booking.booking_id;


--
-- Name: container; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE container (
    container_id integer NOT NULL,
    uid integer NOT NULL,
    container_type_id integer NOT NULL
);


ALTER TABLE container OWNER TO collec;

--
-- Name: TABLE container; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE container IS 'Liste des conteneurs d''échantillon';


--
-- Name: container_container_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE container_container_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE container_container_id_seq OWNER TO collec;

--
-- Name: container_container_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE container_container_id_seq OWNED BY container.container_id;


--
-- Name: container_family; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE container_family (
    container_family_id integer NOT NULL,
    container_family_name character varying NOT NULL,
    is_movable boolean DEFAULT true NOT NULL
);


ALTER TABLE container_family OWNER TO collec;

--
-- Name: TABLE container_family; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE container_family IS 'Famille générique des conteneurs';


--
-- Name: COLUMN container_family.is_movable; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN container_family.is_movable IS 'Indique si la famille de conteneurs est déplçable facilement ou non (éprouvette : oui, armoire : non)';


--
-- Name: container_family_container_family_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE container_family_container_family_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE container_family_container_family_id_seq OWNER TO collec;

--
-- Name: container_family_container_family_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE container_family_container_family_id_seq OWNED BY container_family.container_family_id;


--
-- Name: container_type; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE container_type (
    container_type_id integer NOT NULL,
    container_type_name character varying NOT NULL,
    container_family_id integer NOT NULL,
    storage_condition_id integer,
    label_id integer,
    container_type_description character varying,
    storage_product character varying,
    clp_classification character varying
);


ALTER TABLE container_type OWNER TO collec;

--
-- Name: TABLE container_type; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE container_type IS 'Table des types de conteneurs';


--
-- Name: COLUMN container_type.container_type_description; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN container_type.container_type_description IS 'Description longue';


--
-- Name: COLUMN container_type.storage_product; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN container_type.storage_product IS 'Produit utilisé pour le stockage (formol, alcool...)';


--
-- Name: COLUMN container_type.clp_classification; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN container_type.clp_classification IS 'Classification du risque conformément à la directive européenne CLP';


--
-- Name: container_type_container_type_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE container_type_container_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE container_type_container_type_id_seq OWNER TO collec;

--
-- Name: container_type_container_type_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE container_type_container_type_id_seq OWNED BY container_type.container_type_id;


--
-- Name: document; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE document (
    document_id integer NOT NULL,
    uid integer NOT NULL,
    mime_type_id integer NOT NULL,
    document_import_date timestamp without time zone NOT NULL,
    document_name character varying NOT NULL,
    document_description character varying,
    data bytea,
    thumbnail bytea,
    size integer,
    document_creation_date timestamp without time zone
);


ALTER TABLE document OWNER TO collec;

--
-- Name: TABLE document; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE document IS 'Documents numériques rattachés à un poisson ou à un événement';


--
-- Name: COLUMN document.document_import_date; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN document.document_import_date IS 'Date d''import dans la base de données';


--
-- Name: COLUMN document.document_name; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN document.document_name IS 'Nom d''origine du document';


--
-- Name: COLUMN document.document_description; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN document.document_description IS 'Description libre du document';


--
-- Name: COLUMN document.data; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN document.data IS 'Contenu du document';


--
-- Name: COLUMN document.thumbnail; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN document.thumbnail IS 'Vignette au format PNG (documents pdf, jpg ou png)';


--
-- Name: COLUMN document.size; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN document.size IS 'Taille du fichier téléchargé';


--
-- Name: COLUMN document.document_creation_date; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN document.document_creation_date IS 'Date de création du document (date de prise de vue de la photo)';


--
-- Name: document_document_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE document_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE document_document_id_seq OWNER TO collec;

--
-- Name: document_document_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE document_document_id_seq OWNED BY document.document_id;


--
-- Name: event; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE event (
    event_id integer NOT NULL,
    uid integer NOT NULL,
    event_date timestamp without time zone NOT NULL,
    event_type_id integer NOT NULL,
    still_available character varying,
    event_comment character varying
);


ALTER TABLE event OWNER TO collec;

--
-- Name: TABLE event; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE event IS 'Table des événements';


--
-- Name: COLUMN event.event_date; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN event.event_date IS 'Date / heure de l''événement';


--
-- Name: COLUMN event.still_available; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN event.still_available IS 'définit ce qu''il reste de disponible dans l''objet';


--
-- Name: event_event_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE event_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_event_id_seq OWNER TO collec;

--
-- Name: event_event_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE event_event_id_seq OWNED BY event.event_id;


--
-- Name: event_type; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE event_type (
    event_type_id integer NOT NULL,
    event_type_name character varying NOT NULL,
    is_sample boolean DEFAULT false NOT NULL,
    is_container boolean DEFAULT false NOT NULL
);


ALTER TABLE event_type OWNER TO collec;

--
-- Name: TABLE event_type; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE event_type IS 'Types d''événement';


--
-- Name: COLUMN event_type.is_sample; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN event_type.is_sample IS 'L''événement s''applique aux échantillons';


--
-- Name: COLUMN event_type.is_container; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN event_type.is_container IS 'L''événement s''applique aux conteneurs';


--
-- Name: event_type_event_type_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE event_type_event_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_type_event_type_id_seq OWNER TO collec;

--
-- Name: event_type_event_type_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE event_type_event_type_id_seq OWNED BY event_type.event_type_id;


--
-- Name: identifier_type; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE identifier_type (
    identifier_type_id integer NOT NULL,
    identifier_type_name character varying NOT NULL,
    identifier_type_code character varying NOT NULL
);


ALTER TABLE identifier_type OWNER TO collec;

--
-- Name: TABLE identifier_type; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE identifier_type IS 'Table des types d''identifiants';


--
-- Name: COLUMN identifier_type.identifier_type_name; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN identifier_type.identifier_type_name IS 'Nom textuel de l''identifiant';


--
-- Name: COLUMN identifier_type.identifier_type_code; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN identifier_type.identifier_type_code IS 'Code utilisé pour la génération des étiquettes';


--
-- Name: identifier_type_identifier_type_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE identifier_type_identifier_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE identifier_type_identifier_type_id_seq OWNER TO collec;

--
-- Name: identifier_type_identifier_type_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE identifier_type_identifier_type_id_seq OWNED BY identifier_type.identifier_type_id;


--
-- Name: label; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE label (
    label_id integer NOT NULL,
    label_name character varying NOT NULL,
    label_xsl character varying NOT NULL,
    label_fields character varying DEFAULT 'uid,id,clp,db'::character varying NOT NULL,
    operation_id integer
);


ALTER TABLE label OWNER TO collec;

--
-- Name: TABLE label; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE label IS 'Table des modèles d''étiquettes';


--
-- Name: COLUMN label.label_name; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN label.label_name IS 'Nom du modèle';


--
-- Name: COLUMN label.label_xsl; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN label.label_xsl IS 'Contenu du fichier XSL utilisé pour la transformation FOP (https://xmlgraphics.apache.org/fop/)';


--
-- Name: COLUMN label.label_fields; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN label.label_fields IS 'Liste des champs à intégrer dans le QRCODE, séparés par une virgule';


--
-- Name: label_label_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE label_label_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE label_label_id_seq OWNER TO collec;

--
-- Name: label_label_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE label_label_id_seq OWNED BY label.label_id;


--
-- Name: storage; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE storage (
    storage_id integer NOT NULL,
    uid integer NOT NULL,
    container_id integer,
    movement_type_id integer NOT NULL,
    storage_reason_id integer,
    storage_date timestamp without time zone NOT NULL,
    storage_location character varying,
    login character varying NOT NULL,
    storage_comment character varying
);


ALTER TABLE storage OWNER TO collec;

--
-- Name: TABLE storage; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE storage IS 'Gestion du stockage des échantillons';


--
-- Name: COLUMN storage.storage_date; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN storage.storage_date IS 'Date/heure du mouvement';


--
-- Name: COLUMN storage.storage_location; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN storage.storage_location IS 'Emplacement de l''échantillon dans le conteneur';


--
-- Name: COLUMN storage.login; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN storage.login IS 'Nom de l''utilisateur ayant réalisé l''opération';


--
-- Name: COLUMN storage.storage_comment; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN storage.storage_comment IS 'Commentaire';


--
-- Name: last_movement; Type: VIEW; Schema: zaalpes; Owner: collec
--

CREATE VIEW last_movement AS
 SELECT s.uid,
    s.storage_id,
    s.storage_date,
    s.movement_type_id,
    s.container_id,
    c.uid AS container_uid
   FROM (storage s
     LEFT JOIN container c USING (container_id))
  WHERE (s.storage_id = ( SELECT st.storage_id
           FROM storage st
          WHERE (s.uid = st.uid)
          ORDER BY st.storage_date DESC
         LIMIT 1));


ALTER TABLE last_movement OWNER TO collec;

--
-- Name: VIEW last_movement; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON VIEW last_movement IS 'Dernier mouvement d''un objet';


--
-- Name: last_photo; Type: VIEW; Schema: zaalpes; Owner: collec
--

CREATE VIEW last_photo AS
 SELECT d.document_id,
    d.uid
   FROM document d
  WHERE (d.document_id = ( SELECT d1.document_id
           FROM document d1
          WHERE ((d1.mime_type_id = ANY (ARRAY[4, 5, 6])) AND (d.uid = d1.uid))
          ORDER BY d1.document_creation_date DESC, d1.document_import_date DESC, d1.document_id DESC
         LIMIT 1));


ALTER TABLE last_photo OWNER TO collec;

--
-- Name: metadata_form; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE metadata_form (
    metadata_form_id integer NOT NULL,
    metadata_schema json
);


ALTER TABLE metadata_form OWNER TO collec;

--
-- Name: TABLE metadata_form; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE metadata_form IS 'Table des schémas des formulaires de métadonnées';


--
-- Name: COLUMN metadata_form.metadata_schema; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN metadata_form.metadata_schema IS 'Schéma en JSON du formulaire des métadonnées ';


--
-- Name: metadata_form_metadata_form_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE metadata_form_metadata_form_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE metadata_form_metadata_form_id_seq OWNER TO collec;

--
-- Name: metadata_form_metadata_form_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE metadata_form_metadata_form_id_seq OWNED BY metadata_form.metadata_form_id;


--
-- Name: mime_type; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE mime_type (
    mime_type_id integer NOT NULL,
    extension character varying NOT NULL,
    content_type character varying NOT NULL
);


ALTER TABLE mime_type OWNER TO collec;

--
-- Name: TABLE mime_type; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE mime_type IS 'Types mime des fichiers importés';


--
-- Name: COLUMN mime_type.extension; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN mime_type.extension IS 'Extension du fichier correspondant';


--
-- Name: COLUMN mime_type.content_type; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN mime_type.content_type IS 'type mime officiel';


--
-- Name: mime_type_mime_type_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE mime_type_mime_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mime_type_mime_type_id_seq OWNER TO collec;

--
-- Name: mime_type_mime_type_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE mime_type_mime_type_id_seq OWNED BY mime_type.mime_type_id;


--
-- Name: movement_type; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE movement_type (
    movement_type_id integer NOT NULL,
    movement_type_name character varying NOT NULL
);


ALTER TABLE movement_type OWNER TO collec;

--
-- Name: TABLE movement_type; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE movement_type IS 'Type de mouvement';


--
-- Name: movement_type_movement_type_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE movement_type_movement_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE movement_type_movement_type_id_seq OWNER TO collec;

--
-- Name: movement_type_movement_type_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE movement_type_movement_type_id_seq OWNED BY movement_type.movement_type_id;


--
-- Name: multiple_type; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE multiple_type (
    multiple_type_id integer NOT NULL,
    multiple_type_name character varying NOT NULL
);


ALTER TABLE multiple_type OWNER TO collec;

--
-- Name: TABLE multiple_type; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE multiple_type IS 'Table des types de contenus multiples';


--
-- Name: multiple_type_multiple_type_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE multiple_type_multiple_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE multiple_type_multiple_type_id_seq OWNER TO collec;

--
-- Name: multiple_type_multiple_type_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE multiple_type_multiple_type_id_seq OWNED BY multiple_type.multiple_type_id;


--
-- Name: object; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE object (
    uid integer NOT NULL,
    identifier character varying,
    object_status_id integer,
    wgs84_x double precision,
    wgs84_y double precision
);


ALTER TABLE object OWNER TO collec;

--
-- Name: TABLE object; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE object IS 'Table des objets
Contient les identifiants génériques';


--
-- Name: COLUMN object.identifier; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN object.identifier IS 'Identifiant fourni le cas échéant par le projet';


--
-- Name: COLUMN object.wgs84_x; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN object.wgs84_x IS 'Longitude GPS, en valeur décimale';


--
-- Name: COLUMN object.wgs84_y; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN object.wgs84_y IS 'Latitude GPS, en décimal';


--
-- Name: object_identifier; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE object_identifier (
    object_identifier_id integer NOT NULL,
    uid integer NOT NULL,
    identifier_type_id integer NOT NULL,
    object_identifier_value character varying NOT NULL
);


ALTER TABLE object_identifier OWNER TO collec;

--
-- Name: TABLE object_identifier; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE object_identifier IS 'Table des identifiants complémentaires normalisés';


--
-- Name: COLUMN object_identifier.object_identifier_value; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN object_identifier.object_identifier_value IS 'Valeur de l''identifiant';


--
-- Name: object_identifier_object_identifier_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE object_identifier_object_identifier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE object_identifier_object_identifier_id_seq OWNER TO collec;

--
-- Name: object_identifier_object_identifier_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE object_identifier_object_identifier_id_seq OWNED BY object_identifier.object_identifier_id;


--
-- Name: object_status; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE object_status (
    object_status_id integer NOT NULL,
    object_status_name character varying NOT NULL
);


ALTER TABLE object_status OWNER TO collec;

--
-- Name: TABLE object_status; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE object_status IS 'Table des statuts possibles des objets';


--
-- Name: object_status_object_status_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE object_status_object_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE object_status_object_status_id_seq OWNER TO collec;

--
-- Name: object_status_object_status_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE object_status_object_status_id_seq OWNED BY object_status.object_status_id;


--
-- Name: object_uid_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE object_uid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE object_uid_seq OWNER TO collec;

--
-- Name: object_uid_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE object_uid_seq OWNED BY object.uid;


--
-- Name: operation; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE operation (
    operation_id integer NOT NULL,
    protocol_id integer NOT NULL,
    operation_name character varying NOT NULL,
    operation_order integer,
    metadata_form_id integer,
    operation_version character varying,
    last_edit_date timestamp without time zone
);


ALTER TABLE operation OWNER TO collec;

--
-- Name: COLUMN operation.operation_order; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN operation.operation_order IS 'Ordre de réalisation de l''opération dans le protocole';


--
-- Name: COLUMN operation.operation_version; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN operation.operation_version IS 'Version de l''opération';


--
-- Name: COLUMN operation.last_edit_date; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN operation.last_edit_date IS 'Date de dernière éditione l''opératon';


--
-- Name: operation_operation_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE operation_operation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE operation_operation_id_seq OWNER TO collec;

--
-- Name: operation_operation_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE operation_operation_id_seq OWNED BY operation.operation_id;


--
-- Name: project; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE project (
    project_id integer NOT NULL,
    project_name character varying NOT NULL
);


ALTER TABLE project OWNER TO collec;

--
-- Name: TABLE project; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE project IS 'Table des projets';


--
-- Name: project_group; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE project_group (
    project_id integer NOT NULL,
    aclgroup_id integer NOT NULL
);


ALTER TABLE project_group OWNER TO collec;

--
-- Name: TABLE project_group; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE project_group IS 'Table des autorisations d''accès à un projet';


--
-- Name: project_project_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE project_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE project_project_id_seq OWNER TO collec;

--
-- Name: project_project_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE project_project_id_seq OWNED BY project.project_id;


--
-- Name: protocol; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE protocol (
    protocol_id integer NOT NULL,
    protocol_name character varying NOT NULL,
    protocol_file bytea,
    protocol_year smallint,
    protocol_version character varying DEFAULT 'v1.0'::character varying NOT NULL
);


ALTER TABLE protocol OWNER TO collec;

--
-- Name: COLUMN protocol.protocol_file; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN protocol.protocol_file IS 'Description PDF du protocole';


--
-- Name: COLUMN protocol.protocol_year; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN protocol.protocol_year IS 'Année du protocole';


--
-- Name: COLUMN protocol.protocol_version; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN protocol.protocol_version IS 'Version du protocole';


--
-- Name: protocol_protocol_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE protocol_protocol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE protocol_protocol_id_seq OWNER TO collec;

--
-- Name: protocol_protocol_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE protocol_protocol_id_seq OWNED BY protocol.protocol_id;


--
-- Name: sample; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE sample (
    sample_id integer NOT NULL,
    uid integer NOT NULL,
    project_id integer NOT NULL,
    sample_type_id integer NOT NULL,
    sample_creation_date timestamp without time zone NOT NULL,
    sample_date timestamp without time zone,
    parent_sample_id integer,
    multiple_value double precision,
    sampling_place_id integer,
    dbuid_origin character varying,
    sample_metadata_id integer
);


ALTER TABLE sample OWNER TO collec;

--
-- Name: TABLE sample; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE sample IS 'Table des échantillons';


--
-- Name: COLUMN sample.sample_creation_date; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN sample.sample_creation_date IS 'Date de création de l''enregistrement dans la base de données';


--
-- Name: COLUMN sample.sample_date; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN sample.sample_date IS 'Date de création de l''échantillon physique';


--
-- Name: COLUMN sample.multiple_value; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN sample.multiple_value IS 'Nombre initial de sous-échantillons';


--
-- Name: COLUMN sample.dbuid_origin; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN sample.dbuid_origin IS 'référence utilisée dans la base de données d''origine, sous la forme db:uid
Utilisé pour lire les étiquettes créées dans d''autres instances';


--
-- Name: sample_metadata; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE sample_metadata (
    sample_metadata_id integer NOT NULL,
    data json
);


ALTER TABLE sample_metadata OWNER TO collec;

--
-- Name: TABLE sample_metadata; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE sample_metadata IS 'Table des métadonnées';


--
-- Name: COLUMN sample_metadata.data; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN sample_metadata.data IS 'Métadonnées en JSON';


--
-- Name: sample_metadata_sample_metadata_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE sample_metadata_sample_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sample_metadata_sample_metadata_id_seq OWNER TO collec;

--
-- Name: sample_metadata_sample_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE sample_metadata_sample_metadata_id_seq OWNED BY sample_metadata.sample_metadata_id;


--
-- Name: sample_sample_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE sample_sample_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sample_sample_id_seq OWNER TO collec;

--
-- Name: sample_sample_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE sample_sample_id_seq OWNED BY sample.sample_id;


--
-- Name: sample_type; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE sample_type (
    sample_type_id integer NOT NULL,
    sample_type_name character varying NOT NULL,
    container_type_id integer,
    operation_id integer,
    multiple_type_id integer,
    multiple_unit character varying
);


ALTER TABLE sample_type OWNER TO collec;

--
-- Name: TABLE sample_type; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE sample_type IS 'Types d''échantillons';


--
-- Name: COLUMN sample_type.multiple_unit; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN sample_type.multiple_unit IS 'Unité caractérisant le sous-échantillon';


--
-- Name: sample_type_sample_type_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE sample_type_sample_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sample_type_sample_type_id_seq OWNER TO collec;

--
-- Name: sample_type_sample_type_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE sample_type_sample_type_id_seq OWNED BY sample_type.sample_type_id;


--
-- Name: sampling_place; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE sampling_place (
    sampling_place_id integer NOT NULL,
    sampling_place_name character varying NOT NULL
);


ALTER TABLE sampling_place OWNER TO collec;

--
-- Name: TABLE sampling_place; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE sampling_place IS 'Table des lieux génériques d''échantillonnage';


--
-- Name: sampling_place_sampling_place_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE sampling_place_sampling_place_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sampling_place_sampling_place_id_seq OWNER TO collec;

--
-- Name: sampling_place_sampling_place_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE sampling_place_sampling_place_id_seq OWNED BY sampling_place.sampling_place_id;


--
-- Name: storage_condition; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE storage_condition (
    storage_condition_id integer NOT NULL,
    storage_condition_name character varying NOT NULL
);


ALTER TABLE storage_condition OWNER TO collec;

--
-- Name: TABLE storage_condition; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE storage_condition IS 'Condition de stockage';


--
-- Name: storage_condition_storage_condition_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE storage_condition_storage_condition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE storage_condition_storage_condition_id_seq OWNER TO collec;

--
-- Name: storage_condition_storage_condition_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE storage_condition_storage_condition_id_seq OWNED BY storage_condition.storage_condition_id;


--
-- Name: storage_reason; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE storage_reason (
    storage_reason_id integer NOT NULL,
    storage_reason_name character varying NOT NULL
);


ALTER TABLE storage_reason OWNER TO collec;

--
-- Name: TABLE storage_reason; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE storage_reason IS 'Table des raisons de stockage/déstockage';


--
-- Name: storage_reason_storage_reason_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE storage_reason_storage_reason_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE storage_reason_storage_reason_id_seq OWNER TO collec;

--
-- Name: storage_reason_storage_reason_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE storage_reason_storage_reason_id_seq OWNED BY storage_reason.storage_reason_id;


--
-- Name: storage_storage_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE storage_storage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE storage_storage_id_seq OWNER TO collec;

--
-- Name: storage_storage_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE storage_storage_id_seq OWNED BY storage.storage_id;


--
-- Name: subsample; Type: TABLE; Schema: zaalpes; Owner: collec
--

CREATE TABLE subsample (
    subsample_id integer NOT NULL,
    sample_id integer NOT NULL,
    subsample_date timestamp without time zone NOT NULL,
    movement_type_id integer NOT NULL,
    subsample_quantity double precision,
    subsample_comment character varying,
    subsample_login character varying NOT NULL
);


ALTER TABLE subsample OWNER TO collec;

--
-- Name: TABLE subsample; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON TABLE subsample IS 'Table des prélèvements et restitutions de sous-échantillons';


--
-- Name: COLUMN subsample.subsample_date; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN subsample.subsample_date IS 'Date/heure de l''opération';


--
-- Name: COLUMN subsample.subsample_quantity; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN subsample.subsample_quantity IS 'Quantité prélevée ou restituée';


--
-- Name: COLUMN subsample.subsample_login; Type: COMMENT; Schema: zaalpes; Owner: collec
--

COMMENT ON COLUMN subsample.subsample_login IS 'Login de l''utilisateur ayant réalisé l''opération';


--
-- Name: subsample_subsample_id_seq; Type: SEQUENCE; Schema: zaalpes; Owner: collec
--

CREATE SEQUENCE subsample_subsample_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subsample_subsample_id_seq OWNER TO collec;

--
-- Name: subsample_subsample_id_seq; Type: SEQUENCE OWNED BY; Schema: zaalpes; Owner: collec
--

ALTER SEQUENCE subsample_subsample_id_seq OWNED BY subsample.subsample_id;


--
-- Name: v_object_identifier; Type: VIEW; Schema: zaalpes; Owner: collec
--

CREATE VIEW v_object_identifier AS
 SELECT object_identifier.uid,
    array_to_string(array_agg((((identifier_type.identifier_type_code)::text || ':'::text) || (object_identifier.object_identifier_value)::text) ORDER BY identifier_type.identifier_type_code, object_identifier.object_identifier_value), ','::text) AS identifiers
   FROM (object_identifier
     JOIN identifier_type USING (identifier_type_id))
  GROUP BY object_identifier.uid
  ORDER BY object_identifier.uid;


ALTER TABLE v_object_identifier OWNER TO collec;

SET search_path = gacl, pg_catalog;

--
-- Name: aclaco_id; Type: DEFAULT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclaco ALTER COLUMN aclaco_id SET DEFAULT nextval('aclaco_aclaco_id_seq'::regclass);


--
-- Name: aclappli_id; Type: DEFAULT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclappli ALTER COLUMN aclappli_id SET DEFAULT nextval('aclappli_aclappli_id_seq'::regclass);


--
-- Name: aclgroup_id; Type: DEFAULT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclgroup ALTER COLUMN aclgroup_id SET DEFAULT nextval('aclgroup_aclgroup_id_seq'::regclass);


--
-- Name: acllogin_id; Type: DEFAULT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY acllogin ALTER COLUMN acllogin_id SET DEFAULT nextval('acllogin_acllogin_id_seq'::regclass);


--
-- Name: log_id; Type: DEFAULT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY log ALTER COLUMN log_id SET DEFAULT nextval('log_log_id_seq'::regclass);


--
-- Name: login_oldpassword_id; Type: DEFAULT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY login_oldpassword ALTER COLUMN login_oldpassword_id SET DEFAULT nextval('login_oldpassword_login_oldpassword_id_seq'::regclass);


SET search_path = zaalpes, pg_catalog;

--
-- Name: booking_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY booking ALTER COLUMN booking_id SET DEFAULT nextval('booking_booking_id_seq'::regclass);


--
-- Name: container_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container ALTER COLUMN container_id SET DEFAULT nextval('container_container_id_seq'::regclass);


--
-- Name: container_family_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container_family ALTER COLUMN container_family_id SET DEFAULT nextval('container_family_container_family_id_seq'::regclass);


--
-- Name: container_type_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container_type ALTER COLUMN container_type_id SET DEFAULT nextval('container_type_container_type_id_seq'::regclass);


--
-- Name: document_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY document ALTER COLUMN document_id SET DEFAULT nextval('document_document_id_seq'::regclass);


--
-- Name: event_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY event ALTER COLUMN event_id SET DEFAULT nextval('event_event_id_seq'::regclass);


--
-- Name: event_type_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY event_type ALTER COLUMN event_type_id SET DEFAULT nextval('event_type_event_type_id_seq'::regclass);


--
-- Name: identifier_type_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY identifier_type ALTER COLUMN identifier_type_id SET DEFAULT nextval('identifier_type_identifier_type_id_seq'::regclass);


--
-- Name: label_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY label ALTER COLUMN label_id SET DEFAULT nextval('label_label_id_seq'::regclass);


--
-- Name: metadata_form_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY metadata_form ALTER COLUMN metadata_form_id SET DEFAULT nextval('metadata_form_metadata_form_id_seq'::regclass);


--
-- Name: mime_type_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY mime_type ALTER COLUMN mime_type_id SET DEFAULT nextval('mime_type_mime_type_id_seq'::regclass);


--
-- Name: movement_type_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY movement_type ALTER COLUMN movement_type_id SET DEFAULT nextval('movement_type_movement_type_id_seq'::regclass);


--
-- Name: multiple_type_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY multiple_type ALTER COLUMN multiple_type_id SET DEFAULT nextval('multiple_type_multiple_type_id_seq'::regclass);


--
-- Name: uid; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY object ALTER COLUMN uid SET DEFAULT nextval('object_uid_seq'::regclass);


--
-- Name: object_identifier_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY object_identifier ALTER COLUMN object_identifier_id SET DEFAULT nextval('object_identifier_object_identifier_id_seq'::regclass);


--
-- Name: object_status_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY object_status ALTER COLUMN object_status_id SET DEFAULT nextval('object_status_object_status_id_seq'::regclass);


--
-- Name: operation_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY operation ALTER COLUMN operation_id SET DEFAULT nextval('operation_operation_id_seq'::regclass);


--
-- Name: project_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY project ALTER COLUMN project_id SET DEFAULT nextval('project_project_id_seq'::regclass);


--
-- Name: protocol_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY protocol ALTER COLUMN protocol_id SET DEFAULT nextval('protocol_protocol_id_seq'::regclass);


--
-- Name: sample_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample ALTER COLUMN sample_id SET DEFAULT nextval('sample_sample_id_seq'::regclass);


--
-- Name: sample_metadata_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample_metadata ALTER COLUMN sample_metadata_id SET DEFAULT nextval('sample_metadata_sample_metadata_id_seq'::regclass);


--
-- Name: sample_type_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample_type ALTER COLUMN sample_type_id SET DEFAULT nextval('sample_type_sample_type_id_seq'::regclass);


--
-- Name: sampling_place_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sampling_place ALTER COLUMN sampling_place_id SET DEFAULT nextval('sampling_place_sampling_place_id_seq'::regclass);


--
-- Name: storage_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage ALTER COLUMN storage_id SET DEFAULT nextval('storage_storage_id_seq'::regclass);


--
-- Name: storage_condition_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage_condition ALTER COLUMN storage_condition_id SET DEFAULT nextval('storage_condition_storage_condition_id_seq'::regclass);


--
-- Name: storage_reason_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage_reason ALTER COLUMN storage_reason_id SET DEFAULT nextval('storage_reason_storage_reason_id_seq'::regclass);


--
-- Name: subsample_id; Type: DEFAULT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY subsample ALTER COLUMN subsample_id SET DEFAULT nextval('subsample_subsample_id_seq'::regclass);


SET search_path = gacl, pg_catalog;

--
-- Data for Name: aclacl; Type: TABLE DATA; Schema: gacl; Owner: collec
--

COPY aclacl (aclaco_id, aclgroup_id) FROM stdin;
1	1
2	1
3	1
4	1
5	1
2	22
3	23
4	24
5	25
11	31
12	31
1	31
15	31
14	31
13	31
15	32
14	32
13	32
11	1
12	22
13	22
14	22
15	22
\.


--
-- Data for Name: aclaco; Type: TABLE DATA; Schema: gacl; Owner: collec
--

COPY aclaco (aclaco_id, aclappli_id, aco) FROM stdin;
2	1	param
3	1	projet
4	1	gestion
5	1	consult
1	1	admin
11	3	admin
12	3	param
13	3	projet
14	3	gestion
15	3	consult
\.


--
-- Name: aclaco_aclaco_id_seq; Type: SEQUENCE SET; Schema: gacl; Owner: collec
--

SELECT pg_catalog.setval('aclaco_aclaco_id_seq', 15, true);


--
-- Data for Name: aclappli; Type: TABLE DATA; Schema: gacl; Owner: collec
--

COPY aclappli (aclappli_id, appli, applidetail) FROM stdin;
1	col	\N
3	zaalpes	Carottes EDYTEM de roza
\.


--
-- Name: aclappli_aclappli_id_seq; Type: SEQUENCE SET; Schema: gacl; Owner: collec
--

SELECT pg_catalog.setval('aclappli_aclappli_id_seq', 3, true);


--
-- Data for Name: aclgroup; Type: TABLE DATA; Schema: gacl; Owner: collec
--

COPY aclgroup (aclgroup_id, groupe, aclgroup_id_parent) FROM stdin;
25	consult_group	\N
24	gestion_group	\N
23	projet_group	\N
32	iper_retro_group	\N
22	param_group	\N
31	admin_roza	\N
1	admin	\N
\.


--
-- Name: aclgroup_aclgroup_id_seq; Type: SEQUENCE SET; Schema: gacl; Owner: collec
--

SELECT pg_catalog.setval('aclgroup_aclgroup_id_seq', 32, true);


--
-- Data for Name: acllogin; Type: TABLE DATA; Schema: gacl; Owner: collec
--

COPY acllogin (acllogin_id, login, logindetail) FROM stdin;
1	admin	admin
2	cpignol	pignol cécile
5	arnaud_f	ARNAUD Fabien
4	frossard_v	FROSSARD V
3	jenny_jp	JENNY Jean-Philippe
6	test-collec	Christine Plumejeaud-Perreau
7	admindemo	admindemo admindemo
\.


--
-- Name: acllogin_acllogin_id_seq; Type: SEQUENCE SET; Schema: gacl; Owner: collec
--

SELECT pg_catalog.setval('acllogin_acllogin_id_seq', 7, true);


--
-- Data for Name: acllogingroup; Type: TABLE DATA; Schema: gacl; Owner: collec
--

COPY acllogingroup (acllogin_id, aclgroup_id) FROM stdin;
1	1
1	22
1	23
1	24
1	25
2	22
2	25
2	24
2	23
2	31
5	32
4	32
3	32
6	22
7	31
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: gacl; Owner: collec
--

COPY log (log_id, login, nom_module, log_date, commentaire, ipaddress) FROM stdin;
1	unknown	col-default	2017-02-28 15:32:09	ok	10.4.2.103
2	unknown	col-default	2017-02-28 15:45:27	ok	10.4.2.103
3	unknown	col-default	2017-02-28 15:46:31	ok	10.4.2.103
4	unknown	col-default	2017-02-28 16:07:26	ok	10.4.2.103
5	unknown	col-default	2017-02-28 16:16:38	ok	10.4.2.103
6	unknown	col-connexion	2017-02-28 16:16:42	ok	10.4.2.103
7	admin	col-connexion	2017-02-28 16:19:11	db-ok	10.4.2.103
8	admin	col-default	2017-02-28 16:19:11	ok	10.4.2.103
9	admin	col-loginChangePassword	2017-02-28 16:22:49	ok	10.4.2.103
10	admin	col-loginChangePasswordExec	2017-02-28 16:23:48	ok	10.4.2.103
11	admin	col-password_change	2017-02-28 16:23:48	ip:10.4.2.103	10.4.2.103
12	admin	col-default	2017-02-28 16:30:13	ok	10.4.2.103
13	admin	col-disconnect	2017-02-28 16:30:17	ok	10.4.2.103
14	unknown	col-connexion	2017-02-28 16:30:24	ok	10.4.2.103
15	admin	col-connexion	2017-02-28 16:30:48	db-ok	10.4.2.103
16	admin	col-default	2017-02-28 16:30:48	ok	10.4.2.103
17	admin	col-disconnect	2017-02-28 16:32:46	ok	10.4.2.103
18	unknown	col-connexion	2017-02-28 16:32:54	ok	10.4.2.103
19	admin	col-connexion	2017-02-28 16:33:01	db-ok	10.4.2.103
20	admin	col-default	2017-02-28 16:33:01	ok	10.4.2.103
21	admin	col-loginChangePassword	2017-02-28 16:33:09	ok	10.4.2.103
22	admin	col-loginChangePasswordExec	2017-02-28 16:33:39	ok	10.4.2.103
23	admin	col-password_change	2017-02-28 16:33:39	ip:10.4.2.103	10.4.2.103
24	admin	col-default	2017-02-28 16:34:20	ok	10.4.2.103
25	unknown	col-default	2017-02-28 16:36:10	ok	10.4.2.103
26	admin	col-groupList	2017-02-28 16:51:40	ok	10.4.2.103
27	unknown	col-disconnect	2017-02-28 17:58:14	ok	10.4.2.103
28	unknown	col-connexion	2017-02-28 17:58:17	ok	10.4.2.103
29	admin	col-connexion	2017-02-28 17:58:23	db-ko	10.4.2.103
30	unknown	col-default	2017-02-28 17:58:23	ok	10.4.2.103
31	unknown	col-connexion	2017-02-28 18:12:02	ok	10.4.2.103
32	admin	col-connexion	2017-02-28 18:12:08	db-ko	10.4.2.103
33	unknown	col-default	2017-02-28 18:12:08	ok	10.4.2.103
34	unknown	col-connexion	2017-02-28 18:12:13	ok	10.4.2.103
35	admin	col-connexion	2017-02-28 18:12:21	db-ok	10.4.2.103
36	admin	col-connexion	2017-02-28 18:12:30	ok	10.4.2.103
37	admin	col-disconnect	2017-02-28 18:12:45	ok	10.4.2.103
38	unknown	col-connexion	2017-02-28 18:12:52	ok	10.4.2.103
39	admin	col-connexion	2017-02-28 18:13:03	db-ok	10.4.2.103
40	admin	col-default	2017-02-28 18:14:19	ok	10.4.2.103
41	admin	col-disconnect	2017-02-28 18:14:33	ok	10.4.2.103
42	unknown	col-connexion	2017-02-28 18:14:36	ok	10.4.2.103
43	admin	col-connexion	2017-02-28 18:14:47	db-ok	10.4.2.103
44	admin	col-default	2017-02-28 18:14:47	ok	10.4.2.103
45	unknown	col-disconnect	2017-03-01 09:51:32	ok	10.4.2.103
46	unknown	col-connexion	2017-03-01 09:51:36	ok	10.4.2.103
47	admin	col-connexion	2017-03-01 09:51:40	db-ok	10.4.2.103
48	admin	col-default	2017-03-01 09:51:40	ok	10.4.2.103
49	admin	col-disconnect	2017-03-01 09:52:38	ok	10.4.2.103
50	unknown	col-connexion	2017-03-01 09:52:42	ok	10.4.2.103
51	admin	col-connexion	2017-03-01 09:52:45	db-ok	10.4.2.103
52	admin	col-default	2017-03-01 09:58:42	ok	10.4.2.103
53	admin	col-disconnect	2017-03-01 09:58:49	ok	10.4.2.103
54	unknown	col-connexion	2017-03-01 09:58:55	ok	10.4.2.103
55	admin	col-connexion	2017-03-01 09:58:58	db-ok	10.4.2.103
56	admin	col-default	2017-03-01 10:00:02	ok	10.4.2.103
57	admin	col-disconnect	2017-03-01 10:00:05	ok	10.4.2.103
58	unknown	col-connexion	2017-03-01 10:00:10	ok	10.4.2.103
59	admin	col-connexion	2017-03-01 10:00:14	db-ok	10.4.2.103
60	admin	col-default	2017-03-01 10:00:14	ok	10.4.2.103
61	unknown	col-default	2017-03-02 12:05:47	ok	10.4.2.103
62	unknown	col-default	2017-04-18 13:36:19	ok	10.4.2.103
63	unknown	col-connexion	2017-04-18 13:36:23	ok	10.4.2.103
64	admin	col-connexion	2017-04-18 13:36:44	db-ok	10.4.2.103
65	admin	col-default	2017-04-18 13:36:44	ok	10.4.2.103
66	admin	col-containerList	2017-04-18 13:36:50	droitko	10.4.2.103
67	admin	col-droitko	2017-04-18 13:36:50	ok	10.4.2.103
68	admin	col-containerList	2017-04-18 13:36:54	droitko	10.4.2.103
69	admin	col-droitko	2017-04-18 13:36:54	ok	10.4.2.103
70	admin	col-sampleList	2017-04-18 13:36:55	droitko	10.4.2.103
71	admin	col-droitko	2017-04-18 13:36:55	ok	10.4.2.103
72	admin	col-loginList	2017-04-18 13:37:00	ok	10.4.2.103
73	admin	col-groupList	2017-04-18 13:37:05	ok	10.4.2.103
74	admin	col-phpinfo	2017-04-18 13:37:11	ok	10.4.2.103
75	admin	col-groupList	2017-04-18 13:37:13	ok	10.4.2.103
76	admin	col-administration	2017-04-18 13:37:16	ok	10.4.2.103
77	admin	col-aclloginList	2017-04-18 13:37:19	ok	10.4.2.103
78	admin	col-administration	2017-04-18 13:37:22	ok	10.4.2.103
79	admin	col-administration	2017-04-18 13:37:24	ok	10.4.2.103
80	admin	col-appliList	2017-04-18 13:37:26	ok	10.4.2.103
81	admin	col-appliDisplay	2017-04-18 13:37:34	ok	10.4.2.103
82	admin	col-acoChange	2017-04-18 13:37:39	ok	10.4.2.103
83	admin	col-sampleList	2017-04-18 13:37:53	droitko	10.4.2.103
84	admin	col-droitko	2017-04-18 13:37:53	ok	10.4.2.103
85	admin	col-sampleList	2017-04-18 13:37:56	droitko	10.4.2.103
86	admin	col-droitko	2017-04-18 13:37:56	ok	10.4.2.103
87	admin	col-sampleList	2017-04-18 13:38:01	droitko	10.4.2.103
88	admin	col-droitko	2017-04-18 13:38:01	ok	10.4.2.103
89	admin	col-sampleList	2017-04-18 13:38:15	droitko	10.4.2.103
90	admin	col-droitko	2017-04-18 13:38:15	ok	10.4.2.103
91	admin	col-containerList	2017-04-18 13:38:20	droitko	10.4.2.103
92	admin	col-droitko	2017-04-18 13:38:20	ok	10.4.2.103
93	unknown	col-appliList	2017-04-18 14:12:46	nologin	10.4.2.103
94	admin	col-connexion	2017-04-18 14:12:49	db-ok	10.4.2.103
95	admin	col-appliList	2017-04-18 14:12:49	ok	10.4.2.103
96	admin	col-appliDisplay	2017-04-18 14:13:00	ok	10.4.2.103
97	admin	col-acoChange	2017-04-18 14:13:43	ok	10.4.2.103
98	admin	col-acoWrite	2017-04-18 14:14:06	ok	10.4.2.103
99	admin	col-Aclaco-write	2017-04-18 14:14:06	2	10.4.2.103
100	admin	col-appliDisplay	2017-04-18 14:14:06	ok	10.4.2.103
101	admin	col-acoChange	2017-04-18 14:14:08	ok	10.4.2.103
102	admin	col-acoWrite	2017-04-18 14:14:15	ok	10.4.2.103
103	admin	col-Aclaco-write	2017-04-18 14:14:15	3	10.4.2.103
104	admin	col-appliDisplay	2017-04-18 14:14:15	ok	10.4.2.103
105	admin	col-acoChange	2017-04-18 14:14:19	ok	10.4.2.103
106	admin	col-acoWrite	2017-04-18 14:14:24	ok	10.4.2.103
107	admin	col-Aclaco-write	2017-04-18 14:14:24	4	10.4.2.103
108	admin	col-appliDisplay	2017-04-18 14:14:24	ok	10.4.2.103
109	admin	col-acoChange	2017-04-18 14:14:28	ok	10.4.2.103
110	admin	col-acoWrite	2017-04-18 14:14:33	ok	10.4.2.103
111	admin	col-Aclaco-write	2017-04-18 14:14:33	5	10.4.2.103
112	admin	col-appliDisplay	2017-04-18 14:14:33	ok	10.4.2.103
113	admin	col-administration-connexion	2017-04-18 16:15:37	token-ok	10.4.2.103
114	admin	col-administration	2017-04-18 16:15:37	ok	10.4.2.103
115	admin	col-containerList	2017-04-18 16:15:45	ok	10.4.2.103
116	admin	col-containerTypeGetFromFamily	2017-04-18 16:15:46	ok	10.4.2.103
117	admin	col-phpinfo	2017-04-18 16:27:46	ok	10.4.2.103
118	admin	col-containerList	2017-04-18 16:29:16	ok	10.4.2.103
119	admin	col-containerTypeGetFromFamily	2017-04-18 16:29:16	ok	10.4.2.103
120	unknown	col-containerList	2017-04-19 10:10:50	nologin	10.4.2.103
121	admin	col-connexion	2017-04-19 10:10:51	db-ok	10.4.2.103
122	admin	col-containerList	2017-04-19 10:10:51	ok	10.4.2.103
123	admin	col-containerTypeGetFromFamily	2017-04-19 10:10:52	ok	10.4.2.103
124	admin	col-containerList	2017-04-19 10:14:41	ok	10.4.2.103
125	admin	col-containerTypeGetFromFamily	2017-04-19 10:14:41	ok	10.4.2.103
126	admin	col-objets	2017-04-19 10:14:47	ok	10.4.2.103
127	admin	col-containerList	2017-04-19 10:14:51	ok	10.4.2.103
128	admin	col-containerTypeGetFromFamily	2017-04-19 10:14:51	ok	10.4.2.103
129	admin	col-containerList	2017-04-19 10:14:53	ok	10.4.2.103
130	admin	col-containerTypeGetFromFamily	2017-04-19 10:14:54	ok	10.4.2.103
131	admin	col-containerChange	2017-04-19 10:14:56	ok	10.4.2.103
132	admin	col-containerTypeGetFromFamily	2017-04-19 10:14:57	ok	10.4.2.103
133	admin	col-containerTypeGetFromFamily	2017-04-19 10:15:40	ok	10.4.2.103
134	admin	col-containerWrite	2017-04-19 10:32:45	ok	10.4.2.103
135	admin	col-Container-write	2017-04-19 10:32:45	1	10.4.2.103
136	admin	col-containerDisplay	2017-04-19 10:32:45	ok	10.4.2.103
137	admin	col-sampleList-connexion	2017-04-19 14:03:12	token-ok	10.4.2.103
138	admin	col-sampleList	2017-04-19 14:03:12	ok	10.4.2.103
139	admin	col-sampleList	2017-04-19 14:03:15	ok	10.4.2.103
140	admin	col-sampleChange	2017-04-19 14:03:19	ok	10.4.2.103
141	admin	col-projectList	2017-04-19 14:04:27	ok	10.4.2.103
142	admin	col-projectChange	2017-04-19 14:04:32	ok	10.4.2.103
143	admin	col-projectWrite	2017-04-19 14:05:00	ok	10.4.2.103
144	admin	col-Project-write	2017-04-19 14:05:00	1	10.4.2.103
145	admin	col-projectList	2017-04-19 14:05:00	ok	10.4.2.103
146	admin	col-sampleList	2017-04-19 14:05:08	ok	10.4.2.103
147	admin	col-sampleChange	2017-04-19 14:05:10	ok	10.4.2.103
148	admin	col-parametre	2017-04-19 14:05:17	ok	10.4.2.103
149	admin	col-sampleTypeList	2017-04-19 14:05:32	ok	10.4.2.103
150	admin	col-sampleTypeChange	2017-04-19 14:05:59	ok	10.4.2.103
151	admin	col-sampleTypeWrite	2017-04-19 14:06:40	ok	10.4.2.103
152	admin	col-SampleType-write	2017-04-19 14:06:40	1	10.4.2.103
153	admin	col-sampleTypeList	2017-04-19 14:06:40	ok	10.4.2.103
154	admin	col-sampleList	2017-04-19 14:06:55	ok	10.4.2.103
155	admin	col-sampleChange	2017-04-19 14:06:58	ok	10.4.2.103
156	admin	col-parametre	2017-04-19 14:07:19	ok	10.4.2.103
157	admin	col-parametre	2017-04-19 14:07:20	ok	10.4.2.103
158	admin	col-samplingPlaceList	2017-04-19 14:07:23	ok	10.4.2.103
159	admin	col-samplingPlaceChange	2017-04-19 14:07:32	ok	10.4.2.103
160	admin	col-samplingPlaceWrite	2017-04-19 14:07:39	ok	10.4.2.103
161	admin	col-SamplingPlace-write	2017-04-19 14:07:39	1	10.4.2.103
162	admin	col-samplingPlaceList	2017-04-19 14:07:39	ok	10.4.2.103
163	admin	col-objets	2017-04-19 14:07:46	ok	10.4.2.103
164	admin	col-sampleList	2017-04-19 14:07:48	ok	10.4.2.103
165	admin	col-sampleChange	2017-04-19 14:07:51	ok	10.4.2.103
166	admin	col-sampleWrite	2017-04-19 14:08:30	ok	10.4.2.103
167	admin	col-Sample-write	2017-04-19 14:08:30	2	10.4.2.103
168	admin	col-sampleDisplay	2017-04-19 14:08:30	ok	10.4.2.103
169	admin	col-sampleList	2017-04-19 14:08:54	ok	10.4.2.103
170	admin	col-samplePrintLabel	2017-04-19 14:08:57	ok	10.4.2.103
171	admin	col-sampleList	2017-04-19 14:08:57	ok	10.4.2.103
172	admin	col-samplePrintLabel	2017-04-19 14:09:19	ok	10.4.2.103
173	admin	col-sampleList	2017-04-19 14:09:19	ok	10.4.2.103
174	admin	col-administration	2017-04-19 14:09:51	ok	10.4.2.103
175	admin	col-administration	2017-04-19 14:14:03	ok	10.4.2.103
176	admin	col-default	2017-04-19 14:14:10	ok	10.4.2.103
177	admin	col-disconnect	2017-04-19 14:14:13	ok	10.4.2.103
178	unknown	col-connexion	2017-04-19 14:14:15	ok	10.4.2.103
179	admin	col-connexion	2017-04-19 14:14:17	db-ok	10.4.2.103
180	admin	col-default	2017-04-19 14:14:17	ok	10.4.2.103
181	admin	col-sampleList	2017-04-19 14:14:20	ok	10.4.2.103
182	admin	col-sampleList	2017-04-19 14:14:22	ok	10.4.2.103
183	admin	col-samplePrintLabel	2017-04-19 14:14:27	ok	10.4.2.103
184	admin	col-sampleList	2017-04-19 14:14:27	ok	10.4.2.103
185	admin	col-sampleExportCSV	2017-04-19 14:14:33	ok	10.4.2.103
186	admin	col-sampleDisplay	2017-04-19 14:16:04	ok	10.4.2.103
187	admin	col-parametre-connexion	2017-04-19 16:38:04	token-ok	10.4.2.103
188	admin	col-parametre	2017-04-19 16:38:04	ok	10.4.2.103
189	admin	col-protocolList	2017-04-19 16:38:06	ok	10.4.2.103
190	admin	col-operationList	2017-04-19 16:38:12	ok	10.4.2.103
191	admin	col-objets	2017-04-19 17:01:30	ok	10.4.2.103
192	admin	col-containerList	2017-04-19 17:01:31	ok	10.4.2.103
193	admin	col-containerTypeGetFromFamily	2017-04-19 17:01:31	ok	10.4.2.103
194	admin	col-sampleList	2017-04-19 17:01:33	ok	10.4.2.103
195	admin	col-sampleList	2017-04-19 17:01:34	ok	10.4.2.103
196	admin	col-sampleDisplay	2017-04-19 17:01:45	ok	10.4.2.103
197	admin	col-sampleChange	2017-04-19 17:02:13	ok	10.4.2.103
198	unknown	col-sampleList	2017-04-20 17:02:44	nologin	10.4.2.103
199	admin	col-connexion	2017-04-20 17:02:45	db-ok	10.4.2.103
200	admin	col-sampleList	2017-04-20 17:02:45	ok	10.4.2.103
201	admin	col-sampleList	2017-04-20 17:02:47	ok	10.4.2.103
202	admin	col-samplePrintLabel	2017-04-20 17:02:54	ok	10.4.2.103
203	admin	col-sampleList	2017-04-20 17:02:54	ok	10.4.2.103
204	admin	col-parametre	2017-04-20 17:06:15	ok	10.4.2.103
205	admin	col-sampleTypeList	2017-04-20 17:06:28	ok	10.4.2.103
206	admin	col-parametre	2017-04-20 17:06:39	ok	10.4.2.103
207	admin	col-containerTypeList	2017-04-20 17:06:42	ok	10.4.2.103
208	admin	col-containerTypeChange	2017-04-20 17:06:45	ok	10.4.2.103
209	admin	col-containerTypeWrite	2017-04-20 17:07:03	ok	10.4.2.103
210	admin	col-ContainerType-write	2017-04-20 17:07:03	1	10.4.2.103
211	admin	col-containerTypeList	2017-04-20 17:07:03	ok	10.4.2.103
212	admin	col-objets	2017-04-20 17:07:08	ok	10.4.2.103
213	admin	col-sampleList	2017-04-20 17:07:45	ok	10.4.2.103
214	admin	col-samplePrintLabel	2017-04-20 17:07:50	ok	10.4.2.103
215	admin	col-sampleList	2017-04-20 17:09:50	ok	10.4.2.103
216	admin	col-parametre	2017-04-20 17:34:00	ok	10.4.2.103
217	admin	col-parametre	2017-04-20 17:34:02	ok	10.4.2.103
218	admin	col-parametre	2017-04-20 17:34:04	ok	10.4.2.103
219	admin	col-parametre	2017-04-20 17:34:05	ok	10.4.2.103
220	admin	col-parametre	2017-04-20 17:34:07	ok	10.4.2.103
221	admin	col-labelList	2017-04-20 17:34:13	ok	10.4.2.103
222	admin	col-labelChange	2017-04-20 17:34:17	ok	10.4.2.103
223	admin	col-sampleList	2017-04-20 17:50:59	ok	10.4.2.103
224	unknown	col-sampleDisplay	2017-04-21 08:52:01	nologin	10.4.2.103
225	admin	col-connexion	2017-04-21 08:52:03	db-ok	10.4.2.103
226	admin	col-sampleDisplay	2017-04-21 08:52:03	ok	10.4.2.103
227	admin	col-sampleList	2017-04-21 08:52:20	ok	10.4.2.103
228	admin	col-sampleList	2017-04-21 08:52:22	ok	10.4.2.103
229	admin	col-sampleDisplay	2017-04-21 08:52:24	ok	10.4.2.103
230	admin	col-containerList	2017-04-21 08:52:51	ok	10.4.2.103
231	admin	col-containerTypeGetFromFamily	2017-04-21 08:52:51	ok	10.4.2.103
232	admin	col-containerList	2017-04-21 08:52:53	ok	10.4.2.103
233	admin	col-containerTypeGetFromFamily	2017-04-21 08:52:53	ok	10.4.2.103
234	admin	col-containerDisplay	2017-04-21 08:52:56	ok	10.4.2.103
235	admin	col-parametre	2017-04-21 08:53:22	ok	10.4.2.103
236	admin	col-containerTypeList	2017-04-21 08:53:26	ok	10.4.2.103
237	admin	col-containerTypeChange	2017-04-21 08:53:35	ok	10.4.2.103
238	admin	col-objets	2017-04-21 08:54:03	ok	10.4.2.103
239	admin	col-samplingPlaceList	2017-04-21 08:55:42	ok	10.4.2.103
240	admin	col-containerTypeList	2017-04-21 08:55:55	ok	10.4.2.103
241	admin	col-containerList	2017-04-21 08:56:19	ok	10.4.2.103
242	admin	col-containerTypeGetFromFamily	2017-04-21 08:56:19	ok	10.4.2.103
243	admin	col-sampleList	2017-04-21 08:57:08	ok	10.4.2.103
244	admin	col-samplePrintLabel	2017-04-21 08:57:19	ok	10.4.2.103
245	admin	col-sampleList	2017-04-21 09:03:04	ok	10.4.2.103
246	admin	col-sampleDisplay	2017-04-21 09:03:09	ok	10.4.2.103
247	admin	col-sampleTypeList	2017-04-21 09:03:18	ok	10.4.2.103
248	admin	col-sampleTypeChange	2017-04-21 09:03:25	ok	10.4.2.103
249	admin	col-parametre	2017-04-21 09:05:02	ok	10.4.2.103
250	admin	col-protocolList	2017-04-21 09:05:04	ok	10.4.2.103
251	admin	col-protocolChange	2017-04-21 09:05:07	ok	10.4.2.103
252	admin	col-parametre	2017-04-21 09:05:17	ok	10.4.2.103
253	admin	col-parametre	2017-04-21 09:05:19	ok	10.4.2.103
254	admin	col-operationList	2017-04-21 09:05:21	ok	10.4.2.103
255	admin	col-operationChange	2017-04-21 09:05:24	ok	10.4.2.103
256	admin	col-containerList	2017-04-21 09:07:18	ok	10.4.2.103
257	admin	col-containerTypeGetFromFamily	2017-04-21 09:07:19	ok	10.4.2.103
258	admin	col-objets	2017-04-21 09:07:19	ok	10.4.2.103
259	admin	col-sampleList	2017-04-21 09:07:22	ok	10.4.2.103
260	admin	col-sampleChange	2017-04-21 09:07:25	ok	10.4.2.103
261	admin	col-operationList	2017-04-21 09:11:26	ok	10.4.2.103
262	admin	col-operationChange	2017-04-21 09:11:30	ok	10.4.2.103
263	unknown	col-default	2017-04-25 13:28:18	ok	10.4.2.103
264	unknown	col-default	2017-04-25 13:28:25	ok	10.4.2.103
265	unknown	col-default	2017-04-25 13:30:13	ok	10.4.2.103
266	unknown	col-default	2017-04-25 13:30:41	ok	10.4.2.103
267	unknown	col-containerList	2017-04-25 13:30:58	nologin	10.4.2.103
268	admin	col-connexion	2017-04-25 13:31:00	db-ok	10.4.2.103
269	admin	col-containerList	2017-04-25 13:31:00	ok	10.4.2.103
270	admin	col-containerTypeGetFromFamily	2017-04-25 13:31:01	ok	10.4.2.103
271	admin	col-default	2017-04-25 13:33:15	ok	10.4.2.103
272	admin	col-default	2017-04-25 13:34:42	ok	10.4.2.103
273	admin	col-default	2017-04-25 13:37:15	ok	10.4.2.103
274	admin	col-default	2017-04-25 13:54:37	ok	10.4.2.103
275	admin	col-default	2017-04-25 13:58:10	ok	10.4.2.103
276	admin	col-default	2017-04-25 13:58:13	ok	10.4.2.103
277	admin	col-default	2017-04-25 14:04:06	ok	10.4.2.103
278	admin	col-default	2017-04-25 14:08:38	ok	10.4.2.103
279	admin	col-default	2017-04-25 14:08:48	ok	10.4.2.103
280	admin	col-default	2017-04-25 14:08:52	ok	10.4.2.103
281	admin	col-default	2017-04-25 14:11:46	ok	10.4.2.103
282	admin	col-default	2017-04-25 14:16:09	ok	10.4.2.103
283	admin	col-default	2017-04-25 14:17:12	ok	10.4.2.103
284	admin	col-containerList	2017-04-25 14:17:23	ok	10.4.2.103
285	admin	col-containerTypeGetFromFamily	2017-04-25 14:17:24	ok	10.4.2.103
286	admin	col-containerList	2017-04-25 14:17:26	ok	10.4.2.103
287	admin	col-containerTypeGetFromFamily	2017-04-25 14:17:26	ok	10.4.2.103
288	admin	col-objets	2017-04-25 14:18:49	ok	10.4.2.103
289	admin	col-objets	2017-04-25 14:19:47	ok	10.4.2.103
290	admin	col-default	2017-04-25 14:29:13	ok	10.4.2.103
291	admin	col-default	2017-04-25 14:29:22	ok	10.4.2.103
292	admin	col-default	2017-04-25 14:30:30	ok	10.4.2.103
293	admin	col-default	2017-04-25 14:30:33	ok	10.4.2.103
294	admin	col-default	2017-04-25 14:32:45	ok	10.4.2.103
295	admin	col-default	2017-04-25 14:33:33	ok	10.4.2.103
296	admin	col-default	2017-04-25 14:33:36	ok	10.4.2.103
297	admin	col-default	2017-04-25 14:36:15	ok	10.4.2.103
298	unknown	col-default	2017-06-07 13:48:07	ok	10.4.2.103
299	unknown	col-connexion	2017-06-07 13:48:12	ok	10.4.2.103
300	admin	col-connexion	2017-06-07 13:48:14	db-ok	10.4.2.103
301	admin	col-default	2017-06-07 13:48:14	ok	10.4.2.103
302	admin	col-sampleList	2017-06-07 13:48:17	ok	10.4.2.103
303	admin	col-sampleList	2017-06-07 13:48:20	ok	10.4.2.103
304	admin	col-administration-connexion	2017-06-07 17:50:16	token-ok	10.4.2.103
305	admin	col-administration	2017-06-07 17:50:16	ok	10.4.2.103
306	unknown	col-default	2017-06-13 09:21:56	ok	10.4.2.103
307	unknown	col-default	2017-06-13 09:28:39	ok	10.4.2.103
308	unknown	col-connexion	2017-06-13 09:28:42	ok	10.4.2.103
309	administrateur	col-connexion	2017-06-13 09:30:33	db-ko	10.4.2.103
310	unknown	col-default	2017-06-13 09:30:33	ok	10.4.2.103
311	unknown	col-containerList	2017-06-13 09:30:39	nologin	10.4.2.103
312	admin	col-connexion	2017-06-13 09:30:56	db-ok	10.4.2.103
313	admin	col-containerList	2017-06-13 09:30:56	ok	10.4.2.103
314	admin	col-containerTypeGetFromFamily	2017-06-13 09:30:57	ok	10.4.2.103
315	admin	col-administration	2017-06-13 09:32:05	ok	10.4.2.103
316	admin	col-groupList	2017-06-13 09:32:12	ok	10.4.2.103
317	unknown	col-labelList	2017-06-13 14:12:31	nologin	10.4.2.103
318	admin	col-connexion	2017-06-13 14:12:33	db-ok	10.4.2.103
319	admin	col-labelList	2017-06-13 14:12:33	ok	10.4.2.103
320	admin	col-labelChange	2017-06-13 14:12:36	ok	10.4.2.103
321	unknown	col-default	2017-06-13 14:51:59	ok	10.4.2.103
322	unknown	col-default	2017-06-13 14:52:04	ok	10.4.2.103
323	unknown	col-default	2017-06-13 14:52:16	ok	10.4.2.103
324	unknown	col-default	2017-06-13 14:52:18	ok	10.4.2.103
325	unknown	col-default	2017-06-13 14:53:22	ok	10.4.2.103
326	unknown	col-default	2017-06-13 15:05:10	ok	10.4.2.103
327	admin	col-connexion-connexion	2017-06-13 15:05:12	token-ok	10.4.2.103
328	admin	col-connexion	2017-06-13 15:05:12	ok	10.4.2.103
329	admin	col-sampleList	2017-06-13 15:05:20	ok	10.4.2.103
330	admin	col-connexion	2017-06-13 15:05:24	ok	10.4.2.103
331	admin	col-containerList	2017-06-13 15:05:26	ok	10.4.2.103
332	admin	col-containerTypeGetFromFamily	2017-06-13 15:05:27	ok	10.4.2.103
333	admin	col-connexion	2017-06-13 15:05:29	ok	10.4.2.103
334	admin	col-objets	2017-06-13 15:05:34	ok	10.4.2.103
335	admin	col-sampleList	2017-06-13 15:05:38	ok	10.4.2.103
336	admin	col-sampleList	2017-06-13 15:19:30	ok	10.4.2.103
337	admin	col-containerList	2017-06-13 15:20:10	ok	10.4.2.103
338	admin	col-containerTypeGetFromFamily	2017-06-13 15:20:11	ok	10.4.2.103
339	unknown	col-default	2017-06-13 15:44:42	ok	77.154.204.128
340	unknown	col-default	2017-06-13 15:45:12	ok	193.48.127.14
341	unknown	col-containerList	2017-06-13 15:45:31	nologin	193.48.127.14
342	admin	col-loginList	2017-06-13 15:46:02	ok	10.4.2.103
343	admin	col-loginChange	2017-06-13 15:46:06	ok	10.4.2.103
344	admin	col-loginWrite	2017-06-13 15:49:57	ok	10.4.2.103
345	admin	col-LoginGestion-write	2017-06-13 15:49:57	3	10.4.2.103
346	admin	col-loginList	2017-06-13 15:49:57	ok	10.4.2.103
347	admin	col-groupList	2017-06-13 15:50:23	ok	10.4.2.103
348	admin	col-groupList	2017-06-13 15:50:55	ok	10.4.2.103
349	admin	col-administration	2017-06-13 15:51:02	ok	10.4.2.103
350	admin	col-appliList	2017-06-13 15:51:07	ok	10.4.2.103
351	admin	col-appliDisplay	2017-06-13 15:51:24	ok	10.4.2.103
352	admin	col-acoChange	2017-06-13 15:51:30	ok	10.4.2.103
353	admin	col-appliDisplay	2017-06-13 15:51:38	ok	10.4.2.103
354	admin	col-appliList	2017-06-13 15:51:41	ok	10.4.2.103
355	admin	col-appliDisplay	2017-06-13 15:51:43	ok	10.4.2.103
356	admin	col-acoChange	2017-06-13 15:51:46	ok	10.4.2.103
357	admin	col-appliDisplay	2017-06-13 15:51:56	ok	10.4.2.103
358	admin	col-appliList	2017-06-13 15:51:59	ok	10.4.2.103
359	admin	col-appliDisplay	2017-06-13 15:52:01	ok	10.4.2.103
360	admin	col-acoChange	2017-06-13 15:52:04	ok	10.4.2.103
361	admin	col-loginList	2017-06-13 15:56:52	ok	10.4.2.103
362	admin	col-loginChange	2017-06-13 15:56:55	ok	10.4.2.103
363	admin	col-aclloginList	2017-06-13 15:57:09	ok	10.4.2.103
364	admin	col-aclloginChange	2017-06-13 15:57:15	ok	10.4.2.103
365	admin	col-groupList	2017-06-13 15:57:31	ok	10.4.2.103
366	admin	col-groupChange	2017-06-13 16:00:50	ok	10.4.2.103
367	admin	col-groupList	2017-06-13 16:00:59	ok	10.4.2.103
368	admin	col-groupChange	2017-06-13 16:01:10	ok	10.4.2.103
369	admin	col-groupWrite	2017-06-13 16:01:15	ok	10.4.2.103
370	admin	col-Aclgroup-write	2017-06-13 16:01:15	22	10.4.2.103
371	admin	col-groupList	2017-06-13 16:01:15	ok	10.4.2.103
372	admin	col-connexion-connexion	2017-06-13 16:01:26	token-ok	10.4.2.103
373	admin	col-connexion	2017-06-13 16:01:26	ok	10.4.2.103
374	admin	col-disconnect	2017-06-13 16:01:28	ok	10.4.2.103
375	unknown	col-connexion	2017-06-13 16:01:30	ok	10.4.2.103
376	cpignol	col-connexion	2017-06-13 16:01:43	db-ok	10.4.2.103
377	cpignol	col-default	2017-06-13 16:01:43	ok	10.4.2.103
378	cpignol	col-containerList	2017-06-13 16:03:48	droitko	10.4.2.103
379	cpignol	col-droitko	2017-06-13 16:03:48	ok	10.4.2.103
380	cpignol	col-sampleList	2017-06-13 16:03:52	droitko	10.4.2.103
381	cpignol	col-droitko	2017-06-13 16:03:52	ok	10.4.2.103
382	admin	col-groupChange	2017-06-13 16:04:12	ok	10.4.2.103
383	admin	col-groupWrite	2017-06-13 16:04:17	ok	10.4.2.103
384	admin	col-Aclgroup-write	2017-06-13 16:04:17	27	10.4.2.103
385	admin	col-groupList	2017-06-13 16:04:17	ok	10.4.2.103
386	cpignol	col-disconnect	2017-06-13 16:04:25	ok	10.4.2.103
387	unknown	col-connexion	2017-06-13 16:04:27	ok	10.4.2.103
388	cpignol	col-connexion	2017-06-13 16:04:38	db-ok	10.4.2.103
389	cpignol	col-default	2017-06-13 16:04:38	ok	10.4.2.103
390	cpignol	col-containerList	2017-06-13 16:04:42	droitko	10.4.2.103
391	cpignol	col-droitko	2017-06-13 16:04:42	ok	10.4.2.103
392	admin	col-groupChange	2017-06-13 16:04:48	ok	10.4.2.103
393	admin	col-groupWrite	2017-06-13 16:04:52	ok	10.4.2.103
394	admin	col-Aclgroup-write	2017-06-13 16:04:52	27	10.4.2.103
395	admin	col-groupList	2017-06-13 16:04:52	ok	10.4.2.103
396	admin	col-groupChange	2017-06-13 16:04:57	ok	10.4.2.103
397	admin	col-groupWrite	2017-06-13 16:05:01	ok	10.4.2.103
398	admin	col-Aclgroup-write	2017-06-13 16:05:01	1	10.4.2.103
399	admin	col-groupList	2017-06-13 16:05:01	ok	10.4.2.103
400	cpignol	col-disconnect	2017-06-13 16:05:06	ok	10.4.2.103
401	unknown	col-connexion	2017-06-13 16:05:07	ok	10.4.2.103
402	cpignol	col-connexion	2017-06-13 16:05:18	db-ok	10.4.2.103
403	cpignol	col-default	2017-06-13 16:05:18	ok	10.4.2.103
404	unknown	col-default	2017-06-13 16:46:49	ok	10.4.2.103
405	admin	col-connexion-connexion	2017-06-13 16:46:53	token-ok	10.4.2.103
406	admin	col-connexion	2017-06-13 16:46:53	ok	10.4.2.103
407	admin	col-administration	2017-06-13 16:46:56	ok	10.4.2.103
408	admin	col-administration	2017-06-13 16:46:58	ok	10.4.2.103
409	admin	col-groupList	2017-06-13 16:47:05	ok	10.4.2.103
410	admin	col-groupChange	2017-06-13 16:47:32	ok	10.4.2.103
411	admin	col-groupDelete	2017-06-13 16:47:40	ok	10.4.2.103
412	admin	col-groupChange	2017-06-13 16:47:40	ok	10.4.2.103
413	admin	col-groupDelete	2017-06-13 16:49:00	ok	10.4.2.103
414	admin	col-Aclgroup-delete	2017-06-13 16:49:00	26	10.4.2.103
415	admin	col-groupList	2017-06-13 16:49:00	ok	10.4.2.103
416	admin	col-groupChange	2017-06-13 16:49:21	ok	10.4.2.103
417	admin	col-groupWrite	2017-06-13 16:49:30	ok	10.4.2.103
418	admin	col-Aclgroup-write	2017-06-13 16:49:30	25	10.4.2.103
419	admin	col-groupList	2017-06-13 16:49:30	ok	10.4.2.103
420	admin	col-groupChange	2017-06-13 16:49:34	ok	10.4.2.103
421	admin	col-groupWrite	2017-06-13 16:49:38	ok	10.4.2.103
422	admin	col-Aclgroup-write	2017-06-13 16:49:38	24	10.4.2.103
423	admin	col-groupList	2017-06-13 16:49:38	ok	10.4.2.103
424	admin	col-groupChange	2017-06-13 16:49:46	ok	10.4.2.103
425	admin	col-groupWrite	2017-06-13 16:49:50	ok	10.4.2.103
426	admin	col-Aclgroup-write	2017-06-13 16:49:50	1	10.4.2.103
427	admin	col-groupList	2017-06-13 16:49:50	ok	10.4.2.103
428	unknown	col-disconnect	2017-06-13 16:49:56	ok	10.4.2.103
429	unknown	col-connexion	2017-06-13 16:49:58	ok	10.4.2.103
430	cpignol	col-connexion	2017-06-13 16:50:07	db-ok	10.4.2.103
431	cpignol	col-default	2017-06-13 16:50:07	ok	10.4.2.103
432	cpignol	col-containerList	2017-06-13 16:50:11	ok	10.4.2.103
433	cpignol	col-containerTypeGetFromFamily	2017-06-13 16:50:11	ok	10.4.2.103
434	admin	col-groupChange	2017-06-13 16:50:28	ok	10.4.2.103
435	admin	col-groupWrite	2017-06-13 16:50:31	ok	10.4.2.103
436	admin	col-Aclgroup-write	2017-06-13 16:50:31	23	10.4.2.103
437	admin	col-groupList	2017-06-13 16:50:31	ok	10.4.2.103
438	unknown	col-containerList	2017-06-15 16:42:19	nologin	10.4.2.103
439	admin	col-connexion	2017-06-15 16:42:23	db-ok	10.4.2.103
440	admin	col-containerList	2017-06-15 16:42:23	ok	10.4.2.103
441	admin	col-containerTypeGetFromFamily	2017-06-15 16:42:24	ok	10.4.2.103
442	admin	col-containerFamilyList	2017-06-15 16:42:34	ok	10.4.2.103
443	admin	col-containerFamilyChange	2017-06-15 16:51:01	ok	10.4.2.103
444	admin	col-containerFamilyList	2017-06-15 16:51:04	ok	10.4.2.103
445	admin	col-parametre	2017-06-15 16:52:18	ok	10.4.2.103
446	admin	col-projectList	2017-06-15 16:52:24	ok	10.4.2.103
447	admin	col-projectChange	2017-06-15 16:52:35	ok	10.4.2.103
448	admin	col-projectList	2017-06-15 16:52:48	ok	10.4.2.103
449	admin	col-protocolList	2017-06-15 16:53:01	ok	10.4.2.103
450	admin	col-projectList	2017-06-15 16:53:14	ok	10.4.2.103
451	admin	col-appliList	2017-06-15 16:53:53	ok	10.4.2.103
452	admin	col-appliDisplay	2017-06-15 16:54:00	ok	10.4.2.103
453	admin	col-appliList	2017-06-15 16:54:04	ok	10.4.2.103
454	admin	col-appliDisplay	2017-06-15 16:54:07	ok	10.4.2.103
455	admin	col-appliList	2017-06-15 16:54:20	ok	10.4.2.103
456	admin	col-appliDisplay	2017-06-15 16:54:27	ok	10.4.2.103
457	admin	col-appliChange	2017-06-15 16:54:32	ok	10.4.2.103
458	admin	col-appliDelete	2017-06-15 17:01:03	ok	10.4.2.103
459	admin	col-appliChange	2017-06-15 17:01:03	ok	10.4.2.103
460	admin	col-appliDelete	2017-06-15 17:05:21	ok	10.4.2.103
461	admin	col-Aclappli-delete	2017-06-15 17:05:21	2	10.4.2.103
462	admin	col-appliList	2017-06-15 17:05:21	ok	10.4.2.103
463	admin	col-default	2017-06-15 17:05:35	ok	10.4.2.103
464	admin	col-projectList	2017-06-15 17:05:41	ok	10.4.2.103
465	admin	col-projectList	2017-06-15 17:06:01	ok	10.4.2.103
466	admin	col-projectChange	2017-06-15 17:06:04	ok	10.4.2.103
467	admin	col-administration	2017-06-15 17:06:29	ok	10.4.2.103
468	admin	col-administration	2017-06-15 17:06:32	ok	10.4.2.103
469	admin	col-appliList	2017-06-15 17:06:35	ok	10.4.2.103
470	admin	col-appliChange	2017-06-15 17:06:56	ok	10.4.2.103
471	admin	col-appliWrite	2017-06-15 17:08:05	ok	10.4.2.103
472	admin	col-Aclappli-write	2017-06-15 17:08:05	3	10.4.2.103
473	admin	col-appliDisplay	2017-06-15 17:08:05	ok	10.4.2.103
474	admin	col-acoChange	2017-06-15 17:09:23	ok	10.4.2.103
475	admin	col-default	2017-06-15 17:09:47	ok	10.4.2.103
476	admin	col-appliList	2017-06-15 17:09:56	ok	10.4.2.103
477	admin	col-appliDisplay	2017-06-15 17:10:13	ok	10.4.2.103
478	admin	col-acoChange	2017-06-15 17:10:18	ok	10.4.2.103
479	admin	col-acoWrite	2017-06-15 17:10:53	ok	10.4.2.103
480	admin	col-Aclaco-write	2017-06-15 17:10:53	11	10.4.2.103
481	admin	col-appliDisplay	2017-06-15 17:10:53	ok	10.4.2.103
482	admin	col-acoChange	2017-06-15 17:10:57	ok	10.4.2.103
483	admin	col-acoWrite	2017-06-15 17:11:06	ok	10.4.2.103
484	admin	col-Aclaco-write	2017-06-15 17:11:06	12	10.4.2.103
485	admin	col-appliDisplay	2017-06-15 17:11:06	ok	10.4.2.103
486	admin	col-acoChange	2017-06-15 17:11:09	ok	10.4.2.103
487	admin	col-acoWrite	2017-06-15 17:11:54	ok	10.4.2.103
488	admin	col-Aclaco-write	2017-06-15 17:11:54	13	10.4.2.103
489	admin	col-appliDisplay	2017-06-15 17:11:54	ok	10.4.2.103
490	admin	col-acoChange	2017-06-15 17:12:01	ok	10.4.2.103
491	admin	col-acoWrite	2017-06-15 17:12:08	ok	10.4.2.103
492	admin	col-Aclaco-write	2017-06-15 17:12:08	14	10.4.2.103
493	admin	col-appliDisplay	2017-06-15 17:12:08	ok	10.4.2.103
494	admin	col-acoChange	2017-06-15 17:12:11	ok	10.4.2.103
495	admin	col-acoWrite	2017-06-15 17:12:16	ok	10.4.2.103
496	admin	col-Aclaco-write	2017-06-15 17:12:16	15	10.4.2.103
497	admin	col-appliDisplay	2017-06-15 17:12:16	ok	10.4.2.103
498	admin	col-groupList	2017-06-15 17:13:41	ok	10.4.2.103
499	admin	col-groupChange	2017-06-15 17:13:49	ok	10.4.2.103
500	admin	col-groupWrite	2017-06-15 17:15:10	ok	10.4.2.103
501	admin	col-Aclgroup-write	2017-06-15 17:15:10	31	10.4.2.103
502	admin	col-groupList	2017-06-15 17:15:10	ok	10.4.2.103
503	admin	col-groupChange	2017-06-15 17:15:51	ok	10.4.2.103
504	admin	col-groupList	2017-06-15 17:16:45	ok	10.4.2.103
505	admin	col-groupChange	2017-06-15 17:16:55	ok	10.4.2.103
506	admin	col-groupList	2017-06-15 17:17:01	ok	10.4.2.103
507	admin	col-aclloginList	2017-06-15 17:17:16	ok	10.4.2.103
508	admin	col-aclloginChange	2017-06-15 17:17:19	ok	10.4.2.103
509	admin	col-aclloginList	2017-06-15 17:17:35	ok	10.4.2.103
510	admin	col-appliList	2017-06-15 17:17:39	ok	10.4.2.103
511	admin	col-appliChange	2017-06-15 17:17:46	ok	10.4.2.103
512	admin	col-appliWrite	2017-06-15 17:17:51	ok	10.4.2.103
513	admin	col-Aclappli-write	2017-06-15 17:17:51	3	10.4.2.103
514	admin	col-appliDisplay	2017-06-15 17:17:51	ok	10.4.2.103
515	admin	col-acoChange	2017-06-15 17:18:06	ok	10.4.2.103
516	admin	col-acoWrite	2017-06-15 17:18:56	ok	10.4.2.103
517	admin	col-Aclaco-write	2017-06-15 17:18:56	11	10.4.2.103
518	admin	col-appliDisplay	2017-06-15 17:18:56	ok	10.4.2.103
519	admin	col-acoChange	2017-06-15 17:19:18	ok	10.4.2.103
520	admin	col-appliList	2017-06-15 17:19:34	ok	10.4.2.103
521	admin	col-aclloginList	2017-06-15 17:19:43	ok	10.4.2.103
522	admin	col-aclloginChange	2017-06-15 17:19:46	ok	10.4.2.103
523	admin	col-aclloginList	2017-06-15 17:19:52	ok	10.4.2.103
524	admin	col-groupList	2017-06-15 17:20:05	ok	10.4.2.103
525	admin	col-aclloginList	2017-06-15 17:20:33	ok	10.4.2.103
526	admin	col-aclloginChange	2017-06-15 17:20:36	ok	10.4.2.103
527	admin	col-groupList	2017-06-15 17:20:43	ok	10.4.2.103
528	admin	col-groupChange	2017-06-15 17:20:56	ok	10.4.2.103
529	admin	col-groupList	2017-06-15 17:21:09	ok	10.4.2.103
530	admin	col-disconnect	2017-06-15 17:24:21	ok	10.4.2.103
531	unknown	col-connexion	2017-06-15 17:24:24	ok	10.4.2.103
532	cpignol	col-connexion	2017-06-15 17:24:36	db-ok	10.4.2.103
533	cpignol	col-default	2017-06-15 17:24:36	ok	10.4.2.103
534	cpignol	col-parametre	2017-06-15 17:24:43	ok	10.4.2.103
535	cpignol	col-parametre	2017-06-15 17:24:47	ok	10.4.2.103
536	cpignol	col-parametre	2017-06-15 17:24:50	ok	10.4.2.103
537	cpignol	col-disconnect	2017-06-15 17:33:45	ok	10.4.2.103
538	unknown	col-connexion	2017-06-15 17:34:00	ok	10.4.2.103
539	admin	col-connexion	2017-06-15 17:34:03	db-ok	10.4.2.103
540	admin	col-default	2017-06-15 17:34:03	ok	10.4.2.103
541	admin	col-groupList	2017-06-15 17:34:14	ok	10.4.2.103
542	admin	col-appliList	2017-06-15 17:34:38	ok	10.4.2.103
543	admin	col-appliDisplay	2017-06-15 17:34:44	ok	10.4.2.103
544	admin	col-appliList	2017-06-15 17:34:47	ok	10.4.2.103
545	admin	col-appliDisplay	2017-06-15 17:34:50	ok	10.4.2.103
546	admin	col-acoChange	2017-06-15 17:34:54	ok	10.4.2.103
547	admin	col-appliDisplay	2017-06-15 17:35:16	ok	10.4.2.103
548	admin	col-acoChange	2017-06-15 17:35:23	ok	10.4.2.103
549	admin	col-acoWrite	2017-06-15 17:35:37	ok	10.4.2.103
550	admin	col-Aclaco-write	2017-06-15 17:35:37	12	10.4.2.103
551	admin	col-appliDisplay	2017-06-15 17:35:37	ok	10.4.2.103
552	admin	col-disconnect	2017-06-15 17:35:42	ok	10.4.2.103
553	unknown	col-connexion	2017-06-15 17:35:45	ok	10.4.2.103
554	cpignol	col-connexion	2017-06-15 17:36:00	db-ok	10.4.2.103
555	cpignol	col-default	2017-06-15 17:36:00	ok	10.4.2.103
556	cpignol	col-disconnect	2017-06-15 17:36:15	ok	10.4.2.103
557	unknown	col-connexion	2017-06-15 17:36:19	ok	10.4.2.103
558	admin	col-connexion	2017-06-15 17:36:22	db-ok	10.4.2.103
559	admin	col-default	2017-06-15 17:36:22	ok	10.4.2.103
560	admin	col-groupList	2017-06-15 17:36:35	ok	10.4.2.103
561	admin	col-appliList	2017-06-15 17:36:52	ok	10.4.2.103
562	admin	col-appliDisplay	2017-06-15 17:36:57	ok	10.4.2.103
563	admin	col-acoChange	2017-06-15 17:37:01	ok	10.4.2.103
564	admin	col-acoWrite	2017-06-15 17:37:18	ok	10.4.2.103
565	admin	col-Aclaco-write	2017-06-15 17:37:18	1	10.4.2.103
566	admin	col-appliDisplay	2017-06-15 17:37:18	ok	10.4.2.103
567	admin	col-disconnect	2017-06-15 17:37:22	ok	10.4.2.103
568	unknown	col-connexion	2017-06-15 17:37:26	ok	10.4.2.103
569	cpignol	col-connexion	2017-06-15 17:37:43	db-ok	10.4.2.103
570	cpignol	col-default	2017-06-15 17:37:43	ok	10.4.2.103
571	cpignol	col-appliList	2017-06-15 17:38:13	ok	10.4.2.103
572	cpignol	col-projectList	2017-06-15 17:38:45	ok	10.4.2.103
573	cpignol	col-groupList	2017-06-15 17:39:07	ok	10.4.2.103
574	cpignol	col-appliList	2017-06-15 17:39:17	ok	10.4.2.103
575	unknown	col-appliDisplay	2017-06-16 10:25:18	nologin	10.4.2.103
576	cpignol	col-connexion	2017-06-16 10:25:35	db-ok	10.4.2.103
577	cpignol	col-default	2017-06-16 10:25:35	ok	10.4.2.103
578	cpignol	zaalpes-disconnect	2017-06-16 10:26:56	ok	10.4.2.103
579	unknown	zaalpes-connexion	2017-06-16 10:26:59	ok	10.4.2.103
580	cpignol	zaalpes-connexion	2017-06-16 10:27:13	db-ok	10.4.2.103
581	cpignol	zaalpes-default	2017-06-16 10:27:13	ok	10.4.2.103
582	cpignol	zaalpes-groupList	2017-06-16 10:27:26	ok	10.4.2.103
583	cpignol	zaalpes-appliList	2017-06-16 10:27:53	ok	10.4.2.103
584	cpignol	zaalpes-appliDisplay	2017-06-16 10:27:57	ok	10.4.2.103
585	cpignol	zaalpes-acoChange	2017-06-16 10:28:04	ok	10.4.2.103
586	cpignol	zaalpes-appliDisplay	2017-06-16 10:28:12	ok	10.4.2.103
587	cpignol	zaalpes-acoChange	2017-06-16 10:28:22	ok	10.4.2.103
588	cpignol	zaalpes-appliDisplay	2017-06-16 10:28:30	ok	10.4.2.103
589	cpignol	zaalpes-acoChange	2017-06-16 10:28:34	ok	10.4.2.103
590	cpignol	zaalpes-acoWrite	2017-06-16 10:28:42	ok	10.4.2.103
591	cpignol	zaalpes-Aclaco-write	2017-06-16 10:28:42	15	10.4.2.103
592	cpignol	zaalpes-appliDisplay	2017-06-16 10:28:42	ok	10.4.2.103
593	cpignol	zaalpes-acoChange	2017-06-16 10:28:46	ok	10.4.2.103
594	cpignol	zaalpes-acoWrite	2017-06-16 10:28:50	ok	10.4.2.103
595	cpignol	zaalpes-Aclaco-write	2017-06-16 10:28:50	14	10.4.2.103
596	cpignol	zaalpes-appliDisplay	2017-06-16 10:28:50	ok	10.4.2.103
597	cpignol	zaalpes-acoChange	2017-06-16 10:28:54	ok	10.4.2.103
598	cpignol	zaalpes-acoWrite	2017-06-16 10:28:58	ok	10.4.2.103
599	cpignol	zaalpes-Aclaco-write	2017-06-16 10:28:58	13	10.4.2.103
600	cpignol	zaalpes-appliDisplay	2017-06-16 10:28:58	ok	10.4.2.103
601	cpignol	zaalpes-default	2017-06-16 10:30:45	ok	10.4.2.103
602	cpignol	zaalpes-disconnect	2017-06-16 10:30:50	ok	10.4.2.103
603	unknown	zaalpes-connexion	2017-06-16 10:30:54	ok	10.4.2.103
604	cpignol	zaalpes-connexion	2017-06-16 10:31:19	db-ok	10.4.2.103
605	cpignol	zaalpes-default	2017-06-16 10:31:19	ok	10.4.2.103
606	cpignol	zaalpes-containerList	2017-06-16 10:31:30	ok	10.4.2.103
607	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 10:31:31	ok	10.4.2.103
608	cpignol	zaalpes-parametre	2017-06-16 10:31:35	ok	10.4.2.103
609	cpignol	zaalpes-containerFamilyList	2017-06-16 10:31:39	ok	10.4.2.103
610	cpignol	zaalpes-containerFamilyChange	2017-06-16 10:31:42	ok	10.4.2.103
611	cpignol	zaalpes-containerFamilyList	2017-06-16 10:31:46	ok	10.4.2.103
612	cpignol	zaalpes-containerTypeList	2017-06-16 10:32:18	ok	10.4.2.103
613	cpignol	zaalpes-containerTypeChange	2017-06-16 10:33:38	ok	10.4.2.103
614	cpignol	zaalpes-containerTypeList	2017-06-16 10:33:50	ok	10.4.2.103
615	cpignol	zaalpes-storageConditionList	2017-06-16 10:33:57	ok	10.4.2.103
616	cpignol	zaalpes-storageConditionChange	2017-06-16 10:34:45	ok	10.4.2.103
617	cpignol	zaalpes-storageConditionWrite	2017-06-16 10:35:29	ok	10.4.2.103
618	cpignol	zaalpes-StorageCondition-write	2017-06-16 10:35:29	1	10.4.2.103
619	cpignol	zaalpes-storageConditionList	2017-06-16 10:35:29	ok	10.4.2.103
620	cpignol	zaalpes-storageConditionChange	2017-06-16 10:35:35	ok	10.4.2.103
621	cpignol	zaalpes-storageConditionWrite	2017-06-16 10:35:46	ok	10.4.2.103
622	cpignol	zaalpes-StorageCondition-write	2017-06-16 10:35:46	2	10.4.2.103
623	cpignol	zaalpes-storageConditionList	2017-06-16 10:35:46	ok	10.4.2.103
624	cpignol	zaalpes-storageConditionChange	2017-06-16 10:36:33	ok	10.4.2.103
625	cpignol	zaalpes-storageConditionList	2017-06-16 10:37:09	ok	10.4.2.103
626	cpignol	zaalpes-storageReasonList	2017-06-16 10:37:26	ok	10.4.2.103
627	cpignol	zaalpes-containerTypeList	2017-06-16 10:37:59	ok	10.4.2.103
628	cpignol	zaalpes-containerTypeChange	2017-06-16 10:38:10	ok	10.4.2.103
629	cpignol	zaalpes-containerTypeList	2017-06-16 10:38:34	ok	10.4.2.103
630	cpignol	zaalpes-containerTypeChange	2017-06-16 10:38:47	ok	10.4.2.103
631	cpignol	zaalpes-containerTypeList	2017-06-16 10:39:38	ok	10.4.2.103
632	cpignol	zaalpes-containerTypeChange	2017-06-16 10:39:40	ok	10.4.2.103
633	cpignol	zaalpes-containerTypeList	2017-06-16 10:44:27	ok	10.4.2.103
634	cpignol	zaalpes-containerTypeChange	2017-06-16 10:44:42	ok	10.4.2.103
635	cpignol	zaalpes-containerTypeWrite	2017-06-16 10:46:32	ok	10.4.2.103
636	cpignol	zaalpes-ContainerType-write	2017-06-16 10:46:32	6	10.4.2.103
637	cpignol	zaalpes-containerTypeList	2017-06-16 10:46:32	ok	10.4.2.103
638	cpignol	zaalpes-labelList	2017-06-16 10:46:43	ok	10.4.2.103
639	cpignol	zaalpes-labelChange	2017-06-16 10:46:49	ok	10.4.2.103
640	cpignol	zaalpes-labelList	2017-06-16 10:46:51	ok	10.4.2.103
641	cpignol	zaalpes-labelChange	2017-06-16 10:47:35	ok	10.4.2.103
642	cpignol	zaalpes-labelList	2017-06-16 10:47:49	ok	10.4.2.103
643	cpignol	zaalpes-labelChange	2017-06-16 10:47:51	ok	10.4.2.103
644	cpignol	zaalpes-labelList	2017-06-16 10:48:30	ok	10.4.2.103
645	cpignol	zaalpes-labelChange	2017-06-16 10:48:34	ok	10.4.2.103
646	cpignol	zaalpes-labelWrite	2017-06-16 11:02:45	ok	10.4.2.103
647	cpignol	zaalpes-Label-write	2017-06-16 11:02:45	2	10.4.2.103
648	cpignol	zaalpes-labelList	2017-06-16 11:02:45	ok	10.4.2.103
649	cpignol	zaalpes-labelChange	2017-06-16 11:02:58	ok	10.4.2.103
650	cpignol	zaalpes-labelWrite	2017-06-16 11:16:20	ok	10.4.2.103
651	cpignol	zaalpes-Label-write	2017-06-16 11:16:20	3	10.4.2.103
652	cpignol	zaalpes-labelList	2017-06-16 11:16:20	ok	10.4.2.103
653	cpignol	zaalpes-objectStatusList	2017-06-16 11:17:21	ok	10.4.2.103
654	cpignol	zaalpes-sampleTypeList	2017-06-16 11:17:32	ok	10.4.2.103
655	cpignol	zaalpes-sampleTypeChange	2017-06-16 11:17:55	ok	10.4.2.103
656	cpignol	zaalpes-parametre	2017-06-16 11:18:26	ok	10.4.2.103
657	cpignol	zaalpes-containerTypeList	2017-06-16 11:18:33	ok	10.4.2.103
658	cpignol	zaalpes-containerTypeChange	2017-06-16 11:18:49	ok	10.4.2.103
659	cpignol	zaalpes-containerTypeWrite	2017-06-16 11:20:57	ok	10.4.2.103
660	cpignol	zaalpes-ContainerType-write	2017-06-16 11:20:57	7	10.4.2.103
661	cpignol	zaalpes-containerTypeList	2017-06-16 11:20:57	ok	10.4.2.103
662	cpignol	zaalpes-containerTypeChange	2017-06-16 11:21:04	ok	10.4.2.103
663	cpignol	zaalpes-containerTypeWrite	2017-06-16 11:21:26	ok	10.4.2.103
664	cpignol	zaalpes-ContainerType-write	2017-06-16 11:21:26	6	10.4.2.103
665	cpignol	zaalpes-containerTypeList	2017-06-16 11:21:26	ok	10.4.2.103
666	cpignol	zaalpes-projectList	2017-06-16 11:23:32	ok	10.4.2.103
667	cpignol	zaalpes-projectChange-connexion	2017-06-16 13:48:50	token-ok	10.4.2.103
668	cpignol	zaalpes-projectChange	2017-06-16 13:48:50	ok	10.4.2.103
669	cpignol	zaalpes-projectWrite	2017-06-16 13:49:47	ok	10.4.2.103
670	cpignol	zaalpes-Project-write	2017-06-16 13:49:47	1	10.4.2.103
671	cpignol	zaalpes-projectList	2017-06-16 13:49:47	ok	10.4.2.103
672	cpignol	zaalpes-aclloginList	2017-06-16 13:49:54	ok	10.4.2.103
673	cpignol	zaalpes-groupList	2017-06-16 13:49:58	ok	10.4.2.103
674	cpignol	zaalpes-groupChange	2017-06-16 13:50:15	ok	10.4.2.103
675	cpignol	zaalpes-groupWrite	2017-06-16 13:51:03	ok	10.4.2.103
676	cpignol	zaalpes-Aclgroup-write	2017-06-16 13:51:03	32	10.4.2.103
677	cpignol	zaalpes-groupList	2017-06-16 13:51:03	ok	10.4.2.103
678	cpignol	zaalpes-aclloginList	2017-06-16 13:51:15	ok	10.4.2.103
679	cpignol	zaalpes-aclloginChange	2017-06-16 13:51:19	ok	10.4.2.103
680	cpignol	zaalpes-aclloginWrite	2017-06-16 13:52:52	ok	10.4.2.103
681	cpignol	zaalpes-Acllogin-write	2017-06-16 13:52:52	3	10.4.2.103
682	cpignol	zaalpes-aclloginList	2017-06-16 13:52:52	ok	10.4.2.103
683	cpignol	zaalpes-aclloginChange	2017-06-16 13:52:58	ok	10.4.2.103
684	cpignol	zaalpes-aclloginWrite	2017-06-16 13:53:26	ok	10.4.2.103
685	cpignol	zaalpes-Acllogin-write	2017-06-16 13:53:26	4	10.4.2.103
686	cpignol	zaalpes-aclloginList	2017-06-16 13:53:26	ok	10.4.2.103
687	cpignol	zaalpes-aclloginChange	2017-06-16 13:53:29	ok	10.4.2.103
688	cpignol	zaalpes-aclloginWrite	2017-06-16 13:54:19	ok	10.4.2.103
689	cpignol	zaalpes-Acllogin-write	2017-06-16 13:54:19	5	10.4.2.103
690	cpignol	zaalpes-aclloginList	2017-06-16 13:54:19	ok	10.4.2.103
691	cpignol	zaalpes-appliList	2017-06-16 13:54:39	ok	10.4.2.103
692	cpignol	zaalpes-appliDisplay	2017-06-16 13:54:43	ok	10.4.2.103
693	cpignol	zaalpes-acoChange	2017-06-16 13:54:56	ok	10.4.2.103
694	cpignol	zaalpes-acoWrite	2017-06-16 13:55:43	ok	10.4.2.103
695	cpignol	zaalpes-Aclaco-write	2017-06-16 13:55:43	15	10.4.2.103
696	cpignol	zaalpes-appliDisplay	2017-06-16 13:55:43	ok	10.4.2.103
697	cpignol	zaalpes-acoChange	2017-06-16 13:55:57	ok	10.4.2.103
698	cpignol	zaalpes-acoWrite	2017-06-16 13:56:02	ok	10.4.2.103
699	cpignol	zaalpes-Aclaco-write	2017-06-16 13:56:02	14	10.4.2.103
700	cpignol	zaalpes-appliDisplay	2017-06-16 13:56:02	ok	10.4.2.103
701	cpignol	zaalpes-acoChange	2017-06-16 13:56:04	ok	10.4.2.103
702	cpignol	zaalpes-appliDisplay	2017-06-16 13:56:08	ok	10.4.2.103
703	cpignol	zaalpes-acoChange	2017-06-16 13:57:48	ok	10.4.2.103
704	cpignol	zaalpes-acoWrite	2017-06-16 13:57:54	ok	10.4.2.103
705	cpignol	zaalpes-Aclaco-write	2017-06-16 13:57:54	13	10.4.2.103
706	cpignol	zaalpes-appliDisplay	2017-06-16 13:57:54	ok	10.4.2.103
707	cpignol	zaalpes-groupList	2017-06-16 13:58:05	ok	10.4.2.103
708	cpignol	zaalpes-groupChange	2017-06-16 13:58:46	ok	10.4.2.103
709	cpignol	zaalpes-groupWrite	2017-06-16 13:59:31	ok	10.4.2.103
710	cpignol	zaalpes-Aclgroup-write	2017-06-16 13:59:31	32	10.4.2.103
711	cpignol	zaalpes-groupList	2017-06-16 13:59:31	ok	10.4.2.103
712	cpignol	zaalpes-loginList	2017-06-16 14:00:15	ok	10.4.2.103
713	cpignol	zaalpes-aclloginList	2017-06-16 14:00:32	ok	10.4.2.103
714	cpignol	zaalpes-projectList-connexion	2017-06-16 15:15:49	token-ok	10.4.2.103
715	cpignol	zaalpes-projectList	2017-06-16 15:15:49	ok	10.4.2.103
716	cpignol	zaalpes-projectChange	2017-06-16 15:15:52	ok	10.4.2.103
717	cpignol	zaalpes-projectWrite	2017-06-16 15:17:29	ok	10.4.2.103
718	cpignol	zaalpes-Project-write	2017-06-16 15:17:29	1	10.4.2.103
719	cpignol	zaalpes-projectList	2017-06-16 15:17:29	ok	10.4.2.103
720	cpignol	zaalpes-loginList	2017-06-16 15:17:57	ok	10.4.2.103
721	cpignol	zaalpes-aclloginList	2017-06-16 15:18:08	ok	10.4.2.103
722	cpignol	zaalpes-loginList	2017-06-16 15:18:18	ok	10.4.2.103
723	cpignol	zaalpes-loginChange	2017-06-16 15:18:22	ok	10.4.2.103
724	cpignol	zaalpes-loginWrite	2017-06-16 15:21:42	ok	10.4.2.103
725	cpignol	zaalpes-LoginGestion-write	2017-06-16 15:21:42	4	10.4.2.103
726	cpignol	zaalpes-loginList	2017-06-16 15:21:42	ok	10.4.2.103
727	cpignol	zaalpes-aclloginList	2017-06-16 15:22:04	ok	10.4.2.103
728	cpignol	zaalpes-loginList	2017-06-16 15:22:16	ok	10.4.2.103
729	cpignol	zaalpes-loginChange	2017-06-16 15:22:19	ok	10.4.2.103
730	cpignol	zaalpes-loginWrite	2017-06-16 15:22:44	ok	10.4.2.103
731	cpignol	zaalpes-LoginGestion-write	2017-06-16 15:22:44	5	10.4.2.103
732	cpignol	zaalpes-loginList	2017-06-16 15:22:44	ok	10.4.2.103
733	cpignol	zaalpes-aclloginList	2017-06-16 15:23:55	ok	10.4.2.103
734	cpignol	zaalpes-loginList	2017-06-16 15:24:02	ok	10.4.2.103
735	cpignol	zaalpes-loginChange	2017-06-16 15:24:04	ok	10.4.2.103
736	cpignol	zaalpes-loginWrite	2017-06-16 15:24:23	ok	10.4.2.103
737	cpignol	zaalpes-LoginGestion-write	2017-06-16 15:24:23	6	10.4.2.103
738	cpignol	zaalpes-loginList	2017-06-16 15:24:23	ok	10.4.2.103
739	cpignol	zaalpes-containerList	2017-06-16 15:26:44	ok	10.4.2.103
740	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:26:45	ok	10.4.2.103
741	cpignol	zaalpes-containerChange	2017-06-16 15:26:51	ok	10.4.2.103
742	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:26:53	ok	10.4.2.103
743	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:28:11	ok	10.4.2.103
744	cpignol	zaalpes-containerWrite	2017-06-16 15:30:31	ok	10.4.2.103
745	cpignol	zaalpes-Container-write	2017-06-16 15:30:31	1	10.4.2.103
746	cpignol	zaalpes-containerDisplay	2017-06-16 15:30:31	ok	10.4.2.103
747	cpignol	zaalpes-containerChange	2017-06-16 15:31:10	ok	10.4.2.103
748	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:31:11	ok	10.4.2.103
749	cpignol	zaalpes-containerDisplay	2017-06-16 15:31:19	ok	10.4.2.103
750	cpignol	zaalpes-containerChange	2017-06-16 15:33:00	ok	10.4.2.103
751	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:33:02	ok	10.4.2.103
752	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:34:42	ok	10.4.2.103
753	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:34:49	ok	10.4.2.103
754	cpignol	zaalpes-containerWrite	2017-06-16 15:35:41	ok	10.4.2.103
755	cpignol	zaalpes-Container-write	2017-06-16 15:35:41	2	10.4.2.103
756	cpignol	zaalpes-containerDisplay	2017-06-16 15:35:41	ok	10.4.2.103
757	cpignol	zaalpes-containerChange	2017-06-16 15:36:10	ok	10.4.2.103
758	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:36:11	ok	10.4.2.103
759	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:36:41	ok	10.4.2.103
760	cpignol	zaalpes-containerWrite	2017-06-16 15:36:47	ok	10.4.2.103
761	cpignol	zaalpes-Container-write	2017-06-16 15:36:47	3	10.4.2.103
762	cpignol	zaalpes-containerDisplay	2017-06-16 15:36:47	ok	10.4.2.103
763	cpignol	zaalpes-containerList	2017-06-16 15:37:15	ok	10.4.2.103
764	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:37:17	ok	10.4.2.103
765	cpignol	zaalpes-containerList	2017-06-16 15:37:22	ok	10.4.2.103
766	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:37:23	ok	10.4.2.103
767	cpignol	zaalpes-containerDisplay	2017-06-16 15:37:30	ok	10.4.2.103
768	cpignol	zaalpes-containerList	2017-06-16 15:37:51	ok	10.4.2.103
769	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:37:52	ok	10.4.2.103
770	cpignol	zaalpes-containerDisplay	2017-06-16 15:37:54	ok	10.4.2.103
771	cpignol	zaalpes-containerList	2017-06-16 15:38:01	ok	10.4.2.103
772	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:38:03	ok	10.4.2.103
773	cpignol	zaalpes-containerDisplay	2017-06-16 15:38:15	ok	10.4.2.103
774	cpignol	zaalpes-containerChange	2017-06-16 15:38:19	ok	10.4.2.103
775	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:38:21	ok	10.4.2.103
776	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:38:53	ok	10.4.2.103
777	cpignol	zaalpes-containerWrite	2017-06-16 15:39:00	ok	10.4.2.103
778	cpignol	zaalpes-Container-write	2017-06-16 15:39:00	4	10.4.2.103
779	cpignol	zaalpes-containerDisplay	2017-06-16 15:39:00	ok	10.4.2.103
780	cpignol	zaalpes-containerList	2017-06-16 15:39:10	ok	10.4.2.103
781	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:39:11	ok	10.4.2.103
782	cpignol	zaalpes-containerDisplay	2017-06-16 15:39:15	ok	10.4.2.103
783	cpignol	zaalpes-containerChange	2017-06-16 15:39:26	ok	10.4.2.103
784	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:39:28	ok	10.4.2.103
785	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:39:51	ok	10.4.2.103
786	cpignol	zaalpes-containerWrite	2017-06-16 15:40:49	ok	10.4.2.103
787	cpignol	zaalpes-Container-write	2017-06-16 15:40:49	5	10.4.2.103
788	cpignol	zaalpes-containerDisplay	2017-06-16 15:40:49	ok	10.4.2.103
789	cpignol	zaalpes-containerChange	2017-06-16 15:40:59	ok	10.4.2.103
790	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:41:01	ok	10.4.2.103
791	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:41:41	ok	10.4.2.103
792	cpignol	zaalpes-containerWrite	2017-06-16 15:41:44	ok	10.4.2.103
793	cpignol	zaalpes-Container-write	2017-06-16 15:41:44	6	10.4.2.103
794	cpignol	zaalpes-containerDisplay	2017-06-16 15:41:44	ok	10.4.2.103
795	cpignol	zaalpes-containerList	2017-06-16 15:42:18	ok	10.4.2.103
796	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:42:20	ok	10.4.2.103
797	cpignol	zaalpes-containerDisplay	2017-06-16 15:42:22	ok	10.4.2.103
798	cpignol	zaalpes-containerChange	2017-06-16 15:42:25	ok	10.4.2.103
799	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:42:27	ok	10.4.2.103
800	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:42:48	ok	10.4.2.103
801	cpignol	zaalpes-containerWrite	2017-06-16 15:42:50	ok	10.4.2.103
802	cpignol	zaalpes-Container-write	2017-06-16 15:42:50	7	10.4.2.103
803	cpignol	zaalpes-containerDisplay	2017-06-16 15:42:50	ok	10.4.2.103
804	cpignol	zaalpes-containerChange	2017-06-16 15:43:05	ok	10.4.2.103
805	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:43:07	ok	10.4.2.103
806	cpignol	zaalpes-containerList	2017-06-16 15:43:16	ok	10.4.2.103
807	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:43:18	ok	10.4.2.103
808	cpignol	zaalpes-containerDisplay	2017-06-16 15:43:59	ok	10.4.2.103
809	cpignol	zaalpes-containerChange	2017-06-16 15:44:07	ok	10.4.2.103
810	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:44:09	ok	10.4.2.103
811	cpignol	zaalpes-containerWrite	2017-06-16 15:44:24	ok	10.4.2.103
812	cpignol	zaalpes-Container-write	2017-06-16 15:44:24	7	10.4.2.103
813	cpignol	zaalpes-containerDisplay	2017-06-16 15:44:24	ok	10.4.2.103
814	cpignol	zaalpes-containerList	2017-06-16 15:44:30	ok	10.4.2.103
815	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:44:31	ok	10.4.2.103
816	cpignol	zaalpes-containerExportCSV	2017-06-16 15:45:38	ok	10.4.2.103
817	cpignol	zaalpes-containerDisplay	2017-06-16 15:48:58	ok	10.4.2.103
818	cpignol	zaalpes-containerChange	2017-06-16 15:49:10	ok	10.4.2.103
819	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:49:12	ok	10.4.2.103
820	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:49:48	ok	10.4.2.103
821	cpignol	zaalpes-containerWrite	2017-06-16 15:51:01	ok	10.4.2.103
822	cpignol	zaalpes-Container-write	2017-06-16 15:51:01	8	10.4.2.103
823	cpignol	zaalpes-containerDisplay	2017-06-16 15:51:01	ok	10.4.2.103
824	cpignol	zaalpes-containerChange	2017-06-16 15:51:37	ok	10.4.2.103
825	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:51:39	ok	10.4.2.103
826	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:52:11	ok	10.4.2.103
827	cpignol	zaalpes-containerWrite	2017-06-16 15:52:14	ok	10.4.2.103
828	cpignol	zaalpes-Container-write	2017-06-16 15:52:14	9	10.4.2.103
829	cpignol	zaalpes-containerDisplay	2017-06-16 15:52:14	ok	10.4.2.103
830	cpignol	zaalpes-containerList	2017-06-16 15:52:33	ok	10.4.2.103
831	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:52:35	ok	10.4.2.103
832	cpignol	zaalpes-containerDisplay	2017-06-16 15:52:47	ok	10.4.2.103
833	cpignol	zaalpes-containerList	2017-06-16 15:53:26	ok	10.4.2.103
834	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:53:28	ok	10.4.2.103
835	cpignol	zaalpes-containerDisplay	2017-06-16 15:53:37	ok	10.4.2.103
836	cpignol	zaalpes-containerList	2017-06-16 15:53:46	ok	10.4.2.103
837	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:53:47	ok	10.4.2.103
838	cpignol	zaalpes-containerDisplay	2017-06-16 15:53:49	ok	10.4.2.103
839	cpignol	zaalpes-storagecontainerInput	2017-06-16 15:54:09	ok	10.4.2.103
840	cpignol	zaalpes-containerGetFromUid	2017-06-16 15:54:14	ok	10.4.2.103
841	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:54:22	ok	10.4.2.103
842	cpignol	zaalpes-containerGetFromType	2017-06-16 15:54:25	ok	10.4.2.103
843	cpignol	zaalpes-storagecontainerWrite	2017-06-16 15:56:34	ok	10.4.2.103
844	cpignol	zaalpes-Storage-write	2017-06-16 15:56:34	8	10.4.2.103
845	cpignol	zaalpes-containerDisplay	2017-06-16 15:56:34	ok	10.4.2.103
846	cpignol	zaalpes-containerList	2017-06-16 15:56:57	ok	10.4.2.103
847	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 15:56:59	ok	10.4.2.103
848	cpignol	zaalpes-containerExportCSV	2017-06-16 15:57:11	ok	10.4.2.103
849	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:01:03	ok	10.4.2.103
850	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:04:50	ok	10.4.2.103
851	cpignol	zaalpes-containerDisplay	2017-06-16 16:05:33	ok	10.4.2.103
852	cpignol	zaalpes-containerobjectIdentifierChange	2017-06-16 16:05:49	ok	10.4.2.103
853	cpignol	zaalpes-containerList	2017-06-16 16:06:14	ok	10.4.2.103
854	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:06:15	ok	10.4.2.103
855	cpignol	zaalpes-labelList	2017-06-16 16:07:03	ok	10.4.2.103
856	cpignol	zaalpes-labelChange	2017-06-16 16:07:08	ok	10.4.2.103
857	cpignol	zaalpes-labelWrite	2017-06-16 16:09:22	ok	10.4.2.103
858	cpignol	zaalpes-Label-write	2017-06-16 16:09:22	2	10.4.2.103
859	cpignol	zaalpes-labelList	2017-06-16 16:09:22	ok	10.4.2.103
860	cpignol	zaalpes-labelChange	2017-06-16 16:09:28	ok	10.4.2.103
861	cpignol	zaalpes-labelWrite	2017-06-16 16:14:23	ok	10.4.2.103
862	cpignol	zaalpes-Label-write	2017-06-16 16:14:23	3	10.4.2.103
863	cpignol	zaalpes-labelList	2017-06-16 16:14:23	ok	10.4.2.103
864	cpignol	zaalpes-containerList	2017-06-16 16:14:30	ok	10.4.2.103
865	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:14:32	ok	10.4.2.103
866	cpignol	zaalpes-containerDisplay	2017-06-16 16:14:34	ok	10.4.2.103
867	cpignol	zaalpes-containerTypeList	2017-06-16 16:14:51	ok	10.4.2.103
868	cpignol	zaalpes-containerList	2017-06-16 16:15:05	ok	10.4.2.103
869	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:15:07	ok	10.4.2.103
870	cpignol	zaalpes-containerDisplay	2017-06-16 16:15:10	ok	10.4.2.103
871	cpignol	zaalpes-containerChange	2017-06-16 16:15:17	ok	10.4.2.103
872	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:15:19	ok	10.4.2.103
873	cpignol	zaalpes-containerDisplay	2017-06-16 16:15:24	ok	10.4.2.103
874	cpignol	zaalpes-containerobjectIdentifierChange	2017-06-16 16:15:28	ok	10.4.2.103
875	cpignol	zaalpes-containerobjectIdentifierWrite	2017-06-16 16:15:57	ok	10.4.2.103
876	cpignol	zaalpes-containerobjectIdentifierChange	2017-06-16 16:15:57	ok	10.4.2.103
877	cpignol	zaalpes-administration	2017-06-16 16:16:12	ok	10.4.2.103
878	cpignol	zaalpes-identifierTypeList	2017-06-16 16:16:21	ok	10.4.2.103
879	cpignol	zaalpes-identifierTypeChange	2017-06-16 16:17:07	ok	10.4.2.103
880	cpignol	zaalpes-identifierTypeWrite	2017-06-16 16:17:55	ok	10.4.2.103
881	cpignol	zaalpes-IdentifierType-write	2017-06-16 16:17:55	1	10.4.2.103
882	cpignol	zaalpes-identifierTypeList	2017-06-16 16:17:55	ok	10.4.2.103
883	cpignol	zaalpes-containerList	2017-06-16 16:18:02	ok	10.4.2.103
884	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:18:04	ok	10.4.2.103
885	cpignol	zaalpes-identifierTypeList	2017-06-16 16:18:28	ok	10.4.2.103
886	cpignol	zaalpes-identifierTypeChange	2017-06-16 16:18:32	ok	10.4.2.103
887	cpignol	zaalpes-identifierTypeWrite	2017-06-16 16:19:46	ok	10.4.2.103
888	cpignol	zaalpes-IdentifierType-write	2017-06-16 16:19:46	1	10.4.2.103
889	cpignol	zaalpes-identifierTypeList	2017-06-16 16:19:46	ok	10.4.2.103
890	cpignol	zaalpes-identifierTypeChange	2017-06-16 16:19:52	ok	10.4.2.103
891	cpignol	zaalpes-identifierTypeWrite	2017-06-16 16:20:09	ok	10.4.2.103
892	cpignol	zaalpes-IdentifierType-write	2017-06-16 16:20:09	1	10.4.2.103
893	cpignol	zaalpes-identifierTypeList	2017-06-16 16:20:09	ok	10.4.2.103
894	cpignol	zaalpes-containerList	2017-06-16 16:20:13	ok	10.4.2.103
895	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:20:15	ok	10.4.2.103
896	cpignol	zaalpes-containerDisplay	2017-06-16 16:20:20	ok	10.4.2.103
897	cpignol	zaalpes-containerobjectIdentifierChange	2017-06-16 16:28:00	ok	10.4.2.103
898	cpignol	zaalpes-containerobjectIdentifierWrite	2017-06-16 16:29:14	ok	10.4.2.103
899	cpignol	zaalpes-ObjectIdentifier-write	2017-06-16 16:29:14	2	10.4.2.103
900	cpignol	zaalpes-containerDisplay	2017-06-16 16:29:14	ok	10.4.2.103
901	cpignol	zaalpes-labelList	2017-06-16 16:29:25	ok	10.4.2.103
902	cpignol	zaalpes-labelChange	2017-06-16 16:29:33	ok	10.4.2.103
903	cpignol	zaalpes-labelWrite	2017-06-16 16:30:57	ok	10.4.2.103
904	cpignol	zaalpes-Label-write	2017-06-16 16:30:57	3	10.4.2.103
905	cpignol	zaalpes-labelList	2017-06-16 16:30:57	ok	10.4.2.103
906	cpignol	zaalpes-containerList	2017-06-16 16:31:05	ok	10.4.2.103
907	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:31:07	ok	10.4.2.103
908	cpignol	zaalpes-containerDisplay	2017-06-16 16:31:10	ok	10.4.2.103
909	cpignol	zaalpes-containerobjectIdentifierChange	2017-06-16 16:31:13	ok	10.4.2.103
910	cpignol	zaalpes-containerobjectIdentifierWrite	2017-06-16 16:31:25	ok	10.4.2.103
911	cpignol	zaalpes-ObjectIdentifier-write	2017-06-16 16:31:25	3	10.4.2.103
912	cpignol	zaalpes-containerDisplay	2017-06-16 16:31:25	ok	10.4.2.103
913	cpignol	zaalpes-containerList	2017-06-16 16:31:30	ok	10.4.2.103
914	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:31:32	ok	10.4.2.103
915	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:31:40	ok	10.4.2.103
916	cpignol	zaalpes-containerList	2017-06-16 16:31:45	ok	10.4.2.103
917	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:31:46	ok	10.4.2.103
918	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:31:51	ok	10.4.2.103
919	cpignol	zaalpes-containerList	2017-06-16 16:32:00	ok	10.4.2.103
920	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:32:02	ok	10.4.2.103
921	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:32:22	ok	10.4.2.103
922	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:32:50	ok	10.4.2.103
923	cpignol	zaalpes-containerList	2017-06-16 16:32:53	ok	10.4.2.103
924	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:32:54	ok	10.4.2.103
925	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:33:13	ok	10.4.2.103
926	cpignol	zaalpes-containerList	2017-06-16 16:33:17	ok	10.4.2.103
927	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:33:18	ok	10.4.2.103
928	cpignol	zaalpes-labelList	2017-06-16 16:33:22	ok	10.4.2.103
929	cpignol	zaalpes-labelChange	2017-06-16 16:33:30	ok	10.4.2.103
930	cpignol	zaalpes-labelWrite	2017-06-16 16:33:48	ok	10.4.2.103
931	cpignol	zaalpes-Label-write	2017-06-16 16:33:48	2	10.4.2.103
932	cpignol	zaalpes-labelList	2017-06-16 16:33:48	ok	10.4.2.103
933	cpignol	zaalpes-objets	2017-06-16 16:34:02	ok	10.4.2.103
934	cpignol	zaalpes-containerList	2017-06-16 16:34:07	ok	10.4.2.103
935	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:34:09	ok	10.4.2.103
936	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:34:23	ok	10.4.2.103
937	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:34:29	ok	10.4.2.103
938	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:35:49	ok	10.4.2.103
939	cpignol	zaalpes-containerList	2017-06-16 16:36:26	ok	10.4.2.103
940	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:36:27	ok	10.4.2.103
941	cpignol	zaalpes-labelList	2017-06-16 16:36:34	ok	10.4.2.103
942	cpignol	zaalpes-labelChange	2017-06-16 16:36:39	ok	10.4.2.103
943	cpignol	zaalpes-labelWrite	2017-06-16 16:38:10	ok	10.4.2.103
944	cpignol	zaalpes-Label-write	2017-06-16 16:38:10	3	10.4.2.103
945	cpignol	zaalpes-labelList	2017-06-16 16:38:10	ok	10.4.2.103
946	cpignol	zaalpes-objets	2017-06-16 16:38:20	ok	10.4.2.103
947	cpignol	zaalpes-containerList	2017-06-16 16:38:23	ok	10.4.2.103
948	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:38:25	ok	10.4.2.103
949	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:38:35	ok	10.4.2.103
950	cpignol	zaalpes-containerList	2017-06-16 16:38:38	ok	10.4.2.103
951	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:38:40	ok	10.4.2.103
952	cpignol	zaalpes-labelList	2017-06-16 16:38:46	ok	10.4.2.103
953	cpignol	zaalpes-identifierTypeList	2017-06-16 16:38:56	ok	10.4.2.103
954	cpignol	zaalpes-labelList	2017-06-16 16:39:04	ok	10.4.2.103
955	cpignol	zaalpes-labelChange	2017-06-16 16:39:08	ok	10.4.2.103
956	cpignol	zaalpes-labelWrite	2017-06-16 16:39:42	ok	10.4.2.103
957	cpignol	zaalpes-Label-write	2017-06-16 16:39:42	3	10.4.2.103
958	cpignol	zaalpes-labelList	2017-06-16 16:39:42	ok	10.4.2.103
959	cpignol	zaalpes-objets	2017-06-16 16:39:45	ok	10.4.2.103
960	cpignol	zaalpes-containerList	2017-06-16 16:39:48	ok	10.4.2.103
961	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:39:50	ok	10.4.2.103
962	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:40:00	ok	10.4.2.103
963	cpignol	zaalpes-containerList	2017-06-16 16:40:04	ok	10.4.2.103
964	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:40:05	ok	10.4.2.103
965	cpignol	zaalpes-labelList	2017-06-16 16:40:10	ok	10.4.2.103
966	cpignol	zaalpes-labelChange	2017-06-16 16:40:19	ok	10.4.2.103
967	cpignol	zaalpes-labelWrite	2017-06-16 16:41:37	ok	10.4.2.103
968	cpignol	zaalpes-Label-write	2017-06-16 16:41:37	3	10.4.2.103
969	cpignol	zaalpes-labelList	2017-06-16 16:41:37	ok	10.4.2.103
970	cpignol	zaalpes-containerList	2017-06-16 16:41:44	ok	10.4.2.103
971	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:41:46	ok	10.4.2.103
972	cpignol	zaalpes-containerDisplay	2017-06-16 16:41:52	ok	10.4.2.103
973	cpignol	zaalpes-containerList	2017-06-16 16:41:57	ok	10.4.2.103
974	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:41:58	ok	10.4.2.103
975	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:42:09	ok	10.4.2.103
976	cpignol	zaalpes-labelList	2017-06-16 16:43:29	ok	10.4.2.103
977	cpignol	zaalpes-labelChange	2017-06-16 16:43:33	ok	10.4.2.103
978	cpignol	zaalpes-labelWrite	2017-06-16 16:46:30	ok	10.4.2.103
979	cpignol	zaalpes-Label-write	2017-06-16 16:46:30	3	10.4.2.103
980	cpignol	zaalpes-labelList	2017-06-16 16:46:30	ok	10.4.2.103
981	cpignol	zaalpes-objets	2017-06-16 16:46:42	ok	10.4.2.103
982	cpignol	zaalpes-containerList	2017-06-16 16:46:45	ok	10.4.2.103
983	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:46:47	ok	10.4.2.103
984	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:47:04	ok	10.4.2.103
985	cpignol	zaalpes-labelList	2017-06-16 16:47:29	ok	10.4.2.103
986	cpignol	zaalpes-labelChange	2017-06-16 16:47:34	ok	10.4.2.103
987	cpignol	zaalpes-labelWrite	2017-06-16 16:48:31	ok	10.4.2.103
988	cpignol	zaalpes-Label-write	2017-06-16 16:48:31	3	10.4.2.103
989	cpignol	zaalpes-labelList	2017-06-16 16:48:31	ok	10.4.2.103
990	cpignol	zaalpes-containerList	2017-06-16 16:48:35	ok	10.4.2.103
991	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:48:36	ok	10.4.2.103
992	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:48:46	ok	10.4.2.103
993	cpignol	zaalpes-labelList	2017-06-16 16:53:15	ok	10.4.2.103
994	cpignol	zaalpes-labelChange	2017-06-16 16:53:22	ok	10.4.2.103
995	cpignol	zaalpes-labelWrite	2017-06-16 16:58:20	ok	10.4.2.103
996	cpignol	zaalpes-Label-write	2017-06-16 16:58:20	3	10.4.2.103
997	cpignol	zaalpes-labelList	2017-06-16 16:58:20	ok	10.4.2.103
998	cpignol	zaalpes-containerList	2017-06-16 16:58:38	ok	10.4.2.103
999	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 16:58:40	ok	10.4.2.103
1000	cpignol	zaalpes-containerPrintLabel	2017-06-16 16:58:52	ok	10.4.2.103
1001	cpignol	zaalpes-labelList	2017-06-16 17:19:36	ok	10.4.2.103
1002	cpignol	zaalpes-labelChange	2017-06-16 17:19:39	ok	10.4.2.103
1003	cpignol	zaalpes-labelWrite	2017-06-16 17:22:19	ok	10.4.2.103
1004	cpignol	zaalpes-Label-write	2017-06-16 17:22:19	3	10.4.2.103
1005	cpignol	zaalpes-labelList	2017-06-16 17:22:19	ok	10.4.2.103
1006	cpignol	zaalpes-containerList	2017-06-16 17:22:25	ok	10.4.2.103
1007	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:22:27	ok	10.4.2.103
1008	cpignol	zaalpes-containerDisplay	2017-06-16 17:22:38	ok	10.4.2.103
1009	cpignol	zaalpes-containerList	2017-06-16 17:22:45	ok	10.4.2.103
1010	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:22:46	ok	10.4.2.103
1011	cpignol	zaalpes-containerPrintLabel	2017-06-16 17:23:02	ok	10.4.2.103
1012	cpignol	zaalpes-containerList	2017-06-16 17:23:07	ok	10.4.2.103
1013	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:23:08	ok	10.4.2.103
1014	cpignol	zaalpes-containerPrintLabel	2017-06-16 17:23:23	ok	10.4.2.103
1015	cpignol	zaalpes-containerList	2017-06-16 17:23:27	ok	10.4.2.103
1016	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:23:28	ok	10.4.2.103
1017	cpignol	zaalpes-labelList	2017-06-16 17:23:32	ok	10.4.2.103
1018	cpignol	zaalpes-labelChange	2017-06-16 17:23:35	ok	10.4.2.103
1019	cpignol	zaalpes-labelWrite	2017-06-16 17:25:32	ok	10.4.2.103
1020	cpignol	zaalpes-Label-write	2017-06-16 17:25:32	3	10.4.2.103
1021	cpignol	zaalpes-labelList	2017-06-16 17:25:32	ok	10.4.2.103
1022	cpignol	zaalpes-objets	2017-06-16 17:25:36	ok	10.4.2.103
1023	cpignol	zaalpes-containerList	2017-06-16 17:25:39	ok	10.4.2.103
1024	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:25:41	ok	10.4.2.103
1025	cpignol	zaalpes-containerPrintLabel	2017-06-16 17:25:48	ok	10.4.2.103
1026	cpignol	zaalpes-parametre	2017-06-16 17:26:45	ok	10.4.2.103
1027	cpignol	zaalpes-parametre	2017-06-16 17:26:49	ok	10.4.2.103
1028	cpignol	zaalpes-parametre	2017-06-16 17:26:56	ok	10.4.2.103
1029	cpignol	zaalpes-default	2017-06-16 17:27:04	ok	10.4.2.103
1030	cpignol	zaalpes-labelList	2017-06-16 17:27:09	ok	10.4.2.103
1031	cpignol	zaalpes-labelChange	2017-06-16 17:27:12	ok	10.4.2.103
1032	cpignol	zaalpes-labelWrite	2017-06-16 17:28:04	ok	10.4.2.103
1033	cpignol	zaalpes-Label-write	2017-06-16 17:28:04	3	10.4.2.103
1034	cpignol	zaalpes-labelList	2017-06-16 17:28:04	ok	10.4.2.103
1035	cpignol	zaalpes-objets	2017-06-16 17:28:08	ok	10.4.2.103
1036	cpignol	zaalpes-containerList	2017-06-16 17:28:10	ok	10.4.2.103
1037	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:28:12	ok	10.4.2.103
1038	cpignol	zaalpes-containerPrintLabel	2017-06-16 17:28:25	ok	10.4.2.103
1039	cpignol	zaalpes-labelList	2017-06-16 17:32:35	ok	10.4.2.103
1040	cpignol	zaalpes-labelChange	2017-06-16 17:32:38	ok	10.4.2.103
1041	cpignol	zaalpes-labelWrite	2017-06-16 17:36:22	ok	10.4.2.103
1042	cpignol	zaalpes-Label-write	2017-06-16 17:36:22	3	10.4.2.103
1043	cpignol	zaalpes-labelList	2017-06-16 17:36:22	ok	10.4.2.103
1044	cpignol	zaalpes-containerList	2017-06-16 17:36:27	ok	10.4.2.103
1045	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:36:29	ok	10.4.2.103
1046	cpignol	zaalpes-containerPrintLabel	2017-06-16 17:36:41	ok	10.4.2.103
1047	cpignol	zaalpes-labelList	2017-06-16 17:37:27	ok	10.4.2.103
1048	cpignol	zaalpes-labelChange	2017-06-16 17:37:30	ok	10.4.2.103
1049	cpignol	zaalpes-labelWrite	2017-06-16 17:38:04	ok	10.4.2.103
1050	cpignol	zaalpes-Label-write	2017-06-16 17:38:04	3	10.4.2.103
1051	cpignol	zaalpes-labelList	2017-06-16 17:38:04	ok	10.4.2.103
1052	cpignol	zaalpes-containerList	2017-06-16 17:38:08	ok	10.4.2.103
1053	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:38:11	ok	10.4.2.103
1054	cpignol	zaalpes-containerPrintLabel	2017-06-16 17:38:21	ok	10.4.2.103
1055	cpignol	zaalpes-containerList	2017-06-16 17:42:42	ok	10.4.2.103
1056	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:42:44	ok	10.4.2.103
1057	cpignol	zaalpes-containerExportCSV	2017-06-16 17:43:14	ok	10.4.2.103
1058	cpignol	zaalpes-containerExportCSV	2017-06-16 17:43:20	ok	10.4.2.103
1059	cpignol	zaalpes-importChange	2017-06-16 17:45:38	ok	10.4.2.103
1060	cpignol	zaalpes-containerList	2017-06-16 17:46:47	ok	10.4.2.103
1061	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:46:49	ok	10.4.2.103
1062	cpignol	zaalpes-containerDisplay	2017-06-16 17:46:59	ok	10.4.2.103
1063	cpignol	zaalpes-importChange	2017-06-16 17:48:03	ok	10.4.2.103
1064	cpignol	zaalpes-importControl	2017-06-16 17:57:48	ok	10.4.2.103
1065	cpignol	zaalpes-importChange	2017-06-16 17:57:48	ok	10.4.2.103
1066	cpignol	zaalpes-importImport	2017-06-16 17:57:55	ok	10.4.2.103
1067	cpignol	zaalpes-containerList	2017-06-16 17:59:23	ok	10.4.2.103
1068	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 17:59:24	ok	10.4.2.103
1069	cpignol	zaalpes-containerDisplay	2017-06-16 17:59:47	ok	10.4.2.103
1070	cpignol	zaalpes-storagecontainerInput	2017-06-16 18:00:24	ok	10.4.2.103
1071	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:00:31	ok	10.4.2.103
1072	cpignol	zaalpes-containerGetFromType	2017-06-16 18:00:36	ok	10.4.2.103
1073	cpignol	zaalpes-storagecontainerWrite	2017-06-16 18:00:57	ok	10.4.2.103
1074	cpignol	zaalpes-Storage-write	2017-06-16 18:00:57	9	10.4.2.103
1075	cpignol	zaalpes-containerDisplay	2017-06-16 18:00:57	ok	10.4.2.103
1076	cpignol	zaalpes-containerList	2017-06-16 18:01:03	ok	10.4.2.103
1077	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:01:05	ok	10.4.2.103
1078	cpignol	zaalpes-importChange	2017-06-16 18:02:22	ok	10.4.2.103
1079	cpignol	zaalpes-importControl	2017-06-16 18:02:41	ok	10.4.2.103
1080	cpignol	zaalpes-importChange	2017-06-16 18:02:41	ok	10.4.2.103
1081	cpignol	zaalpes-importImport	2017-06-16 18:02:47	ok	10.4.2.103
1082	cpignol	zaalpes-importChange	2017-06-16 18:02:47	ok	10.4.2.103
1083	cpignol	zaalpes-importControl	2017-06-16 18:04:40	ok	10.4.2.103
1084	cpignol	zaalpes-importChange	2017-06-16 18:04:40	ok	10.4.2.103
1085	cpignol	zaalpes-containerList	2017-06-16 18:05:33	ok	10.4.2.103
1086	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:05:35	ok	10.4.2.103
1087	cpignol	zaalpes-containerDisplay	2017-06-16 18:06:05	ok	10.4.2.103
1088	cpignol	zaalpes-containerList	2017-06-16 18:07:40	ok	10.4.2.103
1089	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:07:42	ok	10.4.2.103
1090	cpignol	zaalpes-containerDisplay	2017-06-16 18:07:46	ok	10.4.2.103
1091	cpignol	zaalpes-containerList	2017-06-16 18:18:02	ok	10.4.2.103
1092	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:18:03	ok	10.4.2.103
1093	cpignol	zaalpes-containerDisplay	2017-06-16 18:18:22	ok	10.4.2.103
1094	cpignol	zaalpes-containerChange	2017-06-16 18:18:36	ok	10.4.2.103
1095	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:18:38	ok	10.4.2.103
1096	cpignol	zaalpes-containerDisplay	2017-06-16 18:18:44	ok	10.4.2.103
1097	cpignol	zaalpes-containerobjectIdentifierChange	2017-06-16 18:18:47	ok	10.4.2.103
1098	cpignol	zaalpes-containerobjectIdentifierWrite	2017-06-16 18:18:56	ok	10.4.2.103
1099	cpignol	zaalpes-ObjectIdentifier-write	2017-06-16 18:18:56	81	10.4.2.103
1100	cpignol	zaalpes-containerDisplay	2017-06-16 18:18:56	ok	10.4.2.103
1101	cpignol	zaalpes-containerList	2017-06-16 18:19:03	ok	10.4.2.103
1102	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:19:05	ok	10.4.2.103
1103	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:19:23	ok	10.4.2.103
1104	cpignol	zaalpes-containerList	2017-06-16 18:19:27	ok	10.4.2.103
1105	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:19:29	ok	10.4.2.103
1106	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:19:39	ok	10.4.2.103
1107	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:19:44	ok	10.4.2.103
1108	cpignol	zaalpes-containerList	2017-06-16 18:19:47	ok	10.4.2.103
1109	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:19:48	ok	10.4.2.103
1110	cpignol	zaalpes-containerDisplay	2017-06-16 18:19:52	ok	10.4.2.103
1111	cpignol	zaalpes-containerChange	2017-06-16 18:20:13	ok	10.4.2.103
1112	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:20:15	ok	10.4.2.103
1113	cpignol	zaalpes-containerDisplay	2017-06-16 18:20:20	ok	10.4.2.103
1114	cpignol	zaalpes-containerList	2017-06-16 18:22:11	ok	10.4.2.103
1115	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:22:13	ok	10.4.2.103
1116	cpignol	zaalpes-containerChange	2017-06-16 18:22:26	ok	10.4.2.103
1117	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:22:27	ok	10.4.2.103
1118	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:25:43	ok	10.4.2.103
1119	cpignol	zaalpes-containerWrite	2017-06-16 18:25:51	ok	10.4.2.103
1120	cpignol	zaalpes-Container-write	2017-06-16 18:25:51	88	10.4.2.103
1121	cpignol	zaalpes-containerDisplay	2017-06-16 18:25:51	ok	10.4.2.103
1122	cpignol	zaalpes-containerList	2017-06-16 18:26:12	ok	10.4.2.103
1123	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 18:26:14	ok	10.4.2.103
1124	cpignol	zaalpes-projectList	2017-06-16 18:44:00	ok	10.4.2.103
1125	cpignol	zaalpes-protocolList	2017-06-16 18:44:08	ok	10.4.2.103
1126	cpignol	zaalpes-protocolChange	2017-06-16 18:44:15	ok	10.4.2.103
1127	cpignol	zaalpes-protocolWrite	2017-06-16 18:45:19	ok	10.4.2.103
1128	cpignol	zaalpes-Protocol-write	2017-06-16 18:45:19	1	10.4.2.103
1129	cpignol	zaalpes-protocolList	2017-06-16 18:45:19	ok	10.4.2.103
1130	cpignol	zaalpes-protocolChange	2017-06-16 18:45:22	ok	10.4.2.103
1131	cpignol	zaalpes-protocolList	2017-06-16 18:45:27	ok	10.4.2.103
1132	cpignol	zaalpes-operationList	2017-06-16 18:45:31	ok	10.4.2.103
1133	cpignol	zaalpes-operationChange	2017-06-16 18:45:38	ok	10.4.2.103
1134	cpignol	zaalpes-operationWrite	2017-06-16 19:01:59	ok	10.4.2.103
1135	cpignol	zaalpes-Operation-write	2017-06-16 19:01:59	1	10.4.2.103
1136	cpignol	zaalpes-operationList	2017-06-16 19:01:59	ok	10.4.2.103
1137	cpignol	zaalpes-operationChange	2017-06-16 19:02:04	ok	10.4.2.103
1138	cpignol	zaalpes-operationWrite	2017-06-16 19:03:35	ok	10.4.2.103
1139	cpignol	zaalpes-Operation-write	2017-06-16 19:03:35	1	10.4.2.103
1140	cpignol	zaalpes-operationList	2017-06-16 19:03:35	ok	10.4.2.103
1141	cpignol	zaalpes-labelChange	2017-06-16 19:03:40	ok	10.4.2.103
1142	cpignol	zaalpes-labelWrite	2017-06-16 19:16:28	ok	10.4.2.103
1143	cpignol	zaalpes-Label-write	2017-06-16 19:16:28	4	10.4.2.103
1144	cpignol	zaalpes-labelList	2017-06-16 19:16:28	ok	10.4.2.103
1145	cpignol	zaalpes-labelChange	2017-06-16 19:16:45	ok	10.4.2.103
1146	cpignol	zaalpes-labelList	2017-06-16 19:17:03	ok	10.4.2.103
1147	cpignol	zaalpes-labelChange	2017-06-16 19:17:06	ok	10.4.2.103
1148	cpignol	zaalpes-labelWrite	2017-06-16 19:18:42	ok	10.4.2.103
1149	cpignol	zaalpes-Label-write	2017-06-16 19:18:42	5	10.4.2.103
1150	cpignol	zaalpes-labelList	2017-06-16 19:18:42	ok	10.4.2.103
1151	cpignol	zaalpes-sampleList	2017-06-16 19:18:50	ok	10.4.2.103
1152	cpignol	zaalpes-sampleChange	2017-06-16 19:18:55	ok	10.4.2.103
1153	cpignol	zaalpes-identifierTypeList	2017-06-16 19:19:38	ok	10.4.2.103
1154	cpignol	zaalpes-identifierTypeChange	2017-06-16 19:19:41	ok	10.4.2.103
1155	cpignol	zaalpes-identifierTypeWrite	2017-06-16 19:19:50	ok	10.4.2.103
1156	cpignol	zaalpes-IdentifierType-write	2017-06-16 19:19:50	2	10.4.2.103
1157	cpignol	zaalpes-identifierTypeList	2017-06-16 19:19:50	ok	10.4.2.103
1158	cpignol	zaalpes-sampleList	2017-06-16 19:20:05	ok	10.4.2.103
1159	cpignol	zaalpes-sampleChange	2017-06-16 19:20:09	ok	10.4.2.103
1160	cpignol	zaalpes-sampleTypeList	2017-06-16 19:21:19	ok	10.4.2.103
1161	cpignol	zaalpes-sampleTypeChange	2017-06-16 19:21:25	ok	10.4.2.103
1162	cpignol	zaalpes-sampleTypeWrite	2017-06-16 19:22:23	ok	10.4.2.103
1163	cpignol	zaalpes-SampleType-write	2017-06-16 19:22:23	1	10.4.2.103
1164	cpignol	zaalpes-sampleTypeList	2017-06-16 19:22:23	ok	10.4.2.103
1165	cpignol	zaalpes-sampleList	2017-06-16 19:22:30	ok	10.4.2.103
1166	cpignol	zaalpes-sampleChange	2017-06-16 19:22:35	ok	10.4.2.103
1167	cpignol	zaalpes-metadataFormGetDetail	2017-06-16 19:23:15	ok	10.4.2.103
1168	cpignol	zaalpes-sampleWrite	2017-06-16 19:26:45	ok	10.4.2.103
1169	cpignol	zaalpes-Sample-write	2017-06-16 19:26:45	89	10.4.2.103
1170	cpignol	zaalpes-sampleDisplay	2017-06-16 19:26:45	ok	10.4.2.103
1171	cpignol	zaalpes-storagesampleInput	2017-06-16 19:27:24	ok	10.4.2.103
1172	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 19:27:30	ok	10.4.2.103
1173	cpignol	zaalpes-containerGetFromType	2017-06-16 19:27:32	ok	10.4.2.103
1174	cpignol	zaalpes-storagesampleWrite	2017-06-16 19:27:45	ok	10.4.2.103
1175	cpignol	zaalpes-Storage-write	2017-06-16 19:27:45	87	10.4.2.103
1176	cpignol	zaalpes-sampleDisplay	2017-06-16 19:27:45	ok	10.4.2.103
1177	cpignol	zaalpes-sampleList	2017-06-16 19:28:23	ok	10.4.2.103
1178	cpignol	zaalpes-sampleList	2017-06-16 19:28:27	ok	10.4.2.103
1179	cpignol	zaalpes-sampleDisplay	2017-06-16 19:28:39	ok	10.4.2.103
1180	cpignol	zaalpes-sampleobjectIdentifierChange	2017-06-16 19:28:44	ok	10.4.2.103
1181	cpignol	zaalpes-sampleobjectIdentifierWrite	2017-06-16 19:29:00	ok	10.4.2.103
1182	cpignol	zaalpes-ObjectIdentifier-write	2017-06-16 19:29:00	82	10.4.2.103
1183	cpignol	zaalpes-sampleDisplay	2017-06-16 19:29:00	ok	10.4.2.103
1184	cpignol	zaalpes-sampleList	2017-06-16 19:29:06	ok	10.4.2.103
1185	cpignol	zaalpes-samplePrintLabel	2017-06-16 19:29:21	ok	10.4.2.103
1186	unknown	zaalpes-default	2017-06-16 19:45:19	ok	77.136.87.4
1187	unknown	zaalpes-default	2017-06-16 19:45:29	ok	77.136.87.4
1188	unknown	zaalpes-connexion	2017-06-16 19:45:43	ok	77.136.87.4
1189	Cpignol	zaalpes-connexion	2017-06-16 19:47:02	db-ko	77.136.87.4
1190	unknown	zaalpes-default	2017-06-16 19:47:02	ok	77.136.87.4
1191	unknown	zaalpes-connexion	2017-06-16 19:47:09	ok	77.136.87.4
1192	cpignol	zaalpes-connexion	2017-06-16 19:48:03	db-ko	77.136.87.4
1193	unknown	zaalpes-default	2017-06-16 19:48:03	ok	77.136.87.4
1194	unknown	zaalpes-connexion	2017-06-16 19:48:13	ok	77.136.87.4
1195	cpignol	zaalpes-connexion	2017-06-16 19:48:54	db-ok	77.136.87.4
1196	cpignol	zaalpes-default	2017-06-16 19:48:54	ok	77.136.87.4
1197	cpignol	zaalpes-sampleList	2017-06-16 19:49:02	ok	77.136.87.4
1198	cpignol	zaalpes-sampleList	2017-06-16 19:49:08	ok	77.136.87.4
1199	cpignol	zaalpes-samplePrintLabel	2017-06-16 19:49:57	ok	77.136.87.4
1200	cpignol	zaalpes-labelList	2017-06-16 19:50:26	ok	77.136.87.4
1201	cpignol	zaalpes-labelChange	2017-06-16 19:50:35	ok	77.136.87.4
1202	cpignol	zaalpes-disconnect-ipaddress-changed	2017-06-16 19:58:11	old:77.136.87.4-new:92.90.21.40	92.90.21.40
1203	cpignol	zaalpes-labelList-connexion	2017-06-16 19:58:11	token-ok	92.90.21.40
1204	cpignol	zaalpes-labelList	2017-06-16 19:58:11	ok	92.90.21.40
1205	unknown	zaalpes-sampleList	2017-06-16 19:58:20	nologin	92.90.21.40
1206	unknown	zaalpes-containerList	2017-06-16 19:58:35	nologin	92.90.21.40
1207	cpignol	zaalpes-connexion	2017-06-16 19:59:12	db-ok	92.90.21.40
1208	cpignol	zaalpes-containerList	2017-06-16 19:59:12	ok	92.90.21.40
1209	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 19:59:14	ok	92.90.21.40
1210	cpignol	zaalpes-containerList	2017-06-16 19:59:18	ok	92.90.21.40
1211	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-16 19:59:20	ok	92.90.21.40
1212	cpignol	zaalpes-sampleList	2017-06-16 19:59:34	ok	92.90.21.40
1213	cpignol	zaalpes-sampleList	2017-06-16 19:59:41	ok	92.90.21.40
1214	unknown	zaalpes-default	2017-06-17 08:03:15	ok	193.250.222.82
1215	unknown	zaalpes-connexion	2017-06-17 08:03:54	ok	193.250.222.82
1216	cpignol	zaalpes-connexion	2017-06-17 08:04:10	db-ok	193.250.222.82
1217	cpignol	zaalpes-default	2017-06-17 08:04:10	ok	193.250.222.82
1218	cpignol	zaalpes-labelList	2017-06-17 08:04:23	ok	193.250.222.82
1219	cpignol	zaalpes-labelChange	2017-06-17 08:04:33	ok	193.250.222.82
1220	cpignol	zaalpes-labelWrite	2017-06-17 08:06:11	ok	193.250.222.82
1221	cpignol	zaalpes-Label-write	2017-06-17 08:06:11	5	193.250.222.82
1222	cpignol	zaalpes-labelList	2017-06-17 08:06:11	ok	193.250.222.82
1223	cpignol	zaalpes-sampleList	2017-06-17 08:06:26	ok	193.250.222.82
1224	cpignol	zaalpes-sampleList	2017-06-17 08:06:33	ok	193.250.222.82
1225	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:06:46	ok	193.250.222.82
1226	cpignol	zaalpes-sampleList	2017-06-17 08:07:13	ok	193.250.222.82
1227	cpignol	zaalpes-labelList	2017-06-17 08:07:50	ok	193.250.222.82
1228	cpignol	zaalpes-labelChange	2017-06-17 08:08:11	ok	193.250.222.82
1229	cpignol	zaalpes-labelList	2017-06-17 08:09:09	ok	193.250.222.82
1230	cpignol	zaalpes-labelChange	2017-06-17 08:09:27	ok	193.250.222.82
1231	cpignol	zaalpes-labelWrite	2017-06-17 08:12:44	ok	193.250.222.82
1232	cpignol	zaalpes-Label-write	2017-06-17 08:12:44	5	193.250.222.82
1233	cpignol	zaalpes-labelList	2017-06-17 08:12:44	ok	193.250.222.82
1234	cpignol	zaalpes-identifierTypeList	2017-06-17 08:13:27	ok	193.250.222.82
1235	cpignol	zaalpes-sampleList	2017-06-17 08:13:54	ok	193.250.222.82
1236	cpignol	zaalpes-sampleDisplay	2017-06-17 08:14:22	ok	193.250.222.82
1237	cpignol	zaalpes-sampleChange	2017-06-17 08:15:46	ok	193.250.222.82
1238	cpignol	zaalpes-sampleDisplay	2017-06-17 08:17:21	ok	193.250.222.82
1239	cpignol	zaalpes-sampleList	2017-06-17 08:17:55	ok	193.250.222.82
1240	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:19:16	ok	193.250.222.82
1241	cpignol	zaalpes-sampleList	2017-06-17 08:19:28	ok	193.250.222.82
1242	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:19:39	ok	193.250.222.82
1243	cpignol	zaalpes-sampleList	2017-06-17 08:20:18	ok	193.250.222.82
1244	cpignol	zaalpes-labelList	2017-06-17 08:21:14	ok	193.250.222.82
1245	cpignol	zaalpes-labelChange	2017-06-17 08:23:32	ok	193.250.222.82
1246	cpignol	zaalpes-labelWrite	2017-06-17 08:25:46	ok	193.250.222.82
1247	cpignol	zaalpes-Label-write	2017-06-17 08:25:46	5	193.250.222.82
1248	cpignol	zaalpes-labelList	2017-06-17 08:25:46	ok	193.250.222.82
1249	cpignol	zaalpes-sampleList	2017-06-17 08:26:00	ok	193.250.222.82
1250	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:26:13	ok	193.250.222.82
1251	cpignol	zaalpes-labelChange	2017-06-17 08:27:27	ok	193.250.222.82
1252	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:27:37	ok	193.250.222.82
1253	cpignol	zaalpes-labelWrite	2017-06-17 08:31:29	ok	193.250.222.82
1254	cpignol	zaalpes-Label-write	2017-06-17 08:31:29	5	193.250.222.82
1255	cpignol	zaalpes-labelList	2017-06-17 08:31:29	ok	193.250.222.82
1256	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:31:57	ok	193.250.222.82
1257	cpignol	zaalpes-labelChange	2017-06-17 08:32:31	ok	193.250.222.82
1258	cpignol	zaalpes-labelWrite	2017-06-17 08:34:41	ok	193.250.222.82
1259	cpignol	zaalpes-Label-write	2017-06-17 08:34:41	5	193.250.222.82
1260	cpignol	zaalpes-labelList	2017-06-17 08:34:41	ok	193.250.222.82
1261	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:34:54	ok	193.250.222.82
1262	cpignol	zaalpes-labelChange	2017-06-17 08:36:08	ok	193.250.222.82
1263	cpignol	zaalpes-labelWrite	2017-06-17 08:39:49	ok	193.250.222.82
1264	cpignol	zaalpes-Label-write	2017-06-17 08:39:49	5	193.250.222.82
1265	cpignol	zaalpes-labelList	2017-06-17 08:39:49	ok	193.250.222.82
1266	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:39:56	ok	193.250.222.82
1267	cpignol	zaalpes-labelChange	2017-06-17 08:40:24	ok	193.250.222.82
1268	cpignol	zaalpes-labelWrite	2017-06-17 08:43:14	ok	193.250.222.82
1269	cpignol	zaalpes-Label-write	2017-06-17 08:43:14	5	193.250.222.82
1270	cpignol	zaalpes-labelList	2017-06-17 08:43:14	ok	193.250.222.82
1271	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:43:21	ok	193.250.222.82
1272	cpignol	zaalpes-labelChange	2017-06-17 08:43:35	ok	193.250.222.82
1273	cpignol	zaalpes-labelWrite	2017-06-17 08:43:53	ok	193.250.222.82
1274	cpignol	zaalpes-Label-write	2017-06-17 08:43:53	5	193.250.222.82
1275	cpignol	zaalpes-labelList	2017-06-17 08:43:53	ok	193.250.222.82
1276	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:43:59	ok	193.250.222.82
1277	cpignol	zaalpes-labelChange	2017-06-17 08:44:04	ok	193.250.222.82
1278	cpignol	zaalpes-labelWrite	2017-06-17 08:44:56	ok	193.250.222.82
1279	cpignol	zaalpes-Label-write	2017-06-17 08:44:56	5	193.250.222.82
1280	cpignol	zaalpes-labelList	2017-06-17 08:44:56	ok	193.250.222.82
1281	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:45:01	ok	193.250.222.82
1282	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:46:05	ok	193.250.222.82
1283	cpignol	zaalpes-labelChange	2017-06-17 08:49:24	ok	193.250.222.82
1284	cpignol	zaalpes-labelList	2017-06-17 08:49:33	ok	193.250.222.82
1285	cpignol	zaalpes-labelChange	2017-06-17 08:49:36	ok	193.250.222.82
1286	cpignol	zaalpes-labelWrite	2017-06-17 08:51:01	ok	193.250.222.82
1287	cpignol	zaalpes-Label-write	2017-06-17 08:51:01	4	193.250.222.82
1288	cpignol	zaalpes-labelList	2017-06-17 08:51:01	ok	193.250.222.82
1289	cpignol	zaalpes-sampleList	2017-06-17 08:51:10	ok	193.250.222.82
1290	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:51:18	ok	193.250.222.82
1291	cpignol	zaalpes-sampleList	2017-06-17 08:51:42	ok	193.250.222.82
1292	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:51:46	ok	193.250.222.82
1293	cpignol	zaalpes-samplePrintLabel	2017-06-17 08:51:50	ok	193.250.222.82
1294	cpignol	zaalpes-sampleList	2017-06-17 08:52:09	ok	193.250.222.82
1295	cpignol	zaalpes-containerList	2017-06-17 09:21:03	ok	193.250.222.82
1296	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-17 09:21:04	ok	193.250.222.82
1297	cpignol	zaalpes-containerList	2017-06-17 09:21:07	ok	193.250.222.82
1298	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-17 09:21:07	ok	193.250.222.82
1299	cpignol	zaalpes-containerDisplay	2017-06-17 09:21:18	ok	193.250.222.82
1300	cpignol	zaalpes-containerList	2017-06-17 09:21:24	ok	193.250.222.82
1301	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-17 09:21:27	ok	193.250.222.82
1302	cpignol	zaalpes-containerPrintLabel	2017-06-17 09:21:46	ok	193.250.222.82
1303	cpignol	zaalpes-containerPrintLabel	2017-06-17 09:22:05	ok	193.250.222.82
1304	cpignol	zaalpes-containerList	2017-06-17 09:22:17	ok	193.250.222.82
1305	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-17 09:22:18	ok	193.250.222.82
1306	cpignol	zaalpes-containerPrintLabel	2017-06-17 09:22:52	ok	193.250.222.82
1307	cpignol	zaalpes-containerList	2017-06-17 09:23:20	ok	193.250.222.82
1308	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-17 09:23:21	ok	193.250.222.82
1309	cpignol	zaalpes-containerPrintLabel	2017-06-17 09:23:40	ok	193.250.222.82
1310	cpignol	zaalpes-containerList	2017-06-17 09:23:46	ok	193.250.222.82
1311	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-17 09:23:47	ok	193.250.222.82
1312	cpignol	zaalpes-containerPrintLabel	2017-06-17 09:23:59	ok	193.250.222.82
1313	cpignol	zaalpes-containerPrintLabel	2017-06-17 09:24:23	ok	193.250.222.82
1314	cpignol	zaalpes-loginList	2017-06-17 09:32:17	ok	193.250.222.82
1315	cpignol	zaalpes-groupList	2017-06-17 09:32:55	ok	193.250.222.82
1316	cpignol	zaalpes-groupChange	2017-06-17 09:33:04	ok	193.250.222.82
1317	cpignol	zaalpes-appliList	2017-06-17 09:33:22	ok	193.250.222.82
1318	cpignol	zaalpes-appliDisplay	2017-06-17 09:33:28	ok	193.250.222.82
1319	cpignol	zaalpes-aclloginList	2017-06-17 09:33:44	ok	193.250.222.82
1320	unknown	zaalpes-containerList	2017-06-18 16:53:07	nologin	193.250.222.82
1321	cpignol	zaalpes-connexion	2017-06-18 17:08:30	db-ok	193.250.222.82
1322	cpignol	zaalpes-containerList	2017-06-18 17:08:30	ok	193.250.222.82
1323	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 17:08:31	ok	193.250.222.82
1324	cpignol	zaalpes-appliList	2017-06-18 17:08:38	ok	193.250.222.82
1325	cpignol	zaalpes-appliDisplay	2017-06-18 17:17:45	ok	193.250.222.82
1326	cpignol	zaalpes-disconnect	2017-06-18 17:33:39	ok	193.250.222.82
1327	unknown	zaalpes-connexion	2017-06-18 17:35:06	ok	193.250.222.82
1328	cpignol	zaalpes-connexion	2017-06-18 17:35:50	db-ok	193.250.222.82
1329	cpignol	zaalpes-default	2017-06-18 17:35:50	ok	193.250.222.82
1330	cpignol	zaalpes-aclloginList	2017-06-18 17:43:26	ok	193.250.222.82
1331	cpignol	zaalpes-loginList	2017-06-18 17:43:31	ok	193.250.222.82
1332	cpignol	zaalpes-loginChange	2017-06-18 17:43:40	ok	193.250.222.82
1333	cpignol	zaalpes-loginList	2017-06-18 17:43:49	ok	193.250.222.82
1334	cpignol	zaalpes-aclloginList	2017-06-18 18:00:52	ok	193.250.222.82
1335	cpignol	zaalpes-aclloginChange	2017-06-18 18:00:58	ok	193.250.222.82
1336	cpignol	zaalpes-groupList	2017-06-18 18:11:43	ok	193.250.222.82
1337	cpignol	zaalpes-appliList-connexion	2017-06-18 18:54:12	token-ok	193.250.222.82
1338	cpignol	zaalpes-appliList	2017-06-18 18:54:12	ok	193.250.222.82
1339	cpignol	zaalpes-appliDisplay	2017-06-18 18:54:18	ok	193.250.222.82
1340	cpignol	zaalpes-acoChange	2017-06-18 18:54:21	ok	193.250.222.82
1341	cpignol	zaalpes-appliDisplay	2017-06-18 18:55:09	ok	193.250.222.82
1342	cpignol	zaalpes-acoChange	2017-06-18 18:55:16	ok	193.250.222.82
1343	cpignol	zaalpes-appliDisplay	2017-06-18 18:55:19	ok	193.250.222.82
1344	cpignol	zaalpes-acoChange	2017-06-18 18:55:20	ok	193.250.222.82
1345	cpignol	zaalpes-default	2017-06-18 19:01:46	ok	193.250.222.82
1346	cpignol	zaalpes-containerFamilyList	2017-06-18 19:16:25	ok	193.250.222.82
1347	cpignol	zaalpes-containerFamilyChange	2017-06-18 19:16:29	ok	193.250.222.82
1348	cpignol	zaalpes-containerFamilyList	2017-06-18 19:16:33	ok	193.250.222.82
1349	cpignol	zaalpes-default	2017-06-18 19:16:33	ok	193.250.222.82
1350	cpignol	zaalpes-containerTypeList	2017-06-18 19:16:41	ok	193.250.222.82
1351	cpignol	zaalpes-storageConditionList	2017-06-18 19:24:49	ok	193.250.222.82
1352	cpignol	zaalpes-identifierTypeList-connexion	2017-06-18 21:16:23	token-ok	193.250.222.82
1353	cpignol	zaalpes-identifierTypeList	2017-06-18 21:16:23	ok	193.250.222.82
1354	cpignol	zaalpes-identifierTypeChange	2017-06-18 21:16:26	ok	193.250.222.82
1355	cpignol	zaalpes-operationList	2017-06-18 21:20:38	ok	193.250.222.82
1356	cpignol	zaalpes-labelChange	2017-06-18 21:24:59	ok	193.250.222.82
1357	cpignol	zaalpes-operationList	2017-06-18 21:25:12	ok	193.250.222.82
1358	cpignol	zaalpes-labelList	2017-06-18 21:25:19	ok	193.250.222.82
1359	cpignol	zaalpes-labelChange	2017-06-18 21:25:30	ok	193.250.222.82
1360	cpignol	zaalpes-containerList	2017-06-18 21:47:39	ok	193.250.222.82
1361	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 21:47:40	ok	193.250.222.82
1362	cpignol	zaalpes-containerChange	2017-06-18 21:47:42	ok	193.250.222.82
1363	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 21:47:43	ok	193.250.222.82
1364	cpignol	zaalpes-containerList	2017-06-18 21:47:44	ok	193.250.222.82
1365	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 21:47:45	ok	193.250.222.82
1366	cpignol	zaalpes-containerList	2017-06-18 21:47:46	ok	193.250.222.82
1367	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 21:47:46	ok	193.250.222.82
1368	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 21:47:56	ok	193.250.222.82
1369	cpignol	zaalpes-containerList	2017-06-18 21:47:57	ok	193.250.222.82
1370	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 21:47:58	ok	193.250.222.82
1371	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 21:48:02	ok	193.250.222.82
1372	cpignol	zaalpes-containerList	2017-06-18 21:48:02	ok	193.250.222.82
1373	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 21:48:03	ok	193.250.222.82
1374	cpignol	zaalpes-containerList	2017-06-18 21:48:25	ok	193.250.222.82
1375	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-18 21:48:26	ok	193.250.222.82
1376	cpignol	zaalpes-sampleList	2017-06-18 22:15:03	ok	193.250.222.82
1377	cpignol	zaalpes-sampleList	2017-06-18 22:15:05	ok	193.250.222.82
1378	cpignol	zaalpes-sampleDisplay	2017-06-18 22:15:10	ok	193.250.222.82
1379	cpignol	zaalpes-sampleChange	2017-06-18 22:15:16	ok	193.250.222.82
1380	unknown	zaalpes-sampleList	2017-06-19 09:17:44	nologin	10.4.2.103
1381	cpignol	zaalpes-connexion	2017-06-19 09:17:56	db-ok	10.4.2.103
1382	cpignol	zaalpes-sampleList	2017-06-19 09:17:56	ok	10.4.2.103
1383	cpignol	zaalpes-sampleList	2017-06-19 09:18:02	ok	10.4.2.103
1384	cpignol	zaalpes-sampleChange	2017-06-19 09:19:26	ok	10.4.2.103
1385	cpignol	zaalpes-parametre	2017-06-19 09:22:01	ok	10.4.2.103
1386	cpignol	zaalpes-parametre	2017-06-19 09:22:03	ok	10.4.2.103
1387	cpignol	zaalpes-parametre	2017-06-19 09:22:06	ok	10.4.2.103
1388	cpignol	zaalpes-samplingPlaceList	2017-06-19 09:22:13	ok	10.4.2.103
1389	cpignol	zaalpes-samplingPlaceChange	2017-06-19 09:23:03	ok	10.4.2.103
1390	cpignol	zaalpes-samplingPlaceWrite	2017-06-19 09:25:42	ok	10.4.2.103
1391	cpignol	zaalpes-SamplingPlace-write	2017-06-19 09:25:42	1	10.4.2.103
1392	cpignol	zaalpes-samplingPlaceList	2017-06-19 09:25:42	ok	10.4.2.103
1393	cpignol	zaalpes-samplingPlaceChange	2017-06-19 09:25:48	ok	10.4.2.103
1394	cpignol	zaalpes-samplingPlaceWrite	2017-06-19 09:25:59	ok	10.4.2.103
1395	cpignol	zaalpes-SamplingPlace-write	2017-06-19 09:25:59	2	10.4.2.103
1396	cpignol	zaalpes-samplingPlaceList	2017-06-19 09:25:59	ok	10.4.2.103
1397	cpignol	zaalpes-samplingPlaceChange	2017-06-19 09:33:25	ok	10.4.2.103
1398	cpignol	zaalpes-samplingPlaceList	2017-06-19 09:34:03	ok	10.4.2.103
1399	cpignol	zaalpes-importChange	2017-06-19 09:35:02	ok	10.4.2.103
1400	cpignol	zaalpes-sampleTypeList	2017-06-19 09:42:41	ok	10.4.2.103
1401	cpignol	zaalpes-objectStatusList	2017-06-19 09:42:56	ok	10.4.2.103
1402	cpignol	zaalpes-sampleTypeList	2017-06-19 09:43:32	ok	10.4.2.103
1403	cpignol	zaalpes-projectList	2017-06-19 09:43:56	ok	10.4.2.103
1404	cpignol	zaalpes-samplingPlaceList	2017-06-19 09:44:35	ok	10.4.2.103
1405	cpignol	zaalpes-sampleList	2017-06-19 09:49:57	ok	10.4.2.103
1406	cpignol	zaalpes-sampleDisplay	2017-06-19 09:50:01	ok	10.4.2.103
1407	cpignol	zaalpes-sampleChange	2017-06-19 09:50:06	ok	10.4.2.103
1408	cpignol	zaalpes-sampleWrite	2017-06-19 09:50:41	ok	10.4.2.103
1409	cpignol	zaalpes-Sample-write	2017-06-19 09:50:41	89	10.4.2.103
1410	cpignol	zaalpes-sampleDisplay	2017-06-19 09:50:41	ok	10.4.2.103
1411	cpignol	zaalpes-importChange	2017-06-19 10:02:54	ok	10.4.2.103
1412	cpignol	zaalpes-sampleList	2017-06-19 10:03:05	ok	10.4.2.103
1413	cpignol	zaalpes-sampleDisplay	2017-06-19 10:03:19	ok	10.4.2.103
1414	cpignol	zaalpes-sampleChange	2017-06-19 10:03:31	ok	10.4.2.103
1415	cpignol	zaalpes-sampleList	2017-06-19 10:04:04	ok	10.4.2.103
1416	cpignol	zaalpes-containerList	2017-06-19 10:04:10	ok	10.4.2.103
1417	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:04:12	ok	10.4.2.103
1418	cpignol	zaalpes-containerList	2017-06-19 10:04:14	ok	10.4.2.103
1419	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:04:16	ok	10.4.2.103
1420	cpignol	zaalpes-containerDisplay	2017-06-19 10:04:23	ok	10.4.2.103
1421	cpignol	zaalpes-containerChange	2017-06-19 10:04:52	ok	10.4.2.103
1422	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:04:54	ok	10.4.2.103
1423	cpignol	zaalpes-containerList	2017-06-19 10:05:13	ok	10.4.2.103
1424	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:05:15	ok	10.4.2.103
1425	cpignol	zaalpes-importChange	2017-06-19 10:07:37	ok	10.4.2.103
1426	cpignol	zaalpes-containerList	2017-06-19 10:14:53	ok	10.4.2.103
1427	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:14:55	ok	10.4.2.103
1428	cpignol	zaalpes-objectStatusList	2017-06-19 10:16:05	ok	10.4.2.103
1429	cpignol	zaalpes-containerTypeList	2017-06-19 10:16:31	ok	10.4.2.103
1430	cpignol	zaalpes-importChange	2017-06-19 10:28:27	ok	10.4.2.103
1431	cpignol	zaalpes-importControl	2017-06-19 10:28:43	ok	10.4.2.103
1432	cpignol	zaalpes-importChange	2017-06-19 10:28:43	ok	10.4.2.103
1433	cpignol	zaalpes-importControl	2017-06-19 10:28:59	ok	10.4.2.103
1434	cpignol	zaalpes-importChange	2017-06-19 10:28:59	ok	10.4.2.103
1435	cpignol	zaalpes-importControl	2017-06-19 10:31:35	ok	10.4.2.103
1436	cpignol	zaalpes-importChange	2017-06-19 10:31:35	ok	10.4.2.103
1437	cpignol	zaalpes-importControl	2017-06-19 10:32:36	ok	10.4.2.103
1438	cpignol	zaalpes-importChange	2017-06-19 10:32:36	ok	10.4.2.103
1439	cpignol	zaalpes-importImport	2017-06-19 10:32:44	ok	10.4.2.103
1440	cpignol	zaalpes-importChange	2017-06-19 10:32:44	ok	10.4.2.103
1441	cpignol	zaalpes-objets	2017-06-19 10:33:31	ok	10.4.2.103
1442	cpignol	zaalpes-sampleList	2017-06-19 10:33:35	ok	10.4.2.103
1443	cpignol	zaalpes-sampleDisplay	2017-06-19 10:33:48	ok	10.4.2.103
1444	cpignol	zaalpes-containerDisplay	2017-06-19 10:34:19	ok	10.4.2.103
1445	cpignol	zaalpes-sampleDisplay	2017-06-19 10:34:43	ok	10.4.2.103
1446	cpignol	zaalpes-containerList	2017-06-19 10:34:57	ok	10.4.2.103
1447	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:34:59	ok	10.4.2.103
1448	cpignol	zaalpes-containerDisplay	2017-06-19 10:35:20	ok	10.4.2.103
1449	cpignol	zaalpes-containerList	2017-06-19 10:35:35	ok	10.4.2.103
1450	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:35:37	ok	10.4.2.103
1451	cpignol	zaalpes-containerDisplay	2017-06-19 10:35:44	ok	10.4.2.103
1452	cpignol	zaalpes-containerList	2017-06-19 10:36:02	ok	10.4.2.103
1453	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:36:04	ok	10.4.2.103
1454	cpignol	zaalpes-containerDisplay	2017-06-19 10:36:08	ok	10.4.2.103
1455	cpignol	zaalpes-containerList	2017-06-19 10:36:28	ok	10.4.2.103
1456	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:36:30	ok	10.4.2.103
1457	cpignol	zaalpes-containerDisplay	2017-06-19 10:36:35	ok	10.4.2.103
1458	cpignol	zaalpes-containerList	2017-06-19 10:36:50	ok	10.4.2.103
1459	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:36:53	ok	10.4.2.103
1460	cpignol	zaalpes-importChange	2017-06-19 10:36:58	ok	10.4.2.103
1461	cpignol	zaalpes-containerList	2017-06-19 10:42:18	ok	10.4.2.103
1462	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:42:20	ok	10.4.2.103
1463	cpignol	zaalpes-objets	2017-06-19 10:58:25	ok	10.4.2.103
1464	cpignol	zaalpes-sampleList	2017-06-19 10:58:28	ok	10.4.2.103
1465	cpignol	zaalpes-importChange	2017-06-19 10:58:47	ok	10.4.2.103
1466	cpignol	zaalpes-importControl	2017-06-19 10:58:59	ok	10.4.2.103
1467	cpignol	zaalpes-importChange	2017-06-19 10:58:59	ok	10.4.2.103
1468	cpignol	zaalpes-containerList	2017-06-19 10:59:56	ok	10.4.2.103
1469	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 10:59:59	ok	10.4.2.103
1470	cpignol	zaalpes-containerList	2017-06-19 11:00:39	ok	10.4.2.103
1471	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 11:00:41	ok	10.4.2.103
1472	cpignol	zaalpes-importChange	2017-06-19 11:00:43	ok	10.4.2.103
1473	cpignol	zaalpes-importControl	2017-06-19 11:00:53	ok	10.4.2.103
1474	cpignol	zaalpes-importChange	2017-06-19 11:00:53	ok	10.4.2.103
1475	cpignol	zaalpes-importImport	2017-06-19 11:01:04	ok	10.4.2.103
1476	cpignol	zaalpes-importChange	2017-06-19 11:01:04	ok	10.4.2.103
1477	cpignol	zaalpes-sampleList	2017-06-19 11:01:35	ok	10.4.2.103
1478	cpignol	zaalpes-sampleList-connexion	2017-06-19 12:23:45	token-ok	10.4.2.103
1479	cpignol	zaalpes-sampleList	2017-06-19 12:23:45	ok	10.4.2.103
1480	cpignol	zaalpes-sampleList	2017-06-19 12:26:00	ok	10.4.2.103
1481	cpignol	zaalpes-sampleList	2017-06-19 12:27:07	ok	10.4.2.103
1482	cpignol	zaalpes-sampleDisplay	2017-06-19 12:27:33	ok	10.4.2.103
1483	cpignol	zaalpes-sampleChange	2017-06-19 12:27:51	ok	10.4.2.103
1484	cpignol	zaalpes-sampleWrite	2017-06-19 12:30:07	ok	10.4.2.103
1485	cpignol	zaalpes-Sample-write	2017-06-19 12:30:07	90	10.4.2.103
1486	cpignol	zaalpes-sampleDisplay	2017-06-19 12:30:07	ok	10.4.2.103
1487	cpignol	zaalpes-sampleList	2017-06-19 12:30:14	ok	10.4.2.103
1488	cpignol	zaalpes-sampleDisplay	2017-06-19 12:30:18	ok	10.4.2.103
1489	cpignol	zaalpes-sampleChange	2017-06-19 12:30:24	ok	10.4.2.103
1490	cpignol	zaalpes-sampleWrite	2017-06-19 12:32:48	ok	10.4.2.103
1491	cpignol	zaalpes-Sample-write	2017-06-19 12:32:48	92	10.4.2.103
1492	cpignol	zaalpes-sampleDisplay	2017-06-19 12:32:48	ok	10.4.2.103
1493	cpignol	zaalpes-sampleList	2017-06-19 12:32:57	ok	10.4.2.103
1494	cpignol	zaalpes-samplePrintLabel	2017-06-19 12:33:04	ok	10.4.2.103
1495	cpignol	zaalpes-labelList-connexion	2017-06-19 13:17:11	token-ok	10.4.2.103
1496	cpignol	zaalpes-labelList	2017-06-19 13:17:11	ok	10.4.2.103
1497	cpignol	zaalpes-labelChange	2017-06-19 13:17:16	ok	10.4.2.103
1498	cpignol	zaalpes-labelWrite	2017-06-19 13:29:48	ok	10.4.2.103
1499	cpignol	zaalpes-Label-write	2017-06-19 13:29:48	5	10.4.2.103
1500	cpignol	zaalpes-labelList	2017-06-19 13:29:48	ok	10.4.2.103
1501	cpignol	zaalpes-containerList	2017-06-19 13:29:54	ok	10.4.2.103
1502	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-19 13:29:56	ok	10.4.2.103
1503	cpignol	zaalpes-sampleList	2017-06-19 13:29:58	ok	10.4.2.103
1504	cpignol	zaalpes-sampleList	2017-06-19 13:30:01	ok	10.4.2.103
1505	cpignol	zaalpes-samplePrintLabel	2017-06-19 13:30:18	ok	10.4.2.103
1506	cpignol	zaalpes-parametre	2017-06-19 13:31:01	ok	10.4.2.103
1507	cpignol	zaalpes-labelList	2017-06-19 13:31:11	ok	10.4.2.103
1508	cpignol	zaalpes-labelChange	2017-06-19 13:31:14	ok	10.4.2.103
1509	cpignol	zaalpes-labelWrite	2017-06-19 13:31:30	ok	10.4.2.103
1510	cpignol	zaalpes-Label-write	2017-06-19 13:31:30	5	10.4.2.103
1511	cpignol	zaalpes-labelList	2017-06-19 13:31:30	ok	10.4.2.103
1512	cpignol	zaalpes-default	2017-06-19 13:31:46	ok	10.4.2.103
1513	cpignol	zaalpes-sampleList	2017-06-19 13:31:54	ok	10.4.2.103
1514	cpignol	zaalpes-sampleDisplay	2017-06-19 13:31:58	ok	10.4.2.103
1515	cpignol	zaalpes-sampleList	2017-06-19 13:32:01	ok	10.4.2.103
1516	cpignol	zaalpes-samplePrintLabel	2017-06-19 13:32:11	ok	10.4.2.103
1517	cpignol	zaalpes-labelChange	2017-06-19 13:35:58	ok	10.4.2.103
1518	cpignol	zaalpes-labelWrite	2017-06-19 13:41:05	ok	10.4.2.103
1519	cpignol	zaalpes-Label-write	2017-06-19 13:41:05	5	10.4.2.103
1520	cpignol	zaalpes-labelList	2017-06-19 13:41:05	ok	10.4.2.103
1521	cpignol	zaalpes-sampleList	2017-06-19 13:41:14	ok	10.4.2.103
1522	cpignol	zaalpes-samplePrintLabel	2017-06-19 13:41:26	ok	10.4.2.103
1523	cpignol	zaalpes-labelChange	2017-06-19 13:47:33	ok	10.4.2.103
1524	cpignol	zaalpes-labelWrite	2017-06-19 13:48:22	ok	10.4.2.103
1525	cpignol	zaalpes-Label-write	2017-06-19 13:48:22	5	10.4.2.103
1526	cpignol	zaalpes-labelList	2017-06-19 13:48:22	ok	10.4.2.103
1527	cpignol	zaalpes-sampleList	2017-06-19 13:48:36	ok	10.4.2.103
1528	cpignol	zaalpes-samplePrintLabel	2017-06-19 13:48:48	ok	10.4.2.103
1529	cpignol	zaalpes-labelChange	2017-06-19 13:49:37	ok	10.4.2.103
1530	cpignol	zaalpes-labelWrite-connexion	2017-06-19 17:50:14	token-ok	10.4.2.103
1531	cpignol	zaalpes-labelWrite	2017-06-19 17:50:14	errorbefore	10.4.2.103
1532	cpignol	zaalpes-errorbefore	2017-06-19 17:50:14	ok	10.4.2.103
1533	cpignol	zaalpes-labelList	2017-06-19 17:50:25	ok	10.4.2.103
1534	cpignol	zaalpes-labelChange	2017-06-19 17:50:28	ok	10.4.2.103
1535	cpignol	zaalpes-labelWrite	2017-06-19 17:52:32	ok	10.4.2.103
1536	cpignol	zaalpes-Label-write	2017-06-19 17:52:32	5	10.4.2.103
1537	cpignol	zaalpes-labelList	2017-06-19 17:52:32	ok	10.4.2.103
1538	cpignol	zaalpes-sampleList	2017-06-19 17:52:53	ok	10.4.2.103
1539	cpignol	zaalpes-sampleList	2017-06-19 17:52:57	ok	10.4.2.103
1540	cpignol	zaalpes-samplePrintLabel	2017-06-19 17:53:10	ok	10.4.2.103
1541	cpignol	zaalpes-labelChange	2017-06-19 17:53:37	ok	10.4.2.103
1542	cpignol	zaalpes-labelWrite	2017-06-19 17:54:13	ok	10.4.2.103
1543	cpignol	zaalpes-Label-write	2017-06-19 17:54:13	5	10.4.2.103
1544	cpignol	zaalpes-labelList	2017-06-19 17:54:13	ok	10.4.2.103
1545	cpignol	zaalpes-sampleList	2017-06-19 17:54:20	ok	10.4.2.103
1546	cpignol	zaalpes-sampleDisplay	2017-06-19 17:54:30	ok	10.4.2.103
1547	cpignol	zaalpes-sampleList	2017-06-19 17:54:34	ok	10.4.2.103
1548	cpignol	zaalpes-samplePrintLabel	2017-06-19 17:54:47	ok	10.4.2.103
1549	cpignol	zaalpes-labelChange	2017-06-19 17:57:10	ok	10.4.2.103
1550	cpignol	zaalpes-labelWrite	2017-06-19 17:57:58	ok	10.4.2.103
1551	cpignol	zaalpes-Label-write	2017-06-19 17:57:58	5	10.4.2.103
1552	cpignol	zaalpes-labelList	2017-06-19 17:57:58	ok	10.4.2.103
1553	cpignol	zaalpes-sampleList	2017-06-19 17:58:04	ok	10.4.2.103
1554	cpignol	zaalpes-samplePrintLabel	2017-06-19 17:58:15	ok	10.4.2.103
1555	cpignol	zaalpes-labelChange	2017-06-19 17:58:42	ok	10.4.2.103
1556	cpignol	zaalpes-labelWrite	2017-06-19 17:59:07	ok	10.4.2.103
1557	cpignol	zaalpes-Label-write	2017-06-19 17:59:07	5	10.4.2.103
1558	cpignol	zaalpes-labelList	2017-06-19 17:59:07	ok	10.4.2.103
1559	cpignol	zaalpes-sampleList	2017-06-19 17:59:15	ok	10.4.2.103
1560	cpignol	zaalpes-samplePrintLabel	2017-06-19 17:59:22	ok	10.4.2.103
1561	cpignol	zaalpes-labelChange	2017-06-19 17:59:57	ok	10.4.2.103
1562	cpignol	zaalpes-labelWrite	2017-06-19 18:00:54	ok	10.4.2.103
1563	cpignol	zaalpes-Label-write	2017-06-19 18:00:54	5	10.4.2.103
1564	cpignol	zaalpes-labelList	2017-06-19 18:00:54	ok	10.4.2.103
1565	cpignol	zaalpes-sampleList	2017-06-19 18:01:00	ok	10.4.2.103
1566	cpignol	zaalpes-samplePrintLabel	2017-06-19 18:01:10	ok	10.4.2.103
1567	unknown	zaalpes-default	2017-06-20 10:07:47	ok	193.48.126.37
1568	unknown	zaalpes-default	2017-06-20 10:08:12	ok	193.48.126.37
1569	unknown	zaalpes-loginChangePassword	2017-06-20 10:18:14	ok	193.48.126.37
1570	cpignol	zaalpes-connexion	2017-06-20 10:18:42	db-ok	193.48.126.37
1571	cpignol	zaalpes-default	2017-06-20 10:18:42	ok	193.48.126.37
1572	cpignol	zaalpes-containerList	2017-06-20 10:19:59	ok	193.48.126.37
1573	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 10:20:00	ok	193.48.126.37
1574	cpignol	zaalpes-containerFamilyList	2017-06-20 10:20:19	ok	193.48.126.37
1575	cpignol	zaalpes-containerFamilyChange	2017-06-20 10:20:27	ok	193.48.126.37
1576	cpignol	zaalpes-containerFamilyList	2017-06-20 10:20:30	ok	193.48.126.37
1577	cpignol	zaalpes-loginList	2017-06-20 10:21:00	ok	193.48.126.37
1578	cpignol	zaalpes-loginChange	2017-06-20 10:21:18	ok	193.48.126.37
1579	cpignol	zaalpes-loginList	2017-06-20 10:22:03	ok	193.48.126.37
1580	cpignol	zaalpes-loginChange	2017-06-20 10:22:59	ok	193.48.126.37
1581	cpignol	zaalpes-loginList	2017-06-20 10:23:05	ok	193.48.126.37
1582	cpignol	zaalpes-appliList	2017-06-20 10:23:08	ok	193.48.126.37
1583	cpignol	zaalpes-appliDisplay	2017-06-20 10:23:20	ok	193.48.126.37
1584	cpignol	zaalpes-administration	2017-06-20 10:23:28	ok	193.48.126.37
1585	cpignol	zaalpes-administration	2017-06-20 10:23:31	ok	193.48.126.37
1586	cpignol	zaalpes-administration	2017-06-20 10:23:33	ok	193.48.126.37
1587	cpignol	zaalpes-administration	2017-06-20 10:23:35	ok	193.48.126.37
1588	cpignol	zaalpes-groupList	2017-06-20 10:23:40	ok	193.48.126.37
1589	cpignol	zaalpes-administration	2017-06-20 10:24:41	ok	193.48.126.37
1590	cpignol	zaalpes-groupList	2017-06-20 10:24:46	ok	193.48.126.37
1591	cpignol	zaalpes-groupChange	2017-06-20 10:24:50	ok	193.48.126.37
1592	cpignol	zaalpes-groupList	2017-06-20 10:25:05	ok	193.48.126.37
1593	cpignol	zaalpes-groupChange	2017-06-20 10:25:08	ok	193.48.126.37
1594	cpignol	zaalpes-groupList	2017-06-20 10:25:12	ok	193.48.126.37
1595	cpignol	zaalpes-parametre	2017-06-20 10:26:04	ok	193.48.126.37
1596	cpignol	zaalpes-projectList	2017-06-20 10:27:00	ok	193.48.126.37
1597	cpignol	zaalpes-projectChange	2017-06-20 10:28:04	ok	193.48.126.37
1598	cpignol	zaalpes-projectList	2017-06-20 10:28:59	ok	193.48.126.37
1599	cpignol	zaalpes-parametre	2017-06-20 10:29:04	ok	193.48.126.37
1600	cpignol	zaalpes-parametre	2017-06-20 10:29:08	ok	193.48.126.37
1601	cpignol	zaalpes-administration	2017-06-20 10:31:03	ok	193.48.126.37
1602	cpignol	zaalpes-administration	2017-06-20 10:31:05	ok	193.48.126.37
1603	cpignol	zaalpes-administration	2017-06-20 10:31:07	ok	193.48.126.37
1604	cpignol	zaalpes-administration	2017-06-20 10:31:09	ok	193.48.126.37
1605	cpignol	zaalpes-administration	2017-06-20 10:31:11	ok	193.48.126.37
1606	cpignol	zaalpes-groupList	2017-06-20 10:31:38	ok	193.48.126.37
1607	cpignol	zaalpes-containerFamilyList	2017-06-20 10:33:09	ok	193.48.126.37
1608	cpignol	zaalpes-containerFamilyChange	2017-06-20 10:33:23	ok	193.48.126.37
1609	cpignol	zaalpes-containerFamilyList	2017-06-20 10:33:31	ok	193.48.126.37
1610	cpignol	zaalpes-groupList	2017-06-20 10:34:01	ok	193.48.126.37
1611	cpignol	zaalpes-parametre	2017-06-20 10:34:05	ok	193.48.126.37
1612	cpignol	zaalpes-parametre	2017-06-20 10:34:07	ok	193.48.126.37
1613	cpignol	zaalpes-parametre	2017-06-20 10:34:09	ok	193.48.126.37
1614	cpignol	zaalpes-parametre	2017-06-20 10:34:11	ok	193.48.126.37
1615	cpignol	zaalpes-storageConditionList	2017-06-20 10:34:30	ok	193.48.126.37
1616	cpignol	zaalpes-storageConditionChange	2017-06-20 10:34:55	ok	193.48.126.37
1617	cpignol	zaalpes-storageConditionList	2017-06-20 10:35:01	ok	193.48.126.37
1618	cpignol	zaalpes-containerTypeList	2017-06-20 10:35:35	ok	193.48.126.37
1619	cpignol	zaalpes-containerTypeChange	2017-06-20 10:36:15	ok	193.48.126.37
1620	cpignol	zaalpes-containerTypeList	2017-06-20 10:36:56	ok	193.48.126.37
1621	cpignol	zaalpes-containerTypeChange	2017-06-20 10:37:29	ok	193.48.126.37
1622	cpignol	zaalpes-containerTypeList	2017-06-20 10:37:33	ok	193.48.126.37
1623	cpignol	zaalpes-sampleTypeList	2017-06-20 10:38:38	ok	193.48.126.37
1624	cpignol	zaalpes-protocolList	2017-06-20 10:39:46	ok	193.48.126.37
1625	cpignol	zaalpes-protocolChange	2017-06-20 10:39:55	ok	193.48.126.37
1626	cpignol	zaalpes-parametre	2017-06-20 10:41:54	ok	193.48.126.37
1627	cpignol	zaalpes-operationList	2017-06-20 10:42:03	ok	193.48.126.37
1628	cpignol	zaalpes-operationChange	2017-06-20 10:42:38	ok	193.48.126.37
1629	cpignol	zaalpes-samplingPlaceList	2017-06-20 10:45:20	ok	193.48.126.37
1630	cpignol	zaalpes-identifierTypeList	2017-06-20 10:45:52	ok	193.48.126.37
1631	cpignol	zaalpes-samplingPlaceList	2017-06-20 10:45:58	ok	193.48.126.37
1632	cpignol	zaalpes-samplingPlaceList	2017-06-20 10:46:08	ok	193.48.126.37
1633	cpignol	zaalpes-samplingPlaceChange	2017-06-20 10:46:11	ok	193.48.126.37
1634	cpignol	zaalpes-sampleTypeList	2017-06-20 10:49:29	ok	193.48.126.37
1635	cpignol	zaalpes-sampleTypeChange	2017-06-20 10:49:33	ok	193.48.126.37
1636	cpignol	zaalpes-objectStatusList	2017-06-20 10:50:46	ok	193.48.126.37
1637	cpignol	zaalpes-objectStatusChange	2017-06-20 10:51:48	ok	193.48.126.37
1638	cpignol	zaalpes-objectStatusList	2017-06-20 10:51:53	ok	193.48.126.37
1639	cpignol	zaalpes-objectStatusChange	2017-06-20 10:52:09	ok	193.48.126.37
1640	cpignol	zaalpes-objectStatusList	2017-06-20 10:52:14	ok	193.48.126.37
1641	cpignol	zaalpes-parametre	2017-06-20 10:52:38	ok	193.48.126.37
1642	cpignol	zaalpes-labelList	2017-06-20 10:52:42	ok	193.48.126.37
1643	cpignol	zaalpes-labelChange	2017-06-20 10:52:57	ok	193.48.126.37
1644	cpignol	zaalpes-labelList	2017-06-20 10:54:06	ok	193.48.126.37
1645	cpignol	zaalpes-labelChange	2017-06-20 10:54:09	ok	193.48.126.37
1646	cpignol	zaalpes-labelList	2017-06-20 10:54:21	ok	193.48.126.37
1647	cpignol	zaalpes-labelChange	2017-06-20 10:54:24	ok	193.48.126.37
1648	cpignol	zaalpes-labelList	2017-06-20 10:54:29	ok	193.48.126.37
1649	cpignol	zaalpes-labelChange	2017-06-20 10:54:38	ok	193.48.126.37
1650	cpignol	zaalpes-labelList	2017-06-20 10:54:41	ok	193.48.126.37
1651	cpignol	zaalpes-administration	2017-06-20 10:54:45	ok	193.48.126.37
1652	cpignol	zaalpes-multipleTypeList	2017-06-20 10:54:50	ok	193.48.126.37
1653	cpignol	zaalpes-multipleTypeChange	2017-06-20 10:55:50	ok	193.48.126.37
1654	cpignol	zaalpes-multipleTypeList	2017-06-20 10:55:53	ok	193.48.126.37
1655	cpignol	zaalpes-administration	2017-06-20 10:55:57	ok	193.48.126.37
1656	cpignol	zaalpes-identifierTypeList	2017-06-20 10:56:02	ok	193.48.126.37
1657	cpignol	zaalpes-identifierTypeChange	2017-06-20 10:56:06	ok	193.48.126.37
1658	cpignol	zaalpes-identifierTypeList	2017-06-20 10:56:10	ok	193.48.126.37
1659	cpignol	zaalpes-parametre	2017-06-20 10:56:12	ok	193.48.126.37
1660	cpignol	zaalpes-parametre	2017-06-20 10:56:14	ok	193.48.126.37
1661	cpignol	zaalpes-parametre	2017-06-20 10:56:17	ok	193.48.126.37
1662	cpignol	zaalpes-parametre	2017-06-20 10:56:19	ok	193.48.126.37
1663	cpignol	zaalpes-parametre	2017-06-20 10:56:22	ok	193.48.126.37
1664	cpignol	zaalpes-parametre	2017-06-20 10:56:24	ok	193.48.126.37
1665	cpignol	zaalpes-parametre	2017-06-20 10:56:26	ok	193.48.126.37
1666	cpignol	zaalpes-parametre	2017-06-20 10:56:38	ok	193.48.126.37
1667	cpignol	zaalpes-parametre	2017-06-20 10:56:54	ok	193.48.126.37
1668	cpignol	zaalpes-parametre	2017-06-20 10:56:58	ok	193.48.126.37
1669	cpignol	zaalpes-labelList	2017-06-20 10:57:26	ok	193.48.126.37
1670	cpignol	zaalpes-parametre	2017-06-20 10:57:43	ok	193.48.126.37
1671	cpignol	zaalpes-containerList	2017-06-20 10:58:25	ok	193.48.126.37
1672	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 10:58:26	ok	193.48.126.37
1673	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 10:58:33	ok	193.48.126.37
1674	cpignol	zaalpes-containerList	2017-06-20 10:58:37	ok	193.48.126.37
1675	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 10:58:39	ok	193.48.126.37
1676	cpignol	zaalpes-containerDisplay	2017-06-20 11:00:09	ok	193.48.126.37
1677	cpignol	zaalpes-containerChange	2017-06-20 11:22:17	ok	193.48.126.37
1678	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:22:20	ok	193.48.126.37
1679	cpignol	zaalpes-containerWrite	2017-06-20 11:22:58	ok	193.48.126.37
1680	cpignol	zaalpes-Container-write	2017-06-20 11:22:58	2	193.48.126.37
1681	cpignol	zaalpes-containerDisplay	2017-06-20 11:22:58	ok	193.48.126.37
1682	cpignol	zaalpes-containerList	2017-06-20 11:23:45	ok	193.48.126.37
1683	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:23:46	ok	193.48.126.37
1684	cpignol	zaalpes-containerDisplay	2017-06-20 11:23:49	ok	193.48.126.37
1685	cpignol	zaalpes-containerChange	2017-06-20 11:23:54	ok	193.48.126.37
1686	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:23:56	ok	193.48.126.37
1687	cpignol	zaalpes-containerWrite	2017-06-20 11:24:11	ok	193.48.126.37
1688	cpignol	zaalpes-Container-write	2017-06-20 11:24:11	5	193.48.126.37
1689	cpignol	zaalpes-containerDisplay	2017-06-20 11:24:11	ok	193.48.126.37
1690	cpignol	zaalpes-containerList	2017-06-20 11:24:29	ok	193.48.126.37
1691	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:24:30	ok	193.48.126.37
1692	cpignol	zaalpes-containerDisplay	2017-06-20 11:24:36	ok	193.48.126.37
1693	cpignol	zaalpes-containerChange	2017-06-20 11:27:49	ok	193.48.126.37
1694	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:27:51	ok	193.48.126.37
1695	cpignol	zaalpes-containerWrite	2017-06-20 11:28:07	ok	193.48.126.37
1696	cpignol	zaalpes-Container-write	2017-06-20 11:28:07	3	193.48.126.37
1697	cpignol	zaalpes-containerDisplay	2017-06-20 11:28:07	ok	193.48.126.37
1698	cpignol	zaalpes-containerChange	2017-06-20 11:28:46	ok	193.48.126.37
1699	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:28:48	ok	193.48.126.37
1700	cpignol	zaalpes-containerWrite	2017-06-20 11:29:01	ok	193.48.126.37
1701	cpignol	zaalpes-Container-write	2017-06-20 11:29:01	3	193.48.126.37
1702	cpignol	zaalpes-containerDisplay	2017-06-20 11:29:01	ok	193.48.126.37
1703	cpignol	zaalpes-containerList	2017-06-20 11:29:04	ok	193.48.126.37
1704	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:29:05	ok	193.48.126.37
1705	cpignol	zaalpes-containerDisplay	2017-06-20 11:29:11	ok	193.48.126.37
1706	cpignol	zaalpes-containerList	2017-06-20 11:29:19	ok	193.48.126.37
1707	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:29:21	ok	193.48.126.37
1708	cpignol	zaalpes-containerDisplay	2017-06-20 11:29:23	ok	193.48.126.37
1709	cpignol	zaalpes-containerChange	2017-06-20 11:29:26	ok	193.48.126.37
1710	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:29:28	ok	193.48.126.37
1711	cpignol	zaalpes-containerWrite	2017-06-20 11:29:40	ok	193.48.126.37
1712	cpignol	zaalpes-Container-write	2017-06-20 11:29:40	4	193.48.126.37
1713	cpignol	zaalpes-containerDisplay	2017-06-20 11:29:40	ok	193.48.126.37
1714	cpignol	zaalpes-containerList	2017-06-20 11:29:44	ok	193.48.126.37
1715	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:29:46	ok	193.48.126.37
1716	cpignol	zaalpes-containerDisplay	2017-06-20 11:29:48	ok	193.48.126.37
1717	cpignol	zaalpes-containerChange	2017-06-20 11:29:51	ok	193.48.126.37
1718	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:29:54	ok	193.48.126.37
1719	cpignol	zaalpes-containerWrite	2017-06-20 11:30:10	ok	193.48.126.37
1720	cpignol	zaalpes-Container-write	2017-06-20 11:30:10	3	193.48.126.37
1721	cpignol	zaalpes-containerDisplay	2017-06-20 11:30:10	ok	193.48.126.37
1722	cpignol	zaalpes-containerList	2017-06-20 11:30:22	ok	193.48.126.37
1723	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:30:24	ok	193.48.126.37
1724	cpignol	zaalpes-containerDisplay	2017-06-20 11:30:26	ok	193.48.126.37
1725	cpignol	zaalpes-containerList	2017-06-20 11:31:00	ok	193.48.126.37
1726	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:31:01	ok	193.48.126.37
1727	cpignol	zaalpes-containerDisplay	2017-06-20 11:31:04	ok	193.48.126.37
1728	cpignol	zaalpes-containerChange	2017-06-20 11:31:16	ok	193.48.126.37
1729	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:31:18	ok	193.48.126.37
1730	cpignol	zaalpes-containerWrite	2017-06-20 11:31:31	ok	193.48.126.37
1731	cpignol	zaalpes-Container-write	2017-06-20 11:31:31	6	193.48.126.37
1732	cpignol	zaalpes-containerDisplay	2017-06-20 11:31:31	ok	193.48.126.37
1733	cpignol	zaalpes-containerChange	2017-06-20 11:31:47	ok	193.48.126.37
1734	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:31:49	ok	193.48.126.37
1735	cpignol	zaalpes-containerWrite	2017-06-20 11:32:00	ok	193.48.126.37
1736	cpignol	zaalpes-Container-write	2017-06-20 11:32:00	6	193.48.126.37
1737	cpignol	zaalpes-containerDisplay	2017-06-20 11:32:00	ok	193.48.126.37
1738	cpignol	zaalpes-containerList	2017-06-20 11:32:17	ok	193.48.126.37
1739	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:32:18	ok	193.48.126.37
1740	cpignol	zaalpes-containerTypeList	2017-06-20 11:32:36	ok	193.48.126.37
1741	cpignol	zaalpes-parametre	2017-06-20 11:32:42	ok	193.48.126.37
1742	cpignol	zaalpes-containerList	2017-06-20 11:32:45	ok	193.48.126.37
1743	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:32:46	ok	193.48.126.37
1744	cpignol	zaalpes-containerDisplay	2017-06-20 11:32:51	ok	193.48.126.37
1745	cpignol	zaalpes-containerList	2017-06-20 11:32:54	ok	193.48.126.37
1746	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:32:56	ok	193.48.126.37
1747	cpignol	zaalpes-containerDisplay	2017-06-20 11:32:57	ok	193.48.126.37
1748	cpignol	zaalpes-sampleList	2017-06-20 11:35:20	ok	193.48.126.37
1749	cpignol	zaalpes-containerDisplay	2017-06-20 11:35:49	ok	193.48.126.37
1750	cpignol	zaalpes-objets	2017-06-20 11:35:55	ok	193.48.126.37
1751	cpignol	zaalpes-containerList	2017-06-20 11:36:00	ok	193.48.126.37
1752	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:36:02	ok	193.48.126.37
1753	cpignol	zaalpes-containerDisplay	2017-06-20 11:36:10	ok	193.48.126.37
1754	cpignol	zaalpes-containerChange	2017-06-20 11:36:17	ok	193.48.126.37
1755	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:36:19	ok	193.48.126.37
1756	cpignol	zaalpes-containerWrite	2017-06-20 11:38:01	ok	193.48.126.37
1757	cpignol	zaalpes-Container-write	2017-06-20 11:38:01	88	193.48.126.37
1758	cpignol	zaalpes-containerDisplay	2017-06-20 11:38:01	ok	193.48.126.37
1759	cpignol	zaalpes-containerList	2017-06-20 11:38:34	ok	193.48.126.37
1760	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:38:36	ok	193.48.126.37
1761	cpignol	zaalpes-containerDisplay	2017-06-20 11:38:39	ok	193.48.126.37
1762	cpignol	zaalpes-containerChange	2017-06-20 11:38:47	ok	193.48.126.37
1763	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:38:50	ok	193.48.126.37
1764	cpignol	zaalpes-containerWrite	2017-06-20 11:39:19	ok	193.48.126.37
1765	cpignol	zaalpes-Container-write	2017-06-20 11:39:19	2	193.48.126.37
1766	cpignol	zaalpes-containerDisplay	2017-06-20 11:39:19	ok	193.48.126.37
1767	cpignol	zaalpes-containerList	2017-06-20 11:39:23	ok	193.48.126.37
1768	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:39:25	ok	193.48.126.37
1769	cpignol	zaalpes-containerDisplay	2017-06-20 11:39:26	ok	193.48.126.37
1770	cpignol	zaalpes-containerList	2017-06-20 11:40:08	ok	193.48.126.37
1771	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:40:09	ok	193.48.126.37
1772	cpignol	zaalpes-containerDisplay	2017-06-20 11:40:11	ok	193.48.126.37
1773	cpignol	zaalpes-containerChange	2017-06-20 11:40:21	ok	193.48.126.37
1774	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:40:23	ok	193.48.126.37
1775	cpignol	zaalpes-containerWrite	2017-06-20 11:40:55	ok	193.48.126.37
1776	cpignol	zaalpes-Container-write	2017-06-20 11:40:55	5	193.48.126.37
1777	cpignol	zaalpes-containerDisplay	2017-06-20 11:40:55	ok	193.48.126.37
1778	cpignol	zaalpes-containerList	2017-06-20 11:41:23	ok	193.48.126.37
1779	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:41:25	ok	193.48.126.37
1780	cpignol	zaalpes-containerDisplay	2017-06-20 11:41:26	ok	193.48.126.37
1781	cpignol	zaalpes-containerChange	2017-06-20 11:41:29	ok	193.48.126.37
1782	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:41:31	ok	193.48.126.37
1783	cpignol	zaalpes-containerWrite	2017-06-20 11:42:31	ok	193.48.126.37
1784	cpignol	zaalpes-Container-write	2017-06-20 11:42:31	3	193.48.126.37
1785	cpignol	zaalpes-containerDisplay	2017-06-20 11:42:31	ok	193.48.126.37
1786	cpignol	zaalpes-containerList	2017-06-20 11:42:34	ok	193.48.126.37
1787	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:42:36	ok	193.48.126.37
1788	cpignol	zaalpes-containerDisplay	2017-06-20 11:42:45	ok	193.48.126.37
1789	cpignol	zaalpes-containerChange	2017-06-20 11:42:49	ok	193.48.126.37
1790	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:42:51	ok	193.48.126.37
1791	cpignol	zaalpes-containerWrite	2017-06-20 11:43:14	ok	193.48.126.37
1792	cpignol	zaalpes-Container-write	2017-06-20 11:43:14	4	193.48.126.37
1793	cpignol	zaalpes-containerDisplay	2017-06-20 11:43:14	ok	193.48.126.37
1794	cpignol	zaalpes-containerList	2017-06-20 11:43:17	ok	193.48.126.37
1795	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:43:18	ok	193.48.126.37
1796	cpignol	zaalpes-containerDisplay	2017-06-20 11:43:20	ok	193.48.126.37
1797	cpignol	zaalpes-containerChange	2017-06-20 11:43:22	ok	193.48.126.37
1798	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:43:25	ok	193.48.126.37
1799	cpignol	zaalpes-containerWrite	2017-06-20 11:43:42	ok	193.48.126.37
1800	cpignol	zaalpes-Container-write	2017-06-20 11:43:42	6	193.48.126.37
1801	cpignol	zaalpes-containerDisplay	2017-06-20 11:43:42	ok	193.48.126.37
1802	cpignol	zaalpes-containerList	2017-06-20 11:43:46	ok	193.48.126.37
1803	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:43:47	ok	193.48.126.37
1804	cpignol	zaalpes-containerDisplay	2017-06-20 11:43:49	ok	193.48.126.37
1805	cpignol	zaalpes-containerChange	2017-06-20 11:43:54	ok	193.48.126.37
1806	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:43:56	ok	193.48.126.37
1807	cpignol	zaalpes-containerWrite	2017-06-20 11:44:21	ok	193.48.126.37
1808	cpignol	zaalpes-Container-write	2017-06-20 11:44:21	7	193.48.126.37
1809	cpignol	zaalpes-containerDisplay	2017-06-20 11:44:21	ok	193.48.126.37
1810	cpignol	zaalpes-containerList	2017-06-20 11:44:24	ok	193.48.126.37
1811	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:44:26	ok	193.48.126.37
1812	cpignol	zaalpes-objets	2017-06-20 11:45:18	ok	193.48.126.37
1813	cpignol	zaalpes-containerList	2017-06-20 11:45:22	ok	193.48.126.37
1814	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 11:45:23	ok	193.48.126.37
1815	cpignol	zaalpes-objets	2017-06-20 11:45:32	ok	193.48.126.37
1816	cpignol	zaalpes-sampleList	2017-06-20 11:45:40	ok	193.48.126.37
1817	cpignol	zaalpes-sampleList	2017-06-20 11:45:54	ok	193.48.126.37
1818	unknown	zaalpes-labelList	2017-06-20 13:06:40	nologin	10.4.2.103
1819	admin	zaalpes-connexion	2017-06-20 13:06:43	db-ok	10.4.2.103
1820	admin	zaalpes-labelList	2017-06-20 13:06:43	droitko	10.4.2.103
1821	admin	zaalpes-droitko	2017-06-20 13:06:43	ok	10.4.2.103
1822	admin	zaalpes-disconnect	2017-06-20 13:06:53	ok	10.4.2.103
1823	unknown	zaalpes-connexion	2017-06-20 13:06:57	ok	10.4.2.103
1824	cpignol	zaalpes-connexion	2017-06-20 13:07:18	db-ok	10.4.2.103
1825	cpignol	zaalpes-default	2017-06-20 13:07:18	ok	10.4.2.103
1826	cpignol	zaalpes-appliList	2017-06-20 13:07:27	ok	10.4.2.103
1827	cpignol	zaalpes-appliDisplay	2017-06-20 13:07:31	ok	10.4.2.103
1828	cpignol	zaalpes-acoChange	2017-06-20 13:07:35	ok	10.4.2.103
1829	cpignol	zaalpes-acoWrite	2017-06-20 13:07:43	ok	10.4.2.103
1830	cpignol	zaalpes-Aclaco-write	2017-06-20 13:07:43	11	10.4.2.103
1831	cpignol	zaalpes-appliDisplay	2017-06-20 13:07:43	ok	10.4.2.103
1832	cpignol	zaalpes-labelList	2017-06-20 13:07:57	ok	10.4.2.103
1833	cpignol	zaalpes-labelChange	2017-06-20 13:08:05	ok	10.4.2.103
1834	cpignol	zaalpes-labelWrite	2017-06-20 13:12:47	ok	10.4.2.103
1835	cpignol	zaalpes-Label-write	2017-06-20 13:12:47	6	10.4.2.103
1836	cpignol	zaalpes-labelList	2017-06-20 13:12:47	ok	10.4.2.103
1837	cpignol	zaalpes-sampleList	2017-06-20 13:12:58	ok	10.4.2.103
1838	cpignol	zaalpes-sampleList	2017-06-20 13:13:01	ok	10.4.2.103
1839	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:13:19	ok	10.4.2.103
1840	cpignol	zaalpes-labelList	2017-06-20 13:13:41	ok	10.4.2.103
1841	cpignol	zaalpes-labelChange	2017-06-20 13:13:45	ok	10.4.2.103
1842	cpignol	zaalpes-labelWrite	2017-06-20 13:14:33	ok	10.4.2.103
1843	cpignol	zaalpes-Label-write	2017-06-20 13:14:33	6	10.4.2.103
1844	cpignol	zaalpes-labelList	2017-06-20 13:14:33	ok	10.4.2.103
1845	cpignol	zaalpes-sampleList	2017-06-20 13:14:40	ok	10.4.2.103
1846	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:14:52	ok	10.4.2.103
1847	cpignol	zaalpes-labelChange	2017-06-20 13:16:36	ok	10.4.2.103
1848	cpignol	zaalpes-labelWrite	2017-06-20 13:18:49	ok	10.4.2.103
1849	cpignol	zaalpes-Label-write	2017-06-20 13:18:49	6	10.4.2.103
1850	cpignol	zaalpes-labelList	2017-06-20 13:18:49	ok	10.4.2.103
1851	cpignol	zaalpes-sampleList	2017-06-20 13:18:55	ok	10.4.2.103
1852	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:19:07	ok	10.4.2.103
1853	cpignol	zaalpes-labelChange	2017-06-20 13:21:37	ok	10.4.2.103
1854	cpignol	zaalpes-labelWrite	2017-06-20 13:23:33	ok	10.4.2.103
1855	cpignol	zaalpes-Label-write	2017-06-20 13:23:33	6	10.4.2.103
1856	cpignol	zaalpes-labelList	2017-06-20 13:23:33	ok	10.4.2.103
1857	cpignol	zaalpes-sampleList	2017-06-20 13:23:41	ok	10.4.2.103
1858	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:23:51	ok	10.4.2.103
1859	cpignol	zaalpes-labelChange	2017-06-20 13:24:08	ok	10.4.2.103
1860	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:24:54	ok	10.4.2.103
1861	cpignol	zaalpes-labelWrite	2017-06-20 13:25:30	ok	10.4.2.103
1862	cpignol	zaalpes-Label-write	2017-06-20 13:25:30	6	10.4.2.103
1863	cpignol	zaalpes-labelList	2017-06-20 13:25:30	ok	10.4.2.103
1864	cpignol	zaalpes-sampleList	2017-06-20 13:25:43	ok	10.4.2.103
1865	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:25:49	ok	10.4.2.103
1866	cpignol	zaalpes-labelChange	2017-06-20 13:26:10	ok	10.4.2.103
1867	cpignol	zaalpes-labelWrite	2017-06-20 13:26:29	ok	10.4.2.103
1868	cpignol	zaalpes-Label-write	2017-06-20 13:26:29	6	10.4.2.103
1869	cpignol	zaalpes-labelList	2017-06-20 13:26:29	ok	10.4.2.103
1870	cpignol	zaalpes-sampleList	2017-06-20 13:26:35	ok	10.4.2.103
1871	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:26:40	ok	10.4.2.103
1872	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:26:52	ok	10.4.2.103
1873	cpignol	zaalpes-labelChange	2017-06-20 13:27:41	ok	10.4.2.103
1874	cpignol	zaalpes-labelWrite	2017-06-20 13:28:02	ok	10.4.2.103
1875	cpignol	zaalpes-Label-write	2017-06-20 13:28:02	6	10.4.2.103
1876	cpignol	zaalpes-labelList	2017-06-20 13:28:02	ok	10.4.2.103
1877	cpignol	zaalpes-sampleList	2017-06-20 13:28:10	ok	10.4.2.103
1878	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:28:16	ok	10.4.2.103
1879	cpignol	zaalpes-samplePrintLabel	2017-06-20 13:28:21	ok	10.4.2.103
1880	unknown	zaalpes-sampleDisplay	2017-06-20 14:17:12	nologin	10.4.2.103
1881	admin	zaalpes-connexion	2017-06-20 14:17:15	db-ok	10.4.2.103
1882	admin	zaalpes-sampleDisplay	2017-06-20 14:17:15	droitko	10.4.2.103
1883	admin	zaalpes-droitko	2017-06-20 14:17:15	ok	10.4.2.103
1884	admin	zaalpes-disconnect	2017-06-20 14:17:19	ok	10.4.2.103
1885	unknown	zaalpes-connexion	2017-06-20 14:17:24	ok	10.4.2.103
1886	cpignol	zaalpes-connexion	2017-06-20 14:17:41	db-ok	10.4.2.103
1887	cpignol	zaalpes-default	2017-06-20 14:17:41	ok	10.4.2.103
1888	cpignol	zaalpes-containerList	2017-06-20 14:17:46	ok	10.4.2.103
1889	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 14:17:48	ok	10.4.2.103
1890	cpignol	zaalpes-containerList	2017-06-20 14:17:49	ok	10.4.2.103
1891	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 14:17:51	ok	10.4.2.103
1892	cpignol	zaalpes-sampleList	2017-06-20 14:18:18	ok	10.4.2.103
1893	cpignol	zaalpes-sampleList	2017-06-20 14:18:22	ok	10.4.2.103
1894	cpignol	zaalpes-sampleDisplay-connexion	2017-06-20 14:19:04	token-ok	193.48.126.37
1895	cpignol	zaalpes-sampleDisplay	2017-06-20 14:19:04	ok	193.48.126.37
1896	cpignol	zaalpes-sampleDisplay	2017-06-20 14:20:30	ok	10.4.2.103
1897	cpignol	zaalpes-containerDisplay	2017-06-20 14:21:58	ok	10.4.2.103
1898	cpignol	zaalpes-containerList	2017-06-20 14:22:09	ok	10.4.2.103
1899	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 14:22:10	ok	10.4.2.103
1900	cpignol	zaalpes-sampleList	2017-06-20 14:22:15	ok	10.4.2.103
1901	cpignol	zaalpes-containerList	2017-06-20 14:23:51	ok	10.4.2.103
1902	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 14:23:52	ok	10.4.2.103
1903	cpignol	zaalpes-containerDisplay	2017-06-20 14:23:56	ok	10.4.2.103
1904	cpignol	zaalpes-sampleList	2017-06-20 14:24:23	ok	10.4.2.103
1905	cpignol	zaalpes-sampleChange	2017-06-20 14:24:38	ok	10.4.2.103
1906	cpignol	zaalpes-metadataFormGetDetail	2017-06-20 14:25:58	ok	10.4.2.103
1907	cpignol	zaalpes-containerDisplay	2017-06-20 14:26:31	ok	193.48.126.37
1908	cpignol	zaalpes-sampleDisplay	2017-06-20 14:26:36	ok	193.48.126.37
1909	cpignol	zaalpes-containerDisplay	2017-06-20 14:26:40	ok	193.48.126.37
1910	cpignol	zaalpes-sampleList	2017-06-20 14:26:42	ok	10.4.2.103
1911	cpignol	zaalpes-sampleDisplay	2017-06-20 14:26:49	ok	193.48.126.37
1912	cpignol	zaalpes-samplePrintLabel	2017-06-20 14:27:05	ok	10.4.2.103
1913	cpignol	zaalpes-labelChange	2017-06-20 14:30:19	ok	10.4.2.103
1914	cpignol	zaalpes-storagesampleOutput	2017-06-20 14:30:24	ok	193.48.126.37
1915	cpignol	zaalpes-sampleDisplay	2017-06-20 14:31:10	ok	193.48.126.37
1916	cpignol	zaalpes-labelWrite	2017-06-20 14:31:12	ok	10.4.2.103
1917	cpignol	zaalpes-Label-write	2017-06-20 14:31:12	6	10.4.2.103
1918	cpignol	zaalpes-labelList	2017-06-20 14:31:12	ok	10.4.2.103
1919	cpignol	zaalpes-storagesampleInput	2017-06-20 14:31:16	ok	193.48.126.37
1920	cpignol	zaalpes-containerGetFromUid	2017-06-20 14:31:20	ok	193.48.126.37
1921	cpignol	zaalpes-labelChange	2017-06-20 14:31:20	ok	10.4.2.103
1922	cpignol	zaalpes-containerGetFromUid	2017-06-20 14:31:21	ok	193.48.126.37
1923	cpignol	zaalpes-containerGetFromUid	2017-06-20 14:31:22	ok	193.48.126.37
1924	cpignol	zaalpes-containerGetFromUid	2017-06-20 14:31:22	ok	193.48.126.37
1925	cpignol	zaalpes-containerGetFromUid	2017-06-20 14:31:23	ok	193.48.126.37
1926	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 14:31:29	ok	193.48.126.37
1927	cpignol	zaalpes-containerGetFromType	2017-06-20 14:31:30	ok	193.48.126.37
1928	cpignol	zaalpes-containerGetFromType	2017-06-20 14:31:40	ok	193.48.126.37
1929	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-20 14:31:45	ok	193.48.126.37
1930	cpignol	zaalpes-containerGetFromType	2017-06-20 14:31:49	ok	193.48.126.37
1931	cpignol	zaalpes-containerGetFromType	2017-06-20 14:32:01	ok	193.48.126.37
1932	cpignol	zaalpes-containerGetFromType	2017-06-20 14:32:04	ok	193.48.126.37
1933	cpignol	zaalpes-containerGetFromType	2017-06-20 14:32:08	ok	193.48.126.37
1934	cpignol	zaalpes-sampleDisplay	2017-06-20 14:32:43	ok	193.48.126.37
1935	cpignol	zaalpes-subsampleChange	2017-06-20 14:34:16	ok	193.48.126.37
1936	cpignol	zaalpes-sampleDisplay	2017-06-20 14:34:36	ok	193.48.126.37
1937	cpignol	zaalpes-labelWrite	2017-06-20 14:36:55	ok	10.4.2.103
1938	cpignol	zaalpes-Label-write	2017-06-20 14:36:55	7	10.4.2.103
1939	cpignol	zaalpes-labelList	2017-06-20 14:36:55	ok	10.4.2.103
1940	cpignol	zaalpes-sampleList	2017-06-20 14:37:06	ok	10.4.2.103
1941	cpignol	zaalpes-sampleDisplay	2017-06-20 14:37:16	ok	10.4.2.103
1942	cpignol	zaalpes-sampleList	2017-06-20 14:37:20	ok	10.4.2.103
1943	cpignol	zaalpes-samplePrintLabel	2017-06-20 14:37:37	ok	10.4.2.103
1944	cpignol	zaalpes-labelChange	2017-06-20 14:38:26	ok	10.4.2.103
1945	cpignol	zaalpes-labelWrite	2017-06-20 14:38:52	ok	10.4.2.103
1946	cpignol	zaalpes-Label-write	2017-06-20 14:38:52	7	10.4.2.103
1947	cpignol	zaalpes-labelList	2017-06-20 14:38:52	ok	10.4.2.103
1948	cpignol	zaalpes-sampleList	2017-06-20 14:39:00	ok	10.4.2.103
1949	cpignol	zaalpes-samplePrintLabel	2017-06-20 14:39:09	ok	10.4.2.103
1950	cpignol	zaalpes-labelChange	2017-06-20 14:41:35	ok	10.4.2.103
1951	cpignol	zaalpes-labelWrite	2017-06-20 14:42:09	ok	10.4.2.103
1952	cpignol	zaalpes-Label-write	2017-06-20 14:42:09	7	10.4.2.103
1953	cpignol	zaalpes-labelList	2017-06-20 14:42:09	ok	10.4.2.103
1954	cpignol	zaalpes-sampleList	2017-06-20 14:42:20	ok	10.4.2.103
1955	cpignol	zaalpes-samplePrintLabel	2017-06-20 14:42:32	ok	10.4.2.103
1956	cpignol	zaalpes-labelChange	2017-06-20 14:44:15	ok	10.4.2.103
1957	cpignol	zaalpes-labelWrite	2017-06-20 14:49:50	ok	10.4.2.103
1958	cpignol	zaalpes-Label-write	2017-06-20 14:49:50	7	10.4.2.103
1959	cpignol	zaalpes-labelList	2017-06-20 14:49:50	ok	10.4.2.103
1960	cpignol	zaalpes-sampleList	2017-06-20 14:49:58	ok	10.4.2.103
1961	cpignol	zaalpes-samplePrintLabel	2017-06-20 14:50:04	ok	10.4.2.103
1962	cpignol	zaalpes-labelChange	2017-06-20 14:50:44	ok	10.4.2.103
1963	cpignol	zaalpes-labelWrite	2017-06-20 14:51:09	ok	10.4.2.103
1964	cpignol	zaalpes-Label-write	2017-06-20 14:51:09	7	10.4.2.103
1965	cpignol	zaalpes-labelList	2017-06-20 14:51:09	ok	10.4.2.103
1966	cpignol	zaalpes-labelChange	2017-06-20 14:51:16	ok	10.4.2.103
1967	cpignol	zaalpes-labelWrite	2017-06-20 14:52:00	ok	10.4.2.103
1968	cpignol	zaalpes-Label-write	2017-06-20 14:52:00	7	10.4.2.103
1969	cpignol	zaalpes-labelList	2017-06-20 14:52:00	ok	10.4.2.103
1970	cpignol	zaalpes-sampleList	2017-06-20 14:52:07	ok	10.4.2.103
1971	cpignol	zaalpes-samplePrintLabel	2017-06-20 14:52:13	ok	10.4.2.103
1972	cpignol	zaalpes-labelChange	2017-06-20 14:52:34	ok	10.4.2.103
1973	cpignol	zaalpes-labelWrite	2017-06-20 14:56:58	ok	10.4.2.103
1974	cpignol	zaalpes-Label-write	2017-06-20 14:56:58	7	10.4.2.103
1975	cpignol	zaalpes-labelList	2017-06-20 14:56:58	ok	10.4.2.103
1976	cpignol	zaalpes-sampleList	2017-06-20 14:57:09	ok	10.4.2.103
1977	cpignol	zaalpes-samplePrintLabel	2017-06-20 14:57:16	ok	10.4.2.103
1978	cpignol	zaalpes-labelChange	2017-06-20 14:57:39	ok	10.4.2.103
1979	cpignol	zaalpes-labelWrite	2017-06-20 14:58:39	ok	10.4.2.103
1980	cpignol	zaalpes-Label-write	2017-06-20 14:58:39	7	10.4.2.103
1981	cpignol	zaalpes-labelList	2017-06-20 14:58:39	ok	10.4.2.103
1982	cpignol	zaalpes-sampleList	2017-06-20 14:58:46	ok	10.4.2.103
1983	cpignol	zaalpes-samplePrintLabel	2017-06-20 14:58:57	ok	10.4.2.103
1984	cpignol	zaalpes-labelChange	2017-06-20 14:59:27	ok	10.4.2.103
1985	cpignol	zaalpes-labelWrite	2017-06-20 15:02:57	ok	10.4.2.103
1986	cpignol	zaalpes-Label-write	2017-06-20 15:02:57	7	10.4.2.103
1987	cpignol	zaalpes-labelList	2017-06-20 15:02:57	ok	10.4.2.103
1988	cpignol	zaalpes-sampleList	2017-06-20 15:03:05	ok	10.4.2.103
1989	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:03:13	ok	10.4.2.103
1990	cpignol	zaalpes-sampleList	2017-06-20 15:04:01	ok	10.4.2.103
1991	cpignol	zaalpes-sampleList	2017-06-20 15:04:08	ok	10.4.2.103
1992	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:04:22	ok	10.4.2.103
1993	cpignol	zaalpes-labelChange	2017-06-20 15:04:34	ok	10.4.2.103
1994	cpignol	zaalpes-labelWrite	2017-06-20 15:05:08	ok	10.4.2.103
1995	cpignol	zaalpes-Label-write	2017-06-20 15:05:08	7	10.4.2.103
1996	cpignol	zaalpes-labelList	2017-06-20 15:05:08	ok	10.4.2.103
1997	cpignol	zaalpes-sampleList	2017-06-20 15:05:16	ok	10.4.2.103
1998	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:05:22	ok	10.4.2.103
1999	cpignol	zaalpes-labelChange	2017-06-20 15:07:15	ok	10.4.2.103
2000	cpignol	zaalpes-labelWrite	2017-06-20 15:07:59	ok	10.4.2.103
2001	cpignol	zaalpes-Label-write	2017-06-20 15:07:59	7	10.4.2.103
2002	cpignol	zaalpes-labelList	2017-06-20 15:07:59	ok	10.4.2.103
2003	cpignol	zaalpes-sampleList	2017-06-20 15:08:09	ok	10.4.2.103
2004	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:08:17	ok	10.4.2.103
2005	cpignol	zaalpes-labelChange	2017-06-20 15:09:01	ok	10.4.2.103
2006	cpignol	zaalpes-labelWrite	2017-06-20 15:10:04	ok	10.4.2.103
2007	cpignol	zaalpes-Label-write	2017-06-20 15:10:04	7	10.4.2.103
2008	cpignol	zaalpes-labelList	2017-06-20 15:10:04	ok	10.4.2.103
2009	cpignol	zaalpes-sampleList	2017-06-20 15:10:10	ok	10.4.2.103
2010	cpignol	zaalpes-sampleList	2017-06-20 15:10:22	ok	10.4.2.103
2011	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:10:27	ok	10.4.2.103
2012	cpignol	zaalpes-labelChange	2017-06-20 15:11:44	ok	10.4.2.103
2013	cpignol	zaalpes-labelWrite	2017-06-20 15:12:43	ok	10.4.2.103
2014	cpignol	zaalpes-Label-write	2017-06-20 15:12:43	7	10.4.2.103
2015	cpignol	zaalpes-labelList	2017-06-20 15:12:43	ok	10.4.2.103
2016	cpignol	zaalpes-sampleList	2017-06-20 15:12:52	ok	10.4.2.103
2017	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:12:57	ok	10.4.2.103
2018	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:13:03	ok	10.4.2.103
2019	cpignol	zaalpes-labelChange	2017-06-20 15:14:32	ok	10.4.2.103
2020	cpignol	zaalpes-labelWrite	2017-06-20 15:16:11	ok	10.4.2.103
2021	cpignol	zaalpes-Label-write	2017-06-20 15:16:11	7	10.4.2.103
2022	cpignol	zaalpes-labelList	2017-06-20 15:16:11	ok	10.4.2.103
2023	cpignol	zaalpes-sampleList	2017-06-20 15:16:18	ok	10.4.2.103
2024	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:16:23	ok	10.4.2.103
2025	cpignol	zaalpes-labelChange	2017-06-20 15:17:05	ok	10.4.2.103
2026	cpignol	zaalpes-labelWrite	2017-06-20 15:17:34	ok	10.4.2.103
2027	cpignol	zaalpes-Label-write	2017-06-20 15:17:34	7	10.4.2.103
2028	cpignol	zaalpes-labelList	2017-06-20 15:17:34	ok	10.4.2.103
2029	cpignol	zaalpes-sampleList	2017-06-20 15:17:42	ok	10.4.2.103
2030	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:17:47	ok	10.4.2.103
2031	cpignol	zaalpes-sampleDisplay	2017-06-20 15:18:10	ok	10.4.2.103
2032	cpignol	zaalpes-sampleChange	2017-06-20 15:18:25	ok	10.4.2.103
2033	cpignol	zaalpes-sampleWrite	2017-06-20 15:18:41	ok	10.4.2.103
2034	cpignol	zaalpes-Sample-write	2017-06-20 15:18:41	92	10.4.2.103
2035	cpignol	zaalpes-sampleDisplay	2017-06-20 15:18:41	ok	10.4.2.103
2036	cpignol	zaalpes-sampleList	2017-06-20 15:18:46	ok	10.4.2.103
2037	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:18:57	ok	10.4.2.103
2038	cpignol	zaalpes-labelChange	2017-06-20 15:19:20	ok	10.4.2.103
2039	cpignol	zaalpes-labelWrite	2017-06-20 15:19:34	ok	10.4.2.103
2040	cpignol	zaalpes-Label-write	2017-06-20 15:19:34	7	10.4.2.103
2041	cpignol	zaalpes-labelList	2017-06-20 15:19:34	ok	10.4.2.103
2042	cpignol	zaalpes-sampleList	2017-06-20 15:19:44	ok	10.4.2.103
2043	cpignol	zaalpes-sampleList	2017-06-20 15:19:52	ok	10.4.2.103
2044	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:19:58	ok	10.4.2.103
2045	cpignol	zaalpes-labelChange	2017-06-20 15:20:30	ok	10.4.2.103
2046	cpignol	zaalpes-labelWrite	2017-06-20 15:24:10	ok	10.4.2.103
2047	cpignol	zaalpes-Label-write	2017-06-20 15:24:10	7	10.4.2.103
2048	cpignol	zaalpes-labelList	2017-06-20 15:24:10	ok	10.4.2.103
2049	cpignol	zaalpes-sampleList	2017-06-20 15:24:18	ok	10.4.2.103
2050	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:24:23	ok	10.4.2.103
2051	cpignol	zaalpes-labelChange	2017-06-20 15:25:35	ok	10.4.2.103
2052	cpignol	zaalpes-labelWrite	2017-06-20 15:25:53	ok	10.4.2.103
2053	cpignol	zaalpes-Label-write	2017-06-20 15:25:54	7	10.4.2.103
2054	cpignol	zaalpes-labelList	2017-06-20 15:25:54	ok	10.4.2.103
2055	cpignol	zaalpes-sampleList	2017-06-20 15:26:05	ok	10.4.2.103
2056	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:26:10	ok	10.4.2.103
2057	cpignol	zaalpes-labelChange	2017-06-20 15:26:35	ok	10.4.2.103
2058	cpignol	zaalpes-labelWrite	2017-06-20 15:28:13	ok	10.4.2.103
2059	cpignol	zaalpes-Label-write	2017-06-20 15:28:13	7	10.4.2.103
2060	cpignol	zaalpes-labelList	2017-06-20 15:28:13	ok	10.4.2.103
2061	cpignol	zaalpes-sampleList	2017-06-20 15:28:19	ok	10.4.2.103
2062	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:28:25	ok	10.4.2.103
2063	cpignol	zaalpes-labelChange	2017-06-20 15:29:03	ok	10.4.2.103
2064	cpignol	zaalpes-labelWrite	2017-06-20 15:31:02	ok	10.4.2.103
2065	cpignol	zaalpes-Label-write	2017-06-20 15:31:02	7	10.4.2.103
2066	cpignol	zaalpes-labelList	2017-06-20 15:31:02	ok	10.4.2.103
2067	cpignol	zaalpes-sampleList	2017-06-20 15:31:10	ok	10.4.2.103
2068	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:31:16	ok	10.4.2.103
2069	cpignol	zaalpes-labelChange	2017-06-20 15:31:36	ok	10.4.2.103
2070	cpignol	zaalpes-labelWrite	2017-06-20 15:32:54	ok	10.4.2.103
2071	cpignol	zaalpes-Label-write	2017-06-20 15:32:54	7	10.4.2.103
2072	cpignol	zaalpes-labelList	2017-06-20 15:32:54	ok	10.4.2.103
2073	cpignol	zaalpes-sampleList	2017-06-20 15:33:01	ok	10.4.2.103
2074	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:33:06	ok	10.4.2.103
2075	cpignol	zaalpes-labelChange	2017-06-20 15:34:04	ok	10.4.2.103
2076	cpignol	zaalpes-labelWrite	2017-06-20 15:35:36	ok	10.4.2.103
2077	cpignol	zaalpes-Label-write	2017-06-20 15:35:36	7	10.4.2.103
2078	cpignol	zaalpes-labelList	2017-06-20 15:35:36	ok	10.4.2.103
2079	cpignol	zaalpes-sampleList	2017-06-20 15:35:43	ok	10.4.2.103
2080	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:35:50	ok	10.4.2.103
2081	cpignol	zaalpes-labelChange	2017-06-20 15:36:19	ok	10.4.2.103
2082	cpignol	zaalpes-labelWrite	2017-06-20 15:39:48	ok	10.4.2.103
2083	cpignol	zaalpes-Label-write	2017-06-20 15:39:48	7	10.4.2.103
2084	cpignol	zaalpes-labelList	2017-06-20 15:39:48	ok	10.4.2.103
2085	cpignol	zaalpes-sampleList	2017-06-20 15:39:56	ok	10.4.2.103
2086	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:40:13	ok	10.4.2.103
2087	cpignol	zaalpes-labelChange	2017-06-20 15:40:57	ok	10.4.2.103
2088	cpignol	zaalpes-labelWrite	2017-06-20 15:42:34	ok	10.4.2.103
2089	cpignol	zaalpes-Label-write	2017-06-20 15:42:34	7	10.4.2.103
2090	cpignol	zaalpes-labelList	2017-06-20 15:42:34	ok	10.4.2.103
2091	cpignol	zaalpes-sampleList	2017-06-20 15:42:51	ok	10.4.2.103
2092	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:43:00	ok	10.4.2.103
2093	cpignol	zaalpes-labelChange	2017-06-20 15:44:34	ok	10.4.2.103
2094	cpignol	zaalpes-labelWrite	2017-06-20 15:45:19	ok	10.4.2.103
2095	cpignol	zaalpes-Label-write	2017-06-20 15:45:19	7	10.4.2.103
2096	cpignol	zaalpes-labelList	2017-06-20 15:45:19	ok	10.4.2.103
2097	cpignol	zaalpes-sampleList	2017-06-20 15:45:25	ok	10.4.2.103
2098	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:45:45	ok	10.4.2.103
2099	cpignol	zaalpes-labelChange	2017-06-20 15:46:13	ok	10.4.2.103
2100	cpignol	zaalpes-labelWrite	2017-06-20 15:47:08	ok	10.4.2.103
2101	cpignol	zaalpes-Label-write	2017-06-20 15:47:08	7	10.4.2.103
2102	cpignol	zaalpes-labelList	2017-06-20 15:47:08	ok	10.4.2.103
2103	cpignol	zaalpes-sampleList	2017-06-20 15:47:14	ok	10.4.2.103
2104	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:47:19	ok	10.4.2.103
2105	cpignol	zaalpes-labelChange	2017-06-20 15:47:34	ok	10.4.2.103
2106	cpignol	zaalpes-labelWrite	2017-06-20 15:48:24	ok	10.4.2.103
2107	cpignol	zaalpes-Label-write	2017-06-20 15:48:24	7	10.4.2.103
2108	cpignol	zaalpes-labelList	2017-06-20 15:48:24	ok	10.4.2.103
2109	cpignol	zaalpes-sampleList	2017-06-20 15:48:33	ok	10.4.2.103
2110	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:48:36	ok	10.4.2.103
2111	cpignol	zaalpes-labelChange	2017-06-20 15:49:00	ok	10.4.2.103
2112	cpignol	zaalpes-labelWrite	2017-06-20 15:50:55	ok	10.4.2.103
2113	cpignol	zaalpes-Label-write	2017-06-20 15:50:55	7	10.4.2.103
2114	cpignol	zaalpes-labelList	2017-06-20 15:50:55	ok	10.4.2.103
2115	cpignol	zaalpes-sampleList	2017-06-20 15:51:02	ok	10.4.2.103
2116	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:51:08	ok	10.4.2.103
2117	cpignol	zaalpes-labelChange	2017-06-20 15:51:49	ok	10.4.2.103
2118	cpignol	zaalpes-labelWrite	2017-06-20 15:52:21	ok	10.4.2.103
2119	cpignol	zaalpes-Label-write	2017-06-20 15:52:21	7	10.4.2.103
2120	cpignol	zaalpes-labelList	2017-06-20 15:52:21	ok	10.4.2.103
2121	cpignol	zaalpes-sampleList	2017-06-20 15:52:27	ok	10.4.2.103
2122	cpignol	zaalpes-samplePrintLabel	2017-06-20 15:52:32	ok	10.4.2.103
2123	cpignol	zaalpes-labelList	2017-06-20 16:06:22	ok	10.4.2.103
2124	cpignol	zaalpes-labelChange	2017-06-20 16:06:25	ok	10.4.2.103
2125	cpignol	zaalpes-labelWrite	2017-06-20 16:06:32	ok	10.4.2.103
2126	cpignol	zaalpes-Label-write	2017-06-20 16:06:32	7	10.4.2.103
2127	cpignol	zaalpes-labelList	2017-06-20 16:06:32	ok	10.4.2.103
2128	unknown	zaalpes-loginList	2017-06-21 17:34:26	nologin	10.4.2.103
2129	admin	zaalpes-connexion	2017-06-21 17:34:31	db-ok	10.4.2.103
2130	admin	zaalpes-loginList	2017-06-21 17:34:31	ok	10.4.2.103
2131	admin	zaalpes-loginList	2017-06-21 17:34:54	ok	10.4.2.103
2132	admin	zaalpes-disconnect	2017-06-21 17:34:58	ok	10.4.2.103
2133	unknown	zaalpes-connexion	2017-06-21 17:35:02	ok	10.4.2.103
2134	cpignol	zaalpes-connexion	2017-06-21 17:35:16	db-ok	10.4.2.103
2135	cpignol	zaalpes-default	2017-06-21 17:35:16	ok	10.4.2.103
2136	cpignol	zaalpes-administration	2017-06-21 17:35:23	ok	10.4.2.103
2137	cpignol	zaalpes-loginList	2017-06-21 17:35:27	ok	10.4.2.103
2138	cpignol	zaalpes-loginChange	2017-06-21 17:35:35	ok	10.4.2.103
2139	cpignol	zaalpes-loginWrite	2017-06-21 17:36:48	ok	10.4.2.103
2140	cpignol	zaalpes-LoginGestion-write	2017-06-21 17:36:48	7	10.4.2.103
2141	cpignol	zaalpes-loginList	2017-06-21 17:36:48	ok	10.4.2.103
2142	cpignol	zaalpes-appliList	2017-06-21 17:37:03	ok	10.4.2.103
2143	cpignol	zaalpes-appliDisplay	2017-06-21 17:37:07	ok	10.4.2.103
2144	cpignol	zaalpes-acoChange	2017-06-21 17:37:13	ok	10.4.2.103
2145	cpignol	zaalpes-appliDisplay	2017-06-21 17:37:19	ok	10.4.2.103
2146	cpignol	zaalpes-acoChange	2017-06-21 17:37:23	ok	10.4.2.103
2147	cpignol	zaalpes-groupList	2017-06-21 17:37:40	ok	10.4.2.103
2148	cpignol	zaalpes-aclloginList	2017-06-21 17:38:17	ok	10.4.2.103
2149	cpignol	zaalpes-aclloginChange	2017-06-21 17:38:31	ok	10.4.2.103
2150	cpignol	zaalpes-loginList	2017-06-21 17:38:41	ok	10.4.2.103
2151	cpignol	zaalpes-loginChange	2017-06-21 17:38:51	ok	10.4.2.103
2152	cpignol	zaalpes-groupList	2017-06-21 17:39:01	ok	10.4.2.103
2153	cpignol	zaalpes-groupChange	2017-06-21 17:39:05	ok	10.4.2.103
2154	cpignol	zaalpes-groupWrite	2017-06-21 17:39:21	ok	10.4.2.103
2155	cpignol	zaalpes-Aclgroup-write	2017-06-21 17:39:21	22	10.4.2.103
2156	cpignol	zaalpes-groupList	2017-06-21 17:39:21	ok	10.4.2.103
2157	cpignol	zaalpes-appliList	2017-06-21 17:39:32	ok	10.4.2.103
2158	cpignol	zaalpes-appliDisplay	2017-06-21 17:39:37	ok	10.4.2.103
2159	cpignol	zaalpes-acoChange	2017-06-21 17:39:45	ok	10.4.2.103
2160	cpignol	zaalpes-appliList	2017-06-21 17:40:19	ok	10.4.2.103
2161	cpignol	zaalpes-appliDisplay	2017-06-21 17:40:22	ok	10.4.2.103
2162	cpignol	zaalpes-acoChange	2017-06-21 17:40:37	ok	10.4.2.103
2163	cpignol	zaalpes-acoWrite	2017-06-21 17:40:57	ok	10.4.2.103
2164	cpignol	zaalpes-Aclaco-write	2017-06-21 17:40:57	12	10.4.2.103
2165	cpignol	zaalpes-appliDisplay	2017-06-21 17:40:57	ok	10.4.2.103
2166	cpignol	zaalpes-aclloginList	2017-06-21 17:41:18	ok	10.4.2.103
2167	cpignol	zaalpes-aclloginChange	2017-06-21 17:41:22	ok	10.4.2.103
2168	cpignol	zaalpes-appliList	2017-06-21 17:41:36	ok	10.4.2.103
2169	cpignol	zaalpes-appliDisplay	2017-06-21 17:41:40	ok	10.4.2.103
2170	cpignol	zaalpes-acoChange	2017-06-21 17:41:48	ok	10.4.2.103
2171	cpignol	zaalpes-acoWrite	2017-06-21 17:41:53	ok	10.4.2.103
2172	cpignol	zaalpes-Aclaco-write	2017-06-21 17:41:53	13	10.4.2.103
2173	cpignol	zaalpes-appliDisplay	2017-06-21 17:41:53	ok	10.4.2.103
2174	cpignol	zaalpes-acoChange	2017-06-21 17:42:03	ok	10.4.2.103
2175	cpignol	zaalpes-acoWrite	2017-06-21 17:42:08	ok	10.4.2.103
2176	cpignol	zaalpes-Aclaco-write	2017-06-21 17:42:08	14	10.4.2.103
2177	cpignol	zaalpes-appliDisplay	2017-06-21 17:42:08	ok	10.4.2.103
2178	cpignol	zaalpes-acoChange	2017-06-21 17:42:12	ok	10.4.2.103
2179	cpignol	zaalpes-acoWrite	2017-06-21 17:42:17	ok	10.4.2.103
2180	cpignol	zaalpes-Aclaco-write	2017-06-21 17:42:17	15	10.4.2.103
2181	cpignol	zaalpes-appliDisplay	2017-06-21 17:42:17	ok	10.4.2.103
2182	cpignol	zaalpes-aclloginList	2017-06-21 17:42:23	ok	10.4.2.103
2183	cpignol	zaalpes-aclloginChange	2017-06-21 17:42:27	ok	10.4.2.103
2184	cpignol	zaalpes-disconnect	2017-06-21 17:42:39	ok	10.4.2.103
2185	unknown	zaalpes-connexion	2017-06-21 17:42:43	ok	10.4.2.103
2186	test-collec	zaalpes-connexion	2017-06-21 17:42:55	db-ok	10.4.2.103
2187	test-collec	zaalpes-default	2017-06-21 17:42:55	ok	10.4.2.103
2188	test-collec	zaalpes-sampleList	2017-06-21 17:43:01	ok	10.4.2.103
2189	test-collec	zaalpes-sampleList	2017-06-21 17:43:04	ok	10.4.2.103
2190	test-collec	zaalpes-sampleDisplay	2017-06-21 17:43:14	ok	10.4.2.103
2191	test-collec	zaalpes-disconnect	2017-06-21 17:43:35	ok	10.4.2.103
2192	unknown	zaalpes-disconnect	2017-06-22 09:23:40	ok	10.4.2.103
2193	unknown	zaalpes-connexion	2017-06-22 09:23:54	ok	10.4.2.103
2194	test-collec	zaalpes-connexion	2017-06-22 09:24:12	db-ok	10.4.2.103
2195	test-collec	zaalpes-default	2017-06-22 09:24:12	ok	10.4.2.103
2196	test-collec	zaalpes-sampleList	2017-06-22 09:24:57	ok	10.4.2.103
2197	test-collec	zaalpes-sampleList	2017-06-22 09:25:01	ok	10.4.2.103
2198	test-collec	zaalpes-sampleDisplay	2017-06-22 09:25:11	ok	10.4.2.103
2199	unknown	zaalpes-default	2017-06-22 09:26:25	ok	10.4.2.103
2200	unknown	zaalpes-connexion	2017-06-22 09:26:30	ok	10.4.2.103
2201	cpignol	zaalpes-connexion	2017-06-22 09:26:51	db-ok	10.4.2.103
2202	cpignol	zaalpes-default	2017-06-22 09:26:51	ok	10.4.2.103
2203	cpignol	zaalpes-aclloginList	2017-06-22 09:26:59	ok	10.4.2.103
2204	cpignol	zaalpes-aclloginChange	2017-06-22 09:27:04	ok	10.4.2.103
2205	cpignol	zaalpes-groupList	2017-06-22 09:27:17	ok	10.4.2.103
2206	cpignol	zaalpes-groupChange	2017-06-22 09:27:22	ok	10.4.2.103
2207	cpignol	zaalpes-appliList	2017-06-22 09:27:50	ok	10.4.2.103
2208	cpignol	zaalpes-groupList	2017-06-22 09:27:56	ok	10.4.2.103
2209	cpignol	zaalpes-administration	2017-06-22 09:27:58	ok	10.4.2.103
2210	cpignol	zaalpes-aclloginList	2017-06-22 09:28:02	ok	10.4.2.103
2211	cpignol	zaalpes-aclloginChange	2017-06-22 09:28:09	ok	10.4.2.103
2212	cpignol	zaalpes-objets	2017-06-22 09:28:20	ok	10.4.2.103
2213	cpignol	zaalpes-sampleList	2017-06-22 09:28:26	ok	10.4.2.103
2214	cpignol	zaalpes-sampleList	2017-06-22 09:28:29	ok	10.4.2.103
2215	cpignol	zaalpes-sampleDisplay	2017-06-22 09:28:34	ok	10.4.2.103
2216	cpignol	zaalpes-projectList	2017-06-22 09:29:37	ok	10.4.2.103
2217	cpignol	zaalpes-projectChange	2017-06-22 09:30:31	ok	10.4.2.103
2218	cpignol	zaalpes-projectWrite	2017-06-22 09:30:37	ok	10.4.2.103
2219	cpignol	zaalpes-Project-write	2017-06-22 09:30:37	1	10.4.2.103
2220	cpignol	zaalpes-projectList	2017-06-22 09:30:37	ok	10.4.2.103
2221	cpignol	zaalpes-sampleList	2017-06-22 09:30:44	ok	10.4.2.103
2222	cpignol	zaalpes-sampleDisplay	2017-06-22 09:30:50	ok	10.4.2.103
2223	cpignol	zaalpes-projectList	2017-06-22 09:31:10	ok	10.4.2.103
2224	cpignol	zaalpes-projectChange	2017-06-22 09:31:22	ok	10.4.2.103
2225	cpignol	zaalpes-projectWrite	2017-06-22 09:31:28	ok	10.4.2.103
2226	cpignol	zaalpes-Project-write	2017-06-22 09:31:28	1	10.4.2.103
2227	cpignol	zaalpes-projectList	2017-06-22 09:31:28	ok	10.4.2.103
2228	test-collec	zaalpes-connexion	2017-06-22 09:31:36	ok	10.4.2.103
2229	test-collec	zaalpes-projectList	2017-06-22 09:31:50	ok	10.4.2.103
2230	test-collec	zaalpes-projectChange	2017-06-22 09:32:01	ok	10.4.2.103
2231	test-collec	zaalpes-projectList	2017-06-22 09:35:14	ok	10.4.2.103
2232	test-collec	zaalpes-protocolList	2017-06-22 09:35:28	ok	10.4.2.103
2233	test-collec	zaalpes-protocolChange	2017-06-22 09:35:35	ok	10.4.2.103
2234	test-collec	zaalpes-protocolList	2017-06-22 09:35:43	ok	10.4.2.103
2235	test-collec	zaalpes-protocolChange	2017-06-22 09:35:47	ok	10.4.2.103
2236	test-collec	zaalpes-protocolList	2017-06-22 09:36:02	ok	10.4.2.103
2237	test-collec	zaalpes-protocolChange	2017-06-22 09:36:57	ok	10.4.2.103
2238	test-collec	zaalpes-protocolWrite	2017-06-22 09:37:12	ok	10.4.2.103
2239	test-collec	zaalpes-Protocol-write	2017-06-22 09:37:12	1	10.4.2.103
2240	test-collec	zaalpes-protocolList	2017-06-22 09:37:12	ok	10.4.2.103
2241	test-collec	zaalpes-protocolChange	2017-06-22 09:37:19	ok	10.4.2.103
2242	test-collec	zaalpes-protocolWrite	2017-06-22 09:37:26	ok	10.4.2.103
2243	test-collec	zaalpes-Protocol-write	2017-06-22 09:37:26	1	10.4.2.103
2244	test-collec	zaalpes-protocolList	2017-06-22 09:37:26	ok	10.4.2.103
2245	test-collec	zaalpes-operationList	2017-06-22 09:37:32	ok	10.4.2.103
2246	test-collec	zaalpes-operationChange	2017-06-22 09:37:47	ok	10.4.2.103
2247	cpignol	zaalpes-appliList	2017-06-22 09:41:39	ok	10.4.2.103
2248	cpignol	zaalpes-appliDisplay	2017-06-22 09:41:43	ok	10.4.2.103
2249	cpignol	zaalpes-acoChange	2017-06-22 09:41:53	ok	10.4.2.103
2250	cpignol	zaalpes-appliList	2017-06-22 09:42:51	ok	10.4.2.103
2251	cpignol	zaalpes-appliDisplay	2017-06-22 09:43:30	ok	10.4.2.103
2252	cpignol	zaalpes-appliList	2017-06-22 09:45:40	ok	10.4.2.103
2253	cpignol	zaalpes-appliDisplay	2017-06-22 09:46:08	ok	10.4.2.103
2254	cpignol	zaalpes-appliList	2017-06-22 09:47:48	ok	10.4.2.103
2255	cpignol	zaalpes-aclloginList	2017-06-22 09:48:44	ok	10.4.2.103
2256	cpignol	zaalpes-aclloginChange	2017-06-22 09:48:53	ok	10.4.2.103
2257	cpignol	zaalpes-aclloginList	2017-06-22 09:49:04	ok	10.4.2.103
2258	cpignol	zaalpes-aclloginChange	2017-06-22 09:49:21	ok	10.4.2.103
2259	cpignol	zaalpes-appliList	2017-06-22 09:50:12	ok	10.4.2.103
2260	test-collec	zaalpes-containerList	2017-06-22 09:58:02	ok	10.4.2.103
2261	test-collec	zaalpes-containerTypeGetFromFamily	2017-06-22 09:58:05	ok	10.4.2.103
2262	test-collec	zaalpes-containerList	2017-06-22 09:58:06	ok	10.4.2.103
2263	test-collec	zaalpes-containerTypeGetFromFamily	2017-06-22 09:58:09	ok	10.4.2.103
2264	test-collec	zaalpes-containerPrintLabel	2017-06-22 09:58:24	ok	10.4.2.103
2265	cpignol	zaalpes-appliDisplay	2017-06-22 10:06:25	ok	10.4.2.103
2266	cpignol	zaalpes-aclloginList	2017-06-22 10:06:33	ok	10.4.2.103
2267	cpignol	zaalpes-groupList	2017-06-22 10:21:01	ok	10.4.2.103
2268	cpignol	zaalpes-aclloginList	2017-06-22 10:21:04	ok	10.4.2.103
2269	cpignol	zaalpes-aclloginChange	2017-06-22 10:21:07	ok	10.4.2.103
2270	cpignol	zaalpes-aclloginList	2017-06-22 10:21:14	ok	10.4.2.103
2271	cpignol	zaalpes-loginList	2017-06-22 10:21:19	ok	10.4.2.103
2272	cpignol	zaalpes-loginChange	2017-06-22 10:21:28	ok	10.4.2.103
2273	cpignol	zaalpes-appliList	2017-06-22 10:25:39	ok	10.4.2.103
2274	cpignol	zaalpes-appliDisplay	2017-06-22 10:25:44	ok	10.4.2.103
2275	cpignol	zaalpes-projectList	2017-06-22 10:34:47	ok	10.4.2.103
2276	cpignol	zaalpes-projectChange	2017-06-22 10:37:30	ok	10.4.2.103
2277	cpignol	zaalpes-aclloginList-connexion	2017-06-22 13:45:57	token-ok	10.4.2.103
2278	cpignol	zaalpes-aclloginList	2017-06-22 13:45:57	ok	10.4.2.103
2279	cpignol	zaalpes-aclloginChange	2017-06-22 13:46:03	ok	10.4.2.103
2280	cpignol	zaalpes-protocolList-connexion	2017-06-22 15:01:08	token-ok	10.4.2.103
2281	cpignol	zaalpes-protocolList	2017-06-22 15:01:08	ok	10.4.2.103
2282	cpignol	zaalpes-protocolChange	2017-06-22 15:01:14	ok	10.4.2.103
2283	cpignol	zaalpes-protocolList	2017-06-22 15:01:19	ok	10.4.2.103
2284	cpignol	zaalpes-protocolChange	2017-06-22 15:01:22	ok	10.4.2.103
2285	cpignol	zaalpes-protocolList	2017-06-22 15:01:28	ok	10.4.2.103
2286	unknown	zaalpes-fastInputChange	2017-06-23 15:05:19	nologin	10.4.2.103
2287	cpignol	zaalpes-connexion	2017-06-23 15:05:30	db-ok	10.4.2.103
2288	cpignol	zaalpes-fastInputChange	2017-06-23 15:05:30	ok	10.4.2.103
2289	cpignol	zaalpes-storageBatchOpen	2017-06-23 15:05:57	ok	10.4.2.103
2290	cpignol	zaalpes-importChange	2017-06-23 15:06:16	ok	10.4.2.103
2291	cpignol	zaalpes-sampleList	2017-06-23 15:06:23	ok	10.4.2.103
2292	cpignol	zaalpes-sampleChange	2017-06-23 15:06:34	ok	10.4.2.103
2293	cpignol	zaalpes-disconnect	2017-06-23 15:07:22	ok	10.4.2.103
2294	unknown	zaalpes-containerList	2017-06-23 15:07:31	nologin	10.4.2.103
2295	unknown	zaalpes-sampleList	2017-06-23 15:07:38	nologin	10.4.2.103
2296	unknown	zaalpes-containerList	2017-06-26 13:59:46	nologin	10.4.2.103
2297	cpignol	zaalpes-connexion	2017-06-26 14:22:49	db-ok	10.4.2.103
2298	cpignol	zaalpes-containerList	2017-06-26 14:22:49	ok	10.4.2.103
2299	cpignol	zaalpes-containerTypeGetFromFamily	2017-06-26 14:22:51	ok	10.4.2.103
2300	cpignol	zaalpes-samplingPlaceList	2017-06-26 14:22:56	ok	10.4.2.103
2301	cpignol	zaalpes-containerTypeList	2017-06-26 14:27:15	ok	10.4.2.103
2302	cpignol	zaalpes-sampleTypeList	2017-06-26 14:27:28	ok	10.4.2.103
2303	cpignol	zaalpes-sampleTypeChange	2017-06-26 14:27:31	ok	10.4.2.103
2304	cpignol	zaalpes-sampleList	2017-06-26 14:27:46	ok	10.4.2.103
2305	cpignol	zaalpes-importChange	2017-06-26 14:27:49	ok	10.4.2.103
2306	unknown	zaalpes-disconnect	2017-06-27 13:45:25	ok	10.4.2.103
2307	unknown	zaalpes-connexion	2017-06-27 13:45:32	ok	10.4.2.103
2308	cpignol	zaalpes-connexion	2017-06-27 14:14:19	db-ok	10.4.2.103
2309	cpignol	zaalpes-default	2017-06-27 14:14:19	ok	10.4.2.103
2310	cpignol	zaalpes-loginList	2017-06-27 14:14:28	ok	10.4.2.103
2311	cpignol	zaalpes-loginChange	2017-06-27 14:14:51	ok	10.4.2.103
2312	cpignol	zaalpes-loginWrite	2017-06-27 14:16:30	ok	10.4.2.103
2313	cpignol	zaalpes-LoginGestion-write	2017-06-27 14:16:30	8	10.4.2.103
2314	cpignol	zaalpes-loginList	2017-06-27 14:16:30	ok	10.4.2.103
2315	cpignol	zaalpes-appliList	2017-06-27 14:16:52	ok	10.4.2.103
2316	cpignol	zaalpes-appliDisplay	2017-06-27 14:17:04	ok	10.4.2.103
2317	cpignol	zaalpes-acoChange	2017-06-27 14:17:13	ok	10.4.2.103
2318	cpignol	zaalpes-appliList	2017-06-27 14:17:24	ok	10.4.2.103
2319	cpignol	zaalpes-appliChange	2017-06-27 14:17:27	ok	10.4.2.103
2320	cpignol	zaalpes-groupList	2017-06-27 14:17:32	ok	10.4.2.103
2321	cpignol	zaalpes-groupChange	2017-06-27 14:17:37	ok	10.4.2.103
2322	cpignol	zaalpes-groupWrite	2017-06-27 14:18:05	ok	10.4.2.103
2323	cpignol	zaalpes-Aclgroup-write	2017-06-27 14:18:05	1	10.4.2.103
2324	cpignol	zaalpes-groupList	2017-06-27 14:18:05	ok	10.4.2.103
2325	cpignol	zaalpes-groupChange	2017-06-27 14:18:15	ok	10.4.2.103
2326	cpignol	zaalpes-groupWrite	2017-06-27 14:18:22	ok	10.4.2.103
2327	cpignol	zaalpes-Aclgroup-write	2017-06-27 14:18:22	31	10.4.2.103
2328	cpignol	zaalpes-groupList	2017-06-27 14:18:22	ok	10.4.2.103
2329	cpignol	zaalpes-groupChange	2017-06-27 14:18:26	ok	10.4.2.103
2330	cpignol	zaalpes-groupWrite	2017-06-27 14:18:30	ok	10.4.2.103
2331	cpignol	zaalpes-Aclgroup-write	2017-06-27 14:18:30	1	10.4.2.103
2332	cpignol	zaalpes-groupList	2017-06-27 14:18:30	ok	10.4.2.103
2333	cpignol	zaalpes-groupChange	2017-06-27 14:18:43	ok	10.4.2.103
2334	cpignol	zaalpes-disconnect	2017-06-27 14:18:56	ok	10.4.2.103
2335	unknown	zaalpes-connexion	2017-06-27 14:18:59	ok	10.4.2.103
2336	admindemo	zaalpes-connexion	2017-06-27 14:20:15	db-ok	10.4.2.103
2337	admindemo	zaalpes-default	2017-06-27 14:20:15	ok	10.4.2.103
2338	admindemo	zaalpes-sampleList	2017-06-27 14:20:26	ok	10.4.2.103
2339	admindemo	zaalpes-sampleList	2017-06-27 14:20:29	ok	10.4.2.103
2340	admindemo	zaalpes-sampleDisplay	2017-06-27 14:20:33	ok	10.4.2.103
2341	admindemo	zaalpes-storage	2017-06-27 14:20:39	ok	10.4.2.103
2342	admindemo	zaalpes-fastInputChange	2017-06-27 14:20:46	ok	10.4.2.103
2343	admindemo	zaalpes-objectGetDetail	2017-06-27 14:20:56	ok	10.4.2.103
2344	admindemo	zaalpes-labelList	2017-06-27 14:20:56	ok	10.4.2.103
2345	admindemo	zaalpes-administration	2017-06-27 14:21:58	ok	10.4.2.103
2346	admindemo	zaalpes-loginList	2017-06-27 14:22:13	ok	10.4.2.103
2347	admindemo	zaalpes-loginChange	2017-06-27 14:22:18	ok	10.4.2.103
2348	admindemo	zaalpes-loginList	2017-06-27 14:22:39	ok	10.4.2.103
\.


--
-- Name: log_log_id_seq; Type: SEQUENCE SET; Schema: gacl; Owner: collec
--

SELECT pg_catalog.setval('log_log_id_seq', 2348, true);


--
-- Data for Name: login_oldpassword; Type: TABLE DATA; Schema: gacl; Owner: collec
--

COPY login_oldpassword (login_oldpassword_id, id, password) FROM stdin;
1	1	cd916028a2d8a1b901e831246dd5b9b4d3832786ddc63bbf5af4b50d9fc98f50
2	1	cfd3c0f2f89c29869f1889a8c45a50098a965d060a5b49d9db99df2970815450
\.


--
-- Name: login_oldpassword_login_oldpassword_id_seq; Type: SEQUENCE SET; Schema: gacl; Owner: collec
--

SELECT pg_catalog.setval('login_oldpassword_login_oldpassword_id_seq', 2, true);


--
-- Data for Name: logingestion; Type: TABLE DATA; Schema: gacl; Owner: collec
--

COPY logingestion (id, login, password, nom, prenom, mail, datemodif, actif) FROM stdin;
1	admin	682dd7115477b6e777e5ddb99c8c6936206953ca6a44cd8653f8b0327447a11a	Administrator	\N	\N	2017-02-28	1
3	cpignol	9fbd2e4d19289f163a6abb1fb44bc6906aeff84682b19a42d55d0811120b121a	pignol	cécile	cecile.pignol@univ-smb.fr	2017-06-13	1
4	arnaud_f	c25948ad1bb8b6df6763d282b2f2806c69f9b8b16a48457519c38e2f12cec311	ARNAUD	Fabien	\N	2017-06-16	1
5	frossard_v	64c98cc6d55e09212f6170c53071c2cdb17ebf5b8ec9292575e682da450213e6	FROSSARD	V	\N	2017-06-16	1
6	jenny_jp	35aa170d400d6cbddd192fa7d7cddebd562239c2bea97e9ca828387f12aa6c84	JENNY	Jean-Philippe	\N	2017-06-16	1
7	test-collec	a69d07ea1565400a610603d2e22178944ea2c23ad0fbbb429ea09ab3b0751c68	Christine	Plumejeaud-Perreau	christine.plumejeaud-perreau@univ-lr.fr	2017-06-21	1
8	admindemo	bca737c4fb3665ed3789f8fca2ef8be24da8f0a8a52fe84d3a06df94d3081162	admindemo	admindemo	\N	2017-06-27	1
\.


--
-- Name: seq_logingestion_id; Type: SEQUENCE SET; Schema: gacl; Owner: collec
--

SELECT pg_catalog.setval('seq_logingestion_id', 8, true);


SET search_path = zaalpes, pg_catalog;

--
-- Data for Name: booking; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY booking (booking_id, uid, booking_date, date_from, date_to, booking_comment, booking_login) FROM stdin;
\.


--
-- Name: booking_booking_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('booking_booking_id_seq', 1, false);


--
-- Data for Name: container; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY container (container_id, uid, container_type_id) FROM stdin;
1	1	1
8	8	7
9	9	7
11	11	7
12	12	7
13	13	7
14	14	7
15	15	7
16	16	7
17	17	7
18	18	7
19	19	7
20	20	7
21	21	7
22	22	7
23	23	7
24	24	7
25	25	7
26	26	7
27	27	7
28	28	7
29	29	7
30	30	7
31	31	7
32	32	7
33	33	7
34	34	7
35	35	7
36	36	7
37	37	7
38	38	7
39	39	7
40	40	7
41	41	7
42	42	7
43	43	7
44	44	7
45	45	7
46	46	7
47	47	7
48	48	7
49	49	7
50	50	7
51	51	7
52	52	7
53	53	7
54	54	7
55	55	7
56	56	7
57	57	7
58	58	7
59	59	7
60	60	7
61	61	7
62	62	7
63	63	7
64	64	7
65	65	7
66	66	7
67	67	7
68	68	7
69	69	7
70	70	7
71	71	7
72	72	7
73	73	7
74	74	7
75	75	7
76	76	7
77	77	7
78	78	7
79	79	7
80	80	7
81	81	7
82	82	7
83	83	7
84	84	7
85	85	7
86	86	7
87	87	7
89	91	7
88	88	6
2	2	6
5	5	6
3	3	6
4	4	6
6	6	6
7	7	6
\.


--
-- Name: container_container_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('container_container_id_seq', 89, true);


--
-- Data for Name: container_family; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY container_family (container_family_id, container_family_name, is_movable) FROM stdin;
1	Immobilier	f
2	Mobilier	f
\.


--
-- Name: container_family_container_family_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('container_family_container_family_id_seq', 2, true);


--
-- Data for Name: container_type; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY container_type (container_type_id, container_type_name, container_family_id, storage_condition_id, label_id, container_type_description, storage_product, clp_classification) FROM stdin;
1	Site	1	\N	\N	\N	\N	\N
2	Bâtiment	1	\N	\N	\N	\N	\N
3	Pièce	1	\N	\N	\N	\N	\N
4	Armoire	2	\N	\N	\N	\N	\N
5	Congélateur	2	\N	\N	\N	\N	\N
7	Etui_ou_casier	2	1	3	Case de rangement des carottes sédimentaires (run/section/demi_section)	\N	\N
6	Chambre froide	1	1	2	Pièce pour conservation de carottes (conteneur ou chambre froide) à 4°C, avec ou sans étuis. Etiquettes posées sur les portes.	\N	\N
\.


--
-- Name: container_type_container_type_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('container_type_container_type_id_seq', 7, true);


--
-- Data for Name: document; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY document (document_id, uid, mime_type_id, document_import_date, document_name, document_description, data, thumbnail, size, document_creation_date) FROM stdin;
\.


--
-- Name: document_document_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('document_document_id_seq', 1, false);


--
-- Data for Name: event; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY event (event_id, uid, event_date, event_type_id, still_available, event_comment) FROM stdin;
\.


--
-- Name: event_event_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('event_event_id_seq', 1, false);


--
-- Data for Name: event_type; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY event_type (event_type_id, event_type_name, is_sample, is_container) FROM stdin;
1	Autre	t	t
2	Conteneur cassé	f	t
3	Échantillon détruit	t	f
4	Prélèvement pour analyse	t	f
5	Échantillon totalement analysé, détruit	t	f
\.


--
-- Name: event_type_event_type_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('event_type_event_type_id_seq', 5, true);


--
-- Data for Name: identifier_type; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY identifier_type (identifier_type_id, identifier_type_name, identifier_type_code) FROM stdin;
1	conteneur_porte	conteneur_porte
2	igsn	igsn
\.


--
-- Name: identifier_type_identifier_type_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('identifier_type_identifier_type_id_seq', 2, true);


--
-- Data for Name: label; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY label (label_id, label_name, label_xsl, label_fields, operation_id) FROM stdin;
1	Exemple - ne pas utiliser	<?xml version="1.0" encoding="utf-8"?>\n<xsl:stylesheet version="1.0"\n      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\n      xmlns:fo="http://www.w3.org/1999/XSL/Format">\n  <xsl:output method="xml" indent="yes"/>\n  <xsl:template match="objects">\n    <fo:root>\n      <fo:layout-master-set>\n        <fo:simple-page-master master-name="label"\n              page-height="5cm" page-width="10cm" margin-left="0.5cm" margin-top="0.5cm" margin-bottom="0cm" margin-right="0.5cm">  \n              <fo:region-body/>\n        </fo:simple-page-master>\n      </fo:layout-master-set>\n      \n      <fo:page-sequence master-reference="label">\n         <fo:flow flow-name="xsl-region-body">        \n          <fo:block>\n          <xsl:apply-templates select="object" />\n          </fo:block>\n\n        </fo:flow>\n      </fo:page-sequence>\n    </fo:root>\n   </xsl:template>\n  <xsl:template match="object">\n\n  <fo:table table-layout="fixed" border-collapse="collapse"  border-style="none" width="8cm" keep-together.within-page="always">\n  <fo:table-column column-width="4cm"/>\n  <fo:table-column column-width="4cm" />\n <fo:table-body  border-style="none" >\n \t<fo:table-row>\n  \t\t<fo:table-cell> \n  \t\t<fo:block>\n  \t\t<fo:external-graphic>\n      <xsl:attribute name="src">\n             <xsl:value-of select="concat(uid,'.png')" />\n       </xsl:attribute>\n       <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\n       <xsl:attribute name="height">4cm</xsl:attribute>\n        <xsl:attribute name="content-width">4cm</xsl:attribute>\n        <xsl:attribute name="scaling">uniform</xsl:attribute>\n      \n       </fo:external-graphic>\n \t\t</fo:block>\n   \t\t</fo:table-cell>\n  \t\t<fo:table-cell>\n<fo:block><fo:inline font-weight="bold">IRSTEA</fo:inline></fo:block>\n  \t\t\t<fo:block>uid:<fo:inline font-weight="bold"><xsl:value-of select="db"/>:<xsl:value-of select="uid"/></fo:inline></fo:block>\n  \t\t\t<fo:block>id:<fo:inline font-weight="bold"><xsl:value-of select="id"/></fo:inline></fo:block>\n  \t\t\t<fo:block>prj:<fo:inline font-weight="bold"><xsl:value-of select="prj"/></fo:inline></fo:block>\n  \t\t\t<fo:block>clp:<fo:inline font-weight="bold"><xsl:value-of select="clp"/></fo:inline></fo:block>\n  \t\t</fo:table-cell>\n  \t  \t</fo:table-row>\n  </fo:table-body>\n  </fo:table>\n   <fo:block page-break-after="always"/>\n\n  </xsl:template>\n</xsl:stylesheet>	uid,id,clp,db,prj	\N
3	Etiquette_casier_ou_étui_chambre_froide	<?xml version="1.0" encoding="utf-8"?>\r\n<xsl:stylesheet version="1.0"\r\n      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\r\n      xmlns:fo="http://www.w3.org/1999/XSL/Format">\r\n  <xsl:output method="xml" indent="yes"/>\r\n  <xsl:template match="objects">\r\n    <fo:root>\r\n      <fo:layout-master-set>\r\n        <fo:simple-page-master master-name="label"\r\n              page-height="5.1cm" page-width="7.6cm" margin-left="0.3cm" margin-top="0.3cm" margin-bottom="0.3cm" margin-right="0.3cm">  \r\n              <fo:region-body/>\r\n        </fo:simple-page-master>\r\n      </fo:layout-master-set>\r\n      \r\n      <fo:page-sequence master-reference="label">\r\n         <fo:flow flow-name="xsl-region-body">        \r\n          <fo:block>\r\n          <xsl:apply-templates select="object" />\r\n          </fo:block>\r\n\r\n        </fo:flow>\r\n      </fo:page-sequence>\r\n    </fo:root>\r\n   </xsl:template>\r\n  <xsl:template match="object">\r\n\r\n  <fo:table table-layout="fixed" border-collapse="collapse"  border-style="none" width="7cm" keep-together.within-page="always">\r\n  <fo:table-column column-width="4.5cm"/>\r\n  <fo:table-column column-width="2.5cm" />\r\n  \r\n <fo:table-body  border-style="none" >\r\n    <fo:table-row>\r\n\r\n        <fo:table-cell> \r\n            <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n            <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>\r\n            <fo:block>CONTENEUR:<fo:inline  font-size="12pt"><xsl:value-of select="conteneur_porte"/></fo:inline></fo:block>\r\n            <fo:block> </fo:block>\r\n            <fo:block>CASIER:<fo:inline font-weight="bold" font-size="24pt"><xsl:value-of select="id"/></fo:inline></fo:block>\r\n        </fo:table-cell>\r\n        <fo:table-cell> \r\n        <fo:block>\r\n        <fo:external-graphic>\r\n            <xsl:attribute name="src">\r\n                 <xsl:value-of select="concat(uid,'.png')" />\r\n            </xsl:attribute>\r\n            <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n            <xsl:attribute name="content-width">2cm</xsl:attribute>\r\n            <xsl:attribute name="scaling">uniform</xsl:attribute>\r\n        </fo:external-graphic>\r\n        </fo:block>\r\n        </fo:table-cell>\r\n    </fo:table-row>\r\n    <fo:table-row>\r\n\r\n        <fo:table-cell> \r\n            <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n            <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>\r\n            <fo:block>CONTENEUR:<fo:inline font-size="12pt"><xsl:value-of select="conteneur_porte"/></fo:inline></fo:block>\r\n            <fo:block> </fo:block>\r\n            <fo:block>CASIER:<fo:inline font-weight="bold" font-size="24pt"><xsl:value-of select="id"/></fo:inline></fo:block>\r\n\r\n        </fo:table-cell>\r\n        <fo:table-cell> \r\n        <fo:block>\r\n        <fo:external-graphic>\r\n            <xsl:attribute name="src">\r\n                 <xsl:value-of select="concat(uid,'.png')" />\r\n            </xsl:attribute>\r\n            <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n            <xsl:attribute name="content-width">2cm</xsl:attribute>\r\n            <xsl:attribute name="scaling">uniform</xsl:attribute>\r\n        </fo:external-graphic>\r\n        </fo:block>\r\n        </fo:table-cell>\r\n    </fo:table-row>\r\n  </fo:table-body>\r\n  </fo:table>\r\n\r\n  </xsl:template>\r\n</xsl:stylesheet>	uid,id,db,conteneur_porte	\N
2	Etiquette_porte_chambre_froide	<?xml version="1.0" encoding="utf-8"?>\r\n<xsl:stylesheet version="1.0"\r\n      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\r\n      xmlns:fo="http://www.w3.org/1999/XSL/Format">\r\n  <xsl:output method="xml" indent="yes"/>\r\n  <xsl:template match="objects">\r\n    <fo:root>\r\n      <fo:layout-master-set>\r\n        <fo:simple-page-master master-name="label"\r\n              page-height="5.1cm" page-width="7.6cm" margin-left="0.5cm" margin-top="0.5cm" margin-bottom="0cm" margin-right="0.5cm">  \r\n              <fo:region-body/>\r\n        </fo:simple-page-master>\r\n      </fo:layout-master-set>\r\n      \r\n      <fo:page-sequence master-reference="label">\r\n         <fo:flow flow-name="xsl-region-body">        \r\n          <fo:block>\r\n          <xsl:apply-templates select="object" />\r\n          </fo:block>\r\n\r\n        </fo:flow>\r\n      </fo:page-sequence>\r\n    </fo:root>\r\n   </xsl:template>\r\n  <xsl:template match="object">\r\n\r\n  <fo:table table-layout="fixed" border-collapse="collapse"  border-style="none" width="7cm" keep-together.within-page="always">\r\n  <fo:table-column column-width="3.5cm"/>\r\n  <fo:table-column column-width="3.5cm" />\r\n <fo:table-body  border-style="none" >\r\n    <fo:table-row>\r\n        <fo:table-cell> \r\n        <fo:block>\r\n        <fo:external-graphic>\r\n      <xsl:attribute name="src">\r\n             <xsl:value-of select="concat(uid,'.png')" />\r\n       </xsl:attribute>\r\n       <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n       <xsl:attribute name="height">3.5cm</xsl:attribute>\r\n        <xsl:attribute name="content-width">3.5cm</xsl:attribute>\r\n        <xsl:attribute name="scaling">uniform</xsl:attribute>\r\n         <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n      \r\n       </fo:external-graphic>\r\n        </fo:block>\r\n        </fo:table-cell>\r\n        <fo:table-cell> \r\n<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>\r\n<fo:block><fo:inline font-weight="bold">PORTE</fo:inline></fo:block>\r\n            <fo:block><fo:inline font-weight="bold"><xsl:value-of select="db"/></fo:inline></fo:block>\r\n<fo:block> </fo:block>\r\n            <fo:block>id:<fo:inline font-weight="bold"  font-size="24pt"><xsl:value-of select="id"/></fo:inline></fo:block>\r\n        </fo:table-cell>\r\n        </fo:table-row>\r\n  </fo:table-body>\r\n  </fo:table>\r\n  </xsl:template>\r\n</xsl:stylesheet>	id,db,uid	\N
4	Etiquette_run_section_beforeIGSN	<?xml version="1.0" encoding="utf-8"?>\r\n<xsl:stylesheet version="1.0"\r\n      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\r\n      xmlns:fo="http://www.w3.org/1999/XSL/Format">\r\n  <xsl:output method="xml" indent="yes"/>\r\n  <xsl:template match="objects">\r\n    <fo:root>\r\n      <fo:layout-master-set>\r\n        <fo:simple-page-master master-name="label"\r\n              page-height="3.2cm" page-width="5.7cm" margin-left="0.35cm" margin-top="0.1cm" margin-bottom="0.1cm" margin-right="0.35cm">  \r\n              <fo:region-body/>\r\n        </fo:simple-page-master>\r\n      </fo:layout-master-set>\r\n      \r\n      <fo:page-sequence master-reference="label">\r\n         <fo:flow flow-name="xsl-region-body">        \r\n          <fo:block>\r\n          <xsl:apply-templates select="object" />\r\n          </fo:block>\r\n\r\n        </fo:flow>\r\n      </fo:page-sequence>\r\n    </fo:root>\r\n   </xsl:template>\r\n  <xsl:template match="object">\r\n\r\n  <fo:table table-layout="fixed" border-collapse="collapse"  border-style="none" width="5cm" keep-together.within-page="always">\r\n  <fo:table-column column-width="2cm"/>\r\n  <fo:table-column column-width="3cm" />\r\n <fo:table-body  border-style="none" >\r\n    <fo:table-row>\r\n        <fo:table-cell> \r\n        <fo:block>\r\n        <fo:external-graphic>\r\n      <xsl:attribute name="src">\r\n             <xsl:value-of select="concat(uid,'.png')" />\r\n       </xsl:attribute>\r\n       <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n       <xsl:attribute name="height">1.9cm</xsl:attribute>\r\n        <xsl:attribute name="scaling">uniform</xsl:attribute>\r\n       </fo:external-graphic>\r\n        </fo:block>\r\n<fo:block  linefeed-treatment="preserve"><fo:inline font-size="7pt">EDYTEM &#xA; igsn in progress</fo:inline></fo:block>\r\n        </fo:table-cell>\r\n        <fo:table-cell> \r\n<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>\r\n            <fo:block font-size="9pt">uid:<fo:inline font-weight="bold"><xsl:value-of select="db"/>:<xsl:value-of select="uid"/></fo:inline></fo:block>\r\n            <fo:block><fo:inline font-size="9pt"><xsl:value-of select="SITE"/></fo:inline></fo:block>\r\n            <fo:block><fo:inline font-size="9pt"><xsl:value-of select="TYPE"/></fo:inline></fo:block>\r\n            <fo:block><fo:inline font-size="10pt" font-weight="bold"><xsl:value-of select="id"/></fo:inline></fo:block>\r\n            <fo:block><fo:inline font-size="9pt"><xsl:value-of select="LONGUEUR"/> (L) / <xsl:value-of select="PROFONDEUR"/> (Z)</fo:inline></fo:block>\r\n            <fo:block><fo:inline font-size="9pt"><xsl:value-of select="PI"/></fo:inline></fo:block>\r\n        </fo:table-cell>\r\n        </fo:table-row>\r\n  </fo:table-body>\r\n  </fo:table>\r\n  </xsl:template>\r\n</xsl:stylesheet>	db,uid,id,prj,cd,x,y,PI	\N
5	Etiquette_run_section_IGSN	<?xml version="1.0" encoding="utf-8"?>\r\n<xsl:stylesheet version="1.0"\r\n      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\r\n      xmlns:fo="http://www.w3.org/1999/XSL/Format">\r\n  <xsl:output method="xml" indent="yes"/>\r\n  <xsl:template match="objects">\r\n    <fo:root>\r\n      <fo:layout-master-set>\r\n        <fo:simple-page-master master-name="label"\r\n              page-height="3.2cm" page-width="5.7cm" margin-left="0cm" margin-top="0cm" margin-bottom="0cm" margin-right="0cm">  \r\n              <fo:region-body/>\r\n        </fo:simple-page-master>\r\n      </fo:layout-master-set>\r\n      \r\n      <fo:page-sequence master-reference="label">\r\n         <fo:flow flow-name="xsl-region-body">        \r\n          <fo:block>\r\n          <xsl:apply-templates select="object" />\r\n          </fo:block>\r\n\r\n        </fo:flow>\r\n      </fo:page-sequence>\r\n    </fo:root>\r\n   </xsl:template>\r\n  <xsl:template match="object">\r\n\r\n<fo:table table-layout="fixed" border-collapse="collapse"  border-style="none" width="5cm" keep-together.within-page="always">\r\n  <fo:table-column column-width="3cm"/>\r\n  <fo:table-column column-width="2cm" />\r\n <fo:table-body  border-style="none" >\r\n    <fo:table-row>\r\n        <fo:table-cell> \r\n        <fo:block>\r\n        <fo:external-graphic>\r\n      <xsl:attribute name="src">\r\n             <xsl:value-of select="concat(uid,'.png')" />\r\n       </xsl:attribute>\r\n       <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n       <xsl:attribute name="height">2.5cm</xsl:attribute>\r\n        <xsl:attribute name="scaling">uniform</xsl:attribute>\r\n       </fo:external-graphic>\r\n        </fo:block>\r\n<fo:block  linefeed-treatment="preserve" line-height="110%"><fo:inline font-size="7pt">igsn: <xsl:value-of select="igsn"/></fo:inline></fo:block>\r\n        </fo:table-cell>\r\n        <fo:table-cell> \r\n<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>\r\n            <fo:block font-size="7pt" line-height="120%">uid:<fo:inline font-weight="bold"><xsl:value-of select="db"/>:<xsl:value-of select="uid"/></fo:inline></fo:block>\r\n            <fo:block line-height="110%"><fo:inline font-size="7pt"><xsl:value-of select="SITE"/></fo:inline></fo:block>\r\n            <fo:block line-height="110%"><fo:inline font-size="7pt"><xsl:value-of select="TYPE"/></fo:inline></fo:block>\r\n            <fo:block line-height="110%"><fo:inline font-size="7pt" font-weight="bold"><xsl:value-of select="id"/></fo:inline></fo:block>\r\n            <fo:block line-height="110%"><fo:inline font-size="7pt"><xsl:value-of select="LONGUEUR"/> (L) / <xsl:value-of select="PROFONDEUR"/> (Z)</fo:inline></fo:block>\r\n            <fo:block line-height="110%"><fo:inline font-size="7pt"><xsl:value-of select="PI"/></fo:inline></fo:block>\r\n        </fo:table-cell>\r\n        </fo:table-row>\r\n  </fo:table-body>\r\n  </fo:table>\r\n  \r\n  </xsl:template>\r\n</xsl:stylesheet>	db,uid,id,prj,cd,x,y,PI,igsn	\N
6	Etiquettes_tube	<?xml version="1.0" encoding="utf-8"?>\r\n<xsl:stylesheet version="1.0"\r\n      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\r\n      xmlns:fo="http://www.w3.org/1999/XSL/Format">\r\n  <xsl:output method="xml" indent="yes"/>\r\n  <xsl:template match="objects">\r\n    <fo:root>\r\n      <fo:layout-master-set>\r\n        <fo:simple-page-master master-name="label"\r\n              page-height="1.2cm" page-width="4.1cm" margin-left="0.4cm" margin-top="0.1cm" margin-bottom="0cm" margin-right="0.3cm">  \r\n              <fo:region-body/>\r\n        </fo:simple-page-master>\r\n      </fo:layout-master-set>\r\n      \r\n      <fo:page-sequence master-reference="label">\r\n         <fo:flow flow-name="xsl-region-body">        \r\n          <fo:block>\r\n          <xsl:apply-templates select="object" />\r\n          </fo:block>\r\n\r\n        </fo:flow>\r\n      </fo:page-sequence>\r\n    </fo:root>\r\n   </xsl:template>\r\n  <xsl:template match="object">\r\n\r\n  <fo:table table-layout="fixed" border-collapse="collapse"  border-style="none" width="35cm" keep-together.within-page="always">\r\n  <fo:table-column column-width="1.5cm"/>\r\n  <fo:table-column column-width="2cm" />\r\n <fo:table-body  border-style="none" >\r\n    <fo:table-row>\r\n        <fo:table-cell> \r\n        <fo:block>\r\n        <fo:external-graphic>\r\n      <xsl:attribute name="src">\r\n             <xsl:value-of select="concat(uid,'.png')" />\r\n       </xsl:attribute>\r\n       <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n       <xsl:attribute name="height">1cm</xsl:attribute>\r\n        <xsl:attribute name="content-width">1cm</xsl:attribute>\r\n        <xsl:attribute name="scaling">uniform</xsl:attribute>\r\n      \r\n       </fo:external-graphic>\r\n        </fo:block>\r\n        </fo:table-cell>\r\n        <fo:table-cell>\r\n\r\n            <fo:block>uid:<fo:inline font-weight="bold"><xsl:value-of select="uid"/></fo:inline></fo:block>\r\n            \r\n        </fo:table-cell>\r\n        </fo:table-row>\r\n  </fo:table-body>\r\n  </fo:table>\r\n   <fo:block page-break-after="always"/>\r\n\r\n  </xsl:template>\r\n</xsl:stylesheet>\r\n	uid	\N
7	Etiquettes_tube_QRrectangle	<?xml version="1.0" encoding="utf-8"?>\r\n<xsl:stylesheet version="1.0"\r\n      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\r\n      xmlns:fo="http://www.w3.org/1999/XSL/Format">\r\n  <xsl:output method="xml" indent="yes"/>\r\n  <xsl:template match="objects">\r\n    <fo:root>\r\n      <fo:layout-master-set>\r\n        <fo:simple-page-master master-name="label"\r\n              page-height="1.2cm" page-width="4.1cm" margin-left="0.4cm" margin-top="0.1cm" margin-bottom="0cm" margin-right="0.7cm">  \r\n              <fo:region-body/>\r\n        </fo:simple-page-master>\r\n      </fo:layout-master-set>\r\n      \r\n      <fo:page-sequence master-reference="label">\r\n         <fo:flow flow-name="xsl-region-body">        \r\n          <fo:block>\r\n          <xsl:apply-templates select="object" />\r\n          </fo:block>\r\n\r\n        </fo:flow>\r\n      </fo:page-sequence>\r\n    </fo:root>\r\n   </xsl:template>\r\n  <xsl:template match="object">\r\n\r\n  <fo:table table-layout="fixed" border-collapse="collapse" border="1pt" border-style="none" width="2.8cm" keep-together.within-page="always" keep-together.within-column="always">\r\n  <fo:table-column column-width="1.5cm"/>\r\n  <fo:table-column column-width="1cm" />\r\n  <fo:table-column column-width="0.3cm" />\r\n <fo:table-body  border-style="none" >\r\n    <fo:table-row>\r\n\r\n        <fo:table-cell> \r\n        <fo:block>\r\n        <fo:external-graphic>\r\n      <xsl:attribute name="src">\r\n             <xsl:value-of select="concat(uid,'.png')" />\r\n       </xsl:attribute>\r\n       <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n       <xsl:attribute name="height">1cm</xsl:attribute>\r\n        <xsl:attribute name="content-width">1cm</xsl:attribute>\r\n        <xsl:attribute name="scaling">uniform</xsl:attribute>\r\n       </fo:external-graphic>\r\n        </fo:block>\r\n        </fo:table-cell>\r\n\r\n        <fo:table-cell> \r\n        <fo:block>\r\n        <fo:external-graphic>\r\n      <xsl:attribute name="src">\r\n             <xsl:value-of select="concat(uid,'.png')" />\r\n       </xsl:attribute>\r\n       <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>\r\n       <xsl:attribute name="height">1cm</xsl:attribute>\r\n        <xsl:attribute name="content-width">1cm</xsl:attribute>\r\n        <xsl:attribute name="scaling">uniform</xsl:attribute>\r\n       </fo:external-graphic>\r\n        </fo:block>\r\n        </fo:table-cell>\r\n\r\n        <fo:table-cell>\r\n            <fo:block wrap-option="wrap"><fo:inline font-size="6pt"><xsl:value-of select="id"/></fo:inline></fo:block>          \r\n        </fo:table-cell>\r\n        </fo:table-row>\r\n  </fo:table-body>\r\n  </fo:table>\r\n\r\n  </xsl:template>\r\n</xsl:stylesheet>	uid,db	\N
\.


--
-- Name: label_label_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('label_label_id_seq', 7, true);


--
-- Data for Name: metadata_form; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY metadata_form (metadata_form_id, metadata_schema) FROM stdin;
1	[{"nom":"SITE","type":"string","require":true,"helperChoice":false,"description":"Nom du lac/site d'extraction","meusureUnit":"champs libre"},{"nom":"TYPE","type":"select","choiceList":["SEDIMENT","SOL","LIQUIDE","ROCHE"],"require":false,"helperChoice":true,"helper":"type des substrat depuis lequel la carotte est extraite","description":"type des substrat depuis lequel la carotte est extraite","meusureUnit":"liste de choix"},{"nom":"SAMPLE_NAME","type":"string","require":true,"helperChoice":true,"helper":"Identifiant STOCK de la carotte","description":"Identifiant STOCK de la carotte","meusureUnit":"sans"},{"nom":"LONGUEUR","type":"string","require":false,"helperChoice":true,"helper":"Longueur du run ou de la section","description":"Longueur du run ou de la section","meusureUnit":"cm"},{"nom":"PROFONDEUR","type":"string","require":true,"helperChoice":true,"helper":"Profondeur de la carotte en cm (bottom - top)","description":"Profondeur de la carotte en cm (bottom - top)","meusureUnit":"cm"},{"nom":"PI","type":"string","require":true,"helperChoice":true,"helper":"Nom du propriétaire de la carotte","description":"Nom du propriétaire de la carotte","meusureUnit":"sans"}]
\.


--
-- Name: metadata_form_metadata_form_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('metadata_form_metadata_form_id_seq', 1, true);


--
-- Data for Name: mime_type; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY mime_type (mime_type_id, extension, content_type) FROM stdin;
1	pdf	application/pdf
2	zip	application/zip
3	mp3	audio/mpeg
4	jpg	image/jpeg
5	jpeg	image/jpeg
6	png	image/png
7	tiff	image/tiff
9	odt	application/vnd.oasis.opendocument.text
10	ods	application/vnd.oasis.opendocument.spreadsheet
11	xls	application/vnd.ms-excel
12	xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
13	doc	application/msword
14	docx	application/vnd.openxmlformats-officedocument.wordprocessingml.document
8	csv	text/csv
\.


--
-- Name: mime_type_mime_type_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('mime_type_mime_type_id_seq', 1, false);


--
-- Data for Name: movement_type; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY movement_type (movement_type_id, movement_type_name) FROM stdin;
1	Entrée/Entry
2	Sortie/Exit
\.


--
-- Name: movement_type_movement_type_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('movement_type_movement_type_id_seq', 1, false);


--
-- Data for Name: multiple_type; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY multiple_type (multiple_type_id, multiple_type_name) FROM stdin;
1	Unité
2	Pourcentage
3	Quantité ou volume
4	Autre
\.


--
-- Name: multiple_type_multiple_type_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('multiple_type_multiple_type_id_seq', 4, true);


--
-- Data for Name: object; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY object (uid, identifier, object_status_id, wgs84_x, wgs84_y) FROM stdin;
1	EDYTEM	1	5.857086181640625	45.6516803279697285
8	A6	1	5.86899517999999976	45.6410747999999984
9	B11	1	5.86899517999999976	45.6410747999999984
10	B4	1	\N	\N
11	B4	1	\N	\N
12	I5	1	\N	\N
13	M14	1	\N	\N
14	F1	1	\N	\N
15	A6	1	\N	\N
16	B11	1	\N	\N
17	A5	1	\N	\N
18	E1	1	\N	\N
19	I 10	1	\N	\N
20	A6	1	\N	\N
21	B9	1	\N	\N
22	I5	1	\N	\N
23	M14	1	\N	\N
24	B9	1	\N	\N
25	A11	1	\N	\N
26	C13	1	\N	\N
27	M15	1	\N	\N
28	A9	1	\N	\N
29	A9	1	\N	\N
30	B9	1	\N	\N
31	F13	1	\N	\N
32	B9	1	\N	\N
33	A13	1	\N	\N
34	B15	1	\N	\N
35	C10	1	\N	\N
36	B13	1	\N	\N
37	A7	1	\N	\N
38	A5	1	\N	\N
39	A10	1	\N	\N
40	C14	1	\N	\N
41	E15	1	\N	\N
42	G1	1	\N	\N
43	F13	1	\N	\N
44	E1	1	\N	\N
45	B7	1	\N	\N
46	A12	1	\N	\N
47	A12	1	\N	\N
48	A7	1	\N	\N
49	A11	1	\N	\N
50	H7	1	\N	\N
51	C13	1	\N	\N
52	B6	1	\N	\N
53	A3	1	\N	\N
54	A11	1	\N	\N
55	B9	1	\N	\N
56	C10	1	\N	\N
57	I5	1	\N	\N
58	B14	1	\N	\N
59	A12	1	\N	\N
60	D13	1	\N	\N
61	A13	1	\N	\N
62	B13	1	\N	\N
63	B6	1	\N	\N
64	C10	1	\N	\N
65	A9	1	\N	\N
66	A5	1	\N	\N
67	G6	1	\N	\N
68	B9	1	\N	\N
69	A10	1	\N	\N
70	A10	1	\N	\N
71	M14	1	\N	\N
72	A9	1	\N	\N
73	M15	1	\N	\N
74	A12	1	\N	\N
75	I 10	1	\N	\N
76	A3	1	\N	\N
77	C10	1	\N	\N
78	A10	1	\N	\N
79	B4	1	\N	\N
80	F1	1	\N	\N
81	E13	1	\N	\N
82	M14	1	\N	\N
83	E15	1	\N	\N
84	B15	1	\N	\N
85	A4	1	\N	\N
86	A13	1	\N	\N
87	E13	1	\N	\N
89	LDB10-T1-60-04	1	5.82969399999999993	45.7959439999999987
91	I5	1	\N	\N
90	LEM10-P6-02a	1	6.57589999999999986	46.4473830000000021
88	CHAMBRE EDYTEM	1	5.87203145027160467	45.6403269473863986
2	CONTENEUR 1	1	5.872916579246521	45.6400912224206365
5	CONTENEUR 2	1	5.87271407246589483	45.6400565293241414
3	CI - P1	1	5.87298631668090731	45.6400985361005382
4	CI - P2	1	5.87283074855804532	45.6401004114021873
6	CII - P3	1	5.87275698781013578	45.6400780953055687
7	CII - P4	1	5.87268188595771612	45.6400743447006789
92	LDB10-06A	1	5.8549439999999997	45.7619439999999997
\.


--
-- Data for Name: object_identifier; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY object_identifier (object_identifier_id, uid, identifier_type_id, object_identifier_value) FROM stdin;
2	8	1	CI - P2
3	9	1	CI - P2
5	12	1	\tCI - P2
6	13	1	\tCI - P2
7	14	1	\tCI - P2
8	15	1	\tCI - P2
9	16	1	\tCI - P2
10	17	1	\tCI - P2
11	18	1	\tCI - P2
12	19	1	\tCI - P2
13	20	1	\tCI - P2
14	21	1	\tCI - P2
15	22	1	\tCI - P2
16	23	1	\tCI - P2
17	24	1	\tCI - P2
18	25	1	\tCI - P2
19	26	1	\tCI - P2
20	27	1	\tCI - P2
21	28	1	\tCI - P2
22	29	1	\tCI - P2
23	30	1	\tCI - P2
24	31	1	\tCI - P2
25	32	1	\tCI - P2
26	33	1	\tCI - P2
27	34	1	\tCI - P2
28	35	1	\tCI - P2
29	36	1	\tCI - P2
30	37	1	\tCI - P2
31	38	1	\tCI - P2
32	39	1	\tCI - P2
33	40	1	\tCI - P2
34	41	1	\tCI - P2
35	42	1	\tCI - P2
36	43	1	\tCI - P2
37	44	1	\tCI - P2
38	45	1	\tCI - P2
39	46	1	\tCI - P2
40	47	1	\tCI - P2
41	48	1	\tCI - P2
42	49	1	\tCI - P2
43	50	1	\tCI - P2
44	51	1	\tCI - P2
45	52	1	\tCI - P2
46	53	1	\tCI - P2
47	54	1	\tCI - P2
48	55	1	\tCI - P2
49	56	1	\tCI - P2
50	57	1	\tCI - P2
51	58	1	\tCI - P2
52	59	1	\tCI - P2
53	60	1	\tCI - P2
54	61	1	\tCI - P2
55	62	1	\tCI - P2
56	63	1	\tCI - P2
57	64	1	\tCI - P2
58	65	1	\tCI - P2
59	66	1	\tCI - P2
60	67	1	\tCI - P2
61	68	1	\tCI - P2
62	69	1	\tCI - P2
63	70	1	\tCI - P2
64	71	1	\tCI - P2
65	72	1	\tCI - P2
66	73	1	\tCI - P2
67	74	1	\tCI - P2
68	75	1	\tCI - P2
69	76	1	\tCI - P2
70	77	1	\tCI - P2
71	78	1	\tCI - P2
72	79	1	\tCI - P2
73	80	1	\tCI - P2
74	81	1	\tCI - P2
75	82	1	\tCI - P2
76	83	1	\tCI - P2
77	84	1	\tCI - P2
78	85	1	\tCI - P2
79	86	1	\tCI - P2
80	87	1	\tCI - P2
81	11	1	CI - P2
82	89	2	IEFRA004W
83	92	2	IEFRA00NW
85	90	2	IEFRA00XF
\.


--
-- Name: object_identifier_object_identifier_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('object_identifier_object_identifier_id_seq', 85, true);


--
-- Data for Name: object_status; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY object_status (object_status_id, object_status_name) FROM stdin;
1	État normal
2	Objet pré-réservé pour usage ultérieur
3	Objet détruit
4	Echantillon vidé de tout contenu
\.


--
-- Name: object_status_object_status_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('object_status_object_status_id_seq', 4, true);


--
-- Name: object_uid_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('object_uid_seq', 92, true);


--
-- Data for Name: operation; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY operation (operation_id, protocol_id, operation_name, operation_order, metadata_form_id, operation_version, last_edit_date) FROM stdin;
1	1	extraction_run	1	1	v1	2017-06-16 19:03:35
\.


--
-- Name: operation_operation_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('operation_operation_id_seq', 1, true);


--
-- Data for Name: project; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY project (project_id, project_name) FROM stdin;
1	ANR 2008 IPER-RETRO (http://www6.inra.fr/iper_retro)
\.


--
-- Data for Name: project_group; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY project_group (project_id, aclgroup_id) FROM stdin;
1	32
1	31
\.


--
-- Name: project_project_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('project_project_id_seq', 1, true);


--
-- Data for Name: protocol; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY protocol (protocol_id, protocol_name, protocol_file, protocol_year, protocol_version) FROM stdin;
1	A.core_run_section_demi-section	\N	2017	1.0
\.


--
-- Name: protocol_protocol_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('protocol_protocol_id_seq', 1, true);


--
-- Data for Name: sample; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY sample (sample_id, uid, project_id, sample_type_id, sample_creation_date, sample_date, parent_sample_id, multiple_value, sampling_place_id, dbuid_origin, sample_metadata_id) FROM stdin;
1	89	1	1	2017-06-16 19:22:35	2012-05-30 19:22:35	\N	65	16	\N	1
2	90	1	1	2017-06-19 10:32:44	2012-05-30 00:00:00	\N	64	2	\N	2
3	92	1	1	2017-06-19 11:01:04	2012-05-30 00:00:00	\N	104	16	\N	3
\.


--
-- Data for Name: sample_metadata; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY sample_metadata (sample_metadata_id, data) FROM stdin;
1	{"SITE":"BOURGET","TYPE":"SEDIMENT","SAMPLE_NAME":"LDB10-T1-60-04","LONGUEUR":"65","PROFONDEUR":"65","PI":"FROSSARD V"}
2	{"SITE":"LEMAN","TYPE":"SEDIMENT","SAMPLE_NAME":"LEM10-P6-02a","LONGUEUR":"64","PROFONDEUR":"315","PI":"JENNY JP (ORCID:0000-0002-2740-174X)"}
3	{"SITE":"BOURGET","TYPE":"SEDIMENT","SAMPLE_NAME":"LDB10-06A","LONGUEUR":"104","PROFONDEUR":"NA","PI":"JENNY JP (ORCID:0000-0002-2740-174X)"}
\.


--
-- Name: sample_metadata_sample_metadata_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('sample_metadata_sample_metadata_id_seq', 3, true);


--
-- Name: sample_sample_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('sample_sample_id_seq', 3, true);


--
-- Data for Name: sample_type; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY sample_type (sample_type_id, sample_type_name, container_type_id, operation_id, multiple_type_id, multiple_unit) FROM stdin;
1	CORE	7	1	3	cm
\.


--
-- Name: sample_type_sample_type_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('sample_type_sample_type_id_seq', 1, true);


--
-- Data for Name: sampling_place; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY sampling_place (sampling_place_id, sampling_place_name) FROM stdin;
1	ANNECY
2	LEMAN
3	ABBAYE SALINS
4	ALLOS
5	ANTERNE
6	ARMOR
7	ARVOIN
8	BASTANI
9	BENIT
10	BERGSEE
11	BLANC AIGUILLE ROUGE
12	BLANC BELLEDONNE
13	BLANC BELLEDONNE (PETIT)
14	BLED Blejsko Jezero
15	BOHINJ Bohinjsko Jezero
16	BOURGET
17	BREVENT
18	CANARD
19	CAPITELLO
20	CORNU
21	CREUSATES (Tourbière)
22	DOMENON INF
23	DOMENON Inf Petit
24	DOMENON SUP
25	EGORGEOU
26	EYCHAUDA
27	FARAVEL
28	FOREANT
29	FOUGERES
30	GD LAC ESTARIS
31	GERS
32	GIROTTE
33	GOLEON
34	GROS
35	GUYNEMER
36	INFERIORE DI LAURES
37	ISEO
38	KERLOCH
39	KRN
40	LAUVITEL
41	LAUZANIER
42	LAUZIERE
43	LEDVICAH
44	LES ROBERTS
45	LONG Mercantour
46	LOU
47	LUITEL
48	MADDALENA
49	MELO
50	MIAGE (Lac)
51	MUZELLE
52	NAR
53	NINO
54	NOIR AIGUILLE ROUGE Bas
55	ORONAYE
56	PALLUEL
57	PETAREL
58	PETIT
59	PETO
60	PLAN
61	PLAN VIANNEY
62	PLANINI
63	PONTET
64	PORMENAZ
65	PORT COUVREUX
66	POULE
67	PREDIL
68	RING ANSE
69	RIOT
70	ROCHEBUT
71	SAINT-ANDRE
72	SERRE HOMME
73	SESTO
74	SORME
75	THUILE
76	TIERCELIN
77	URBINO
78	VALLON
79	VERNEY
\.


--
-- Name: sampling_place_sampling_place_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('sampling_place_sampling_place_id_seq', 79, true);


--
-- Data for Name: storage; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY storage (storage_id, uid, container_id, movement_type_id, storage_reason_id, storage_date, storage_location, login, storage_comment) FROM stdin;
1	2	1	1	\N	2017-06-16 15:35:41	\N	cpignol	\N
2	3	2	1	\N	2017-06-16 15:36:47	\N	cpignol	\N
3	4	2	1	\N	2017-06-16 15:39:00	\N	cpignol	\N
4	5	1	1	\N	2017-06-16 15:40:49	\N	cpignol	\N
5	6	5	1	\N	2017-06-16 15:41:44	\N	cpignol	\N
6	7	5	1	\N	2017-06-16 15:42:50	\N	cpignol	\N
7	8	4	1	\N	2017-06-16 15:51:01	\N	cpignol	\N
8	9	4	1	\N	2017-06-16 15:54:09	Grille B11	cpignol	pas d'étui
9	10	4	1	\N	2017-06-16 18:00:24	B4	cpignol	\N
10	11	4	1	\N	2017-06-16 18:02:47	B4	cpignol	\N
11	12	4	1	\N	2017-06-16 18:02:47	I5	cpignol	\N
12	13	4	1	\N	2017-06-16 18:02:47	M14	cpignol	\N
13	14	4	1	\N	2017-06-16 18:02:47	F1	cpignol	\N
14	15	4	1	\N	2017-06-16 18:02:47	A6	cpignol	\N
15	16	4	1	\N	2017-06-16 18:02:47	B11	cpignol	\N
16	17	4	1	\N	2017-06-16 18:02:47	A5	cpignol	\N
17	18	4	1	\N	2017-06-16 18:02:47	E1	cpignol	\N
18	19	4	1	\N	2017-06-16 18:02:47	I 10	cpignol	\N
19	20	4	1	\N	2017-06-16 18:02:47	A6	cpignol	\N
20	21	4	1	\N	2017-06-16 18:02:47	B9	cpignol	\N
21	22	4	1	\N	2017-06-16 18:02:47	I5	cpignol	\N
22	23	4	1	\N	2017-06-16 18:02:47	M14	cpignol	\N
23	24	4	1	\N	2017-06-16 18:02:47	B9	cpignol	\N
24	25	4	1	\N	2017-06-16 18:02:47	A11	cpignol	\N
25	26	4	1	\N	2017-06-16 18:02:47	C13	cpignol	\N
26	27	4	1	\N	2017-06-16 18:02:47	M15	cpignol	\N
27	28	4	1	\N	2017-06-16 18:02:47	A9	cpignol	\N
28	29	4	1	\N	2017-06-16 18:02:47	A9	cpignol	\N
29	30	4	1	\N	2017-06-16 18:02:47	B9	cpignol	\N
30	31	4	1	\N	2017-06-16 18:02:47	F13	cpignol	\N
31	32	4	1	\N	2017-06-16 18:02:47	B9	cpignol	\N
32	33	4	1	\N	2017-06-16 18:02:47	A13	cpignol	\N
33	34	4	1	\N	2017-06-16 18:02:47	B15	cpignol	\N
34	35	4	1	\N	2017-06-16 18:02:47	C10	cpignol	\N
35	36	4	1	\N	2017-06-16 18:02:47	B13	cpignol	\N
36	37	4	1	\N	2017-06-16 18:02:47	A7	cpignol	\N
37	38	4	1	\N	2017-06-16 18:02:47	A5	cpignol	\N
38	39	4	1	\N	2017-06-16 18:02:47	A10	cpignol	\N
39	40	4	1	\N	2017-06-16 18:02:47	C14	cpignol	\N
40	41	4	1	\N	2017-06-16 18:02:47	E15	cpignol	\N
41	42	4	1	\N	2017-06-16 18:02:47	G1	cpignol	\N
42	43	4	1	\N	2017-06-16 18:02:47	F13	cpignol	\N
43	44	4	1	\N	2017-06-16 18:02:47	E1	cpignol	\N
44	45	4	1	\N	2017-06-16 18:02:47	B7	cpignol	\N
45	46	4	1	\N	2017-06-16 18:02:47	A12	cpignol	\N
46	47	4	1	\N	2017-06-16 18:02:47	A12	cpignol	\N
47	48	4	1	\N	2017-06-16 18:02:47	A7	cpignol	\N
48	49	4	1	\N	2017-06-16 18:02:47	A11	cpignol	\N
49	50	4	1	\N	2017-06-16 18:02:47	H7	cpignol	\N
50	51	4	1	\N	2017-06-16 18:02:47	C13	cpignol	\N
51	52	4	1	\N	2017-06-16 18:02:47	B6	cpignol	\N
52	53	4	1	\N	2017-06-16 18:02:47	A3	cpignol	\N
53	54	4	1	\N	2017-06-16 18:02:47	A11	cpignol	\N
54	55	4	1	\N	2017-06-16 18:02:47	B9	cpignol	\N
55	56	4	1	\N	2017-06-16 18:02:47	C10	cpignol	\N
56	57	4	1	\N	2017-06-16 18:02:47	I5	cpignol	\N
57	58	4	1	\N	2017-06-16 18:02:47	B14	cpignol	\N
58	59	4	1	\N	2017-06-16 18:02:47	A12	cpignol	\N
59	60	4	1	\N	2017-06-16 18:02:47	D13	cpignol	\N
60	61	4	1	\N	2017-06-16 18:02:47	A13	cpignol	\N
61	62	4	1	\N	2017-06-16 18:02:47	B13	cpignol	\N
62	63	4	1	\N	2017-06-16 18:02:47	B6	cpignol	\N
63	64	4	1	\N	2017-06-16 18:02:47	C10	cpignol	\N
64	65	4	1	\N	2017-06-16 18:02:47	A9	cpignol	\N
65	66	4	1	\N	2017-06-16 18:02:47	A5	cpignol	\N
66	67	4	1	\N	2017-06-16 18:02:47	G6	cpignol	\N
67	68	4	1	\N	2017-06-16 18:02:47	B9	cpignol	\N
68	69	4	1	\N	2017-06-16 18:02:47	A10	cpignol	\N
69	70	4	1	\N	2017-06-16 18:02:47	A10	cpignol	\N
70	71	4	1	\N	2017-06-16 18:02:47	M14	cpignol	\N
71	72	4	1	\N	2017-06-16 18:02:47	A9	cpignol	\N
72	73	4	1	\N	2017-06-16 18:02:47	M15	cpignol	\N
73	74	4	1	\N	2017-06-16 18:02:47	A12	cpignol	\N
74	75	4	1	\N	2017-06-16 18:02:47	I 10	cpignol	\N
75	76	4	1	\N	2017-06-16 18:02:47	A3	cpignol	\N
76	77	4	1	\N	2017-06-16 18:02:47	C10	cpignol	\N
77	78	4	1	\N	2017-06-16 18:02:47	A10	cpignol	\N
78	79	4	1	\N	2017-06-16 18:02:47	B4	cpignol	\N
79	80	4	1	\N	2017-06-16 18:02:47	F1	cpignol	\N
80	81	4	1	\N	2017-06-16 18:02:47	E13	cpignol	\N
81	82	4	1	\N	2017-06-16 18:02:47	M14	cpignol	\N
82	83	4	1	\N	2017-06-16 18:02:47	E15	cpignol	\N
83	84	4	1	\N	2017-06-16 18:02:47	B15	cpignol	\N
84	85	4	1	\N	2017-06-16 18:02:47	A4	cpignol	\N
85	86	4	1	\N	2017-06-16 18:02:47	A13	cpignol	\N
86	87	4	1	\N	2017-06-16 18:02:47	E13	cpignol	\N
87	89	71	1	\N	2017-06-16 19:27:24	M14	cpignol	\N
88	91	4	1	\N	2017-06-19 10:32:44	C1 P2	cpignol	\N
89	90	89	1	\N	2017-06-19 10:32:44	I5	cpignol	\N
90	92	11	1	\N	2017-06-19 11:01:04	B4	cpignol	\N
\.


--
-- Data for Name: storage_condition; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY storage_condition (storage_condition_id, storage_condition_name) FROM stdin;
1	Froid 4°C
2	Sec 20°C
\.


--
-- Name: storage_condition_storage_condition_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('storage_condition_storage_condition_id_seq', 2, true);


--
-- Data for Name: storage_reason; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY storage_reason (storage_reason_id, storage_reason_name) FROM stdin;
\.


--
-- Name: storage_reason_storage_reason_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('storage_reason_storage_reason_id_seq', 1, false);


--
-- Name: storage_storage_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('storage_storage_id_seq', 90, true);


--
-- Data for Name: subsample; Type: TABLE DATA; Schema: zaalpes; Owner: collec
--

COPY subsample (subsample_id, sample_id, subsample_date, movement_type_id, subsample_quantity, subsample_comment, subsample_login) FROM stdin;
\.


--
-- Name: subsample_subsample_id_seq; Type: SEQUENCE SET; Schema: zaalpes; Owner: collec
--

SELECT pg_catalog.setval('subsample_subsample_id_seq', 1, false);


SET search_path = gacl, pg_catalog;

--
-- Name: aclacl_pk; Type: CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclacl
    ADD CONSTRAINT aclacl_pk PRIMARY KEY (aclaco_id, aclgroup_id);


--
-- Name: aclaco_pk; Type: CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclaco
    ADD CONSTRAINT aclaco_pk PRIMARY KEY (aclaco_id);


--
-- Name: aclappli_pk; Type: CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclappli
    ADD CONSTRAINT aclappli_pk PRIMARY KEY (aclappli_id);


--
-- Name: aclgroup_pk; Type: CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclgroup
    ADD CONSTRAINT aclgroup_pk PRIMARY KEY (aclgroup_id);


--
-- Name: acllogin_pk; Type: CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY acllogin
    ADD CONSTRAINT acllogin_pk PRIMARY KEY (acllogin_id);


--
-- Name: acllogingroup_pk; Type: CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY acllogingroup
    ADD CONSTRAINT acllogingroup_pk PRIMARY KEY (acllogin_id, aclgroup_id);


--
-- Name: log_pk; Type: CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY log
    ADD CONSTRAINT log_pk PRIMARY KEY (log_id);


--
-- Name: login_oldpassword_pk; Type: CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY login_oldpassword
    ADD CONSTRAINT login_oldpassword_pk PRIMARY KEY (login_oldpassword_id);


--
-- Name: pk_logingestion; Type: CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY logingestion
    ADD CONSTRAINT pk_logingestion PRIMARY KEY (id);


SET search_path = zaalpes, pg_catalog;

--
-- Name: booking_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY booking
    ADD CONSTRAINT booking_pk PRIMARY KEY (booking_id);


--
-- Name: container_family_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container_family
    ADD CONSTRAINT container_family_pk PRIMARY KEY (container_family_id);


--
-- Name: container_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container
    ADD CONSTRAINT container_pk PRIMARY KEY (container_id);


--
-- Name: container_type_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container_type
    ADD CONSTRAINT container_type_pk PRIMARY KEY (container_type_id);


--
-- Name: document_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_pk PRIMARY KEY (document_id);


--
-- Name: event_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pk PRIMARY KEY (event_id);


--
-- Name: event_type_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY event_type
    ADD CONSTRAINT event_type_pk PRIMARY KEY (event_type_id);


--
-- Name: identifier_type_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY identifier_type
    ADD CONSTRAINT identifier_type_pk PRIMARY KEY (identifier_type_id);


--
-- Name: label_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY label
    ADD CONSTRAINT label_pk PRIMARY KEY (label_id);


--
-- Name: metadata_form_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY metadata_form
    ADD CONSTRAINT metadata_form_pk PRIMARY KEY (metadata_form_id);


--
-- Name: mime_type_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY mime_type
    ADD CONSTRAINT mime_type_pk PRIMARY KEY (mime_type_id);


--
-- Name: movement_type_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY movement_type
    ADD CONSTRAINT movement_type_pk PRIMARY KEY (movement_type_id);


--
-- Name: multiple_type_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY multiple_type
    ADD CONSTRAINT multiple_type_pk PRIMARY KEY (multiple_type_id);


--
-- Name: object_identifier_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY object_identifier
    ADD CONSTRAINT object_identifier_pk PRIMARY KEY (object_identifier_id);


--
-- Name: object_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY object
    ADD CONSTRAINT object_pk PRIMARY KEY (uid);


--
-- Name: object_status_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY object_status
    ADD CONSTRAINT object_status_pk PRIMARY KEY (object_status_id);


--
-- Name: operation_name_version_unique; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY operation
    ADD CONSTRAINT operation_name_version_unique UNIQUE (operation_name, operation_version);


--
-- Name: operation_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY operation
    ADD CONSTRAINT operation_pk PRIMARY KEY (operation_id);


--
-- Name: project_group_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY project_group
    ADD CONSTRAINT project_group_pk PRIMARY KEY (project_id, aclgroup_id);


--
-- Name: project_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_pk PRIMARY KEY (project_id);


--
-- Name: protocol_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY protocol
    ADD CONSTRAINT protocol_pk PRIMARY KEY (protocol_id);


--
-- Name: sample_metadata_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample_metadata
    ADD CONSTRAINT sample_metadata_pk PRIMARY KEY (sample_metadata_id);


--
-- Name: sample_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample
    ADD CONSTRAINT sample_pk PRIMARY KEY (sample_id);


--
-- Name: sample_type_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample_type
    ADD CONSTRAINT sample_type_pk PRIMARY KEY (sample_type_id);


--
-- Name: sampling_place_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sampling_place
    ADD CONSTRAINT sampling_place_pk PRIMARY KEY (sampling_place_id);


--
-- Name: storage_condition_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage_condition
    ADD CONSTRAINT storage_condition_pk PRIMARY KEY (storage_condition_id);


--
-- Name: storage_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage
    ADD CONSTRAINT storage_pk PRIMARY KEY (storage_id);


--
-- Name: storage_reason_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage_reason
    ADD CONSTRAINT storage_reason_pk PRIMARY KEY (storage_reason_id);


--
-- Name: subsample_pk; Type: CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY subsample
    ADD CONSTRAINT subsample_pk PRIMARY KEY (subsample_id);


SET search_path = gacl, pg_catalog;

--
-- Name: log_date_idx; Type: INDEX; Schema: gacl; Owner: collec
--

CREATE INDEX log_date_idx ON log USING btree (log_date);


--
-- Name: log_login_idx; Type: INDEX; Schema: gacl; Owner: collec
--

CREATE INDEX log_login_idx ON log USING btree (login);


--
-- Name: aclaco_aclacl_fk; Type: FK CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclacl
    ADD CONSTRAINT aclaco_aclacl_fk FOREIGN KEY (aclaco_id) REFERENCES aclaco(aclaco_id);


--
-- Name: aclappli_aclaco_fk; Type: FK CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclaco
    ADD CONSTRAINT aclappli_aclaco_fk FOREIGN KEY (aclappli_id) REFERENCES aclappli(aclappli_id);


--
-- Name: aclgroup_aclacl_fk; Type: FK CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclacl
    ADD CONSTRAINT aclgroup_aclacl_fk FOREIGN KEY (aclgroup_id) REFERENCES aclgroup(aclgroup_id);


--
-- Name: aclgroup_aclgroup_fk; Type: FK CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY aclgroup
    ADD CONSTRAINT aclgroup_aclgroup_fk FOREIGN KEY (aclgroup_id_parent) REFERENCES aclgroup(aclgroup_id);


--
-- Name: aclgroup_acllogingroup_fk; Type: FK CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY acllogingroup
    ADD CONSTRAINT aclgroup_acllogingroup_fk FOREIGN KEY (aclgroup_id) REFERENCES aclgroup(aclgroup_id);


--
-- Name: acllogin_acllogingroup_fk; Type: FK CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY acllogingroup
    ADD CONSTRAINT acllogin_acllogingroup_fk FOREIGN KEY (acllogin_id) REFERENCES acllogin(acllogin_id);


--
-- Name: logingestion_login_oldpassword_fk; Type: FK CONSTRAINT; Schema: gacl; Owner: collec
--

ALTER TABLE ONLY login_oldpassword
    ADD CONSTRAINT logingestion_login_oldpassword_fk FOREIGN KEY (id) REFERENCES logingestion(id);


SET search_path = zaalpes, pg_catalog;

--
-- Name: container_family_container_type_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container_type
    ADD CONSTRAINT container_family_container_type_fk FOREIGN KEY (container_family_id) REFERENCES container_family(container_family_id);


--
-- Name: container_storage_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage
    ADD CONSTRAINT container_storage_fk FOREIGN KEY (container_id) REFERENCES container(container_id);


--
-- Name: container_type_container_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container
    ADD CONSTRAINT container_type_container_fk FOREIGN KEY (container_type_id) REFERENCES container_type(container_type_id);


--
-- Name: container_type_sample_type_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample_type
    ADD CONSTRAINT container_type_sample_type_fk FOREIGN KEY (container_type_id) REFERENCES container_type(container_type_id);


--
-- Name: event_type_event_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_type_event_fk FOREIGN KEY (event_type_id) REFERENCES event_type(event_type_id);


--
-- Name: identifier_type_object_identifier_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY object_identifier
    ADD CONSTRAINT identifier_type_object_identifier_fk FOREIGN KEY (identifier_type_id) REFERENCES identifier_type(identifier_type_id);


--
-- Name: label_container_type_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container_type
    ADD CONSTRAINT label_container_type_fk FOREIGN KEY (label_id) REFERENCES label(label_id);


--
-- Name: label_operation_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY label
    ADD CONSTRAINT label_operation_fk FOREIGN KEY (operation_id) REFERENCES operation(operation_id);


--
-- Name: metadata_form_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY operation
    ADD CONSTRAINT metadata_form_fk FOREIGN KEY (metadata_form_id) REFERENCES metadata_form(metadata_form_id);


--
-- Name: mime_type_document_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY document
    ADD CONSTRAINT mime_type_document_fk FOREIGN KEY (mime_type_id) REFERENCES mime_type(mime_type_id);


--
-- Name: movement_type_storage_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage
    ADD CONSTRAINT movement_type_storage_fk FOREIGN KEY (movement_type_id) REFERENCES movement_type(movement_type_id);


--
-- Name: movement_type_subsample_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY subsample
    ADD CONSTRAINT movement_type_subsample_fk FOREIGN KEY (movement_type_id) REFERENCES movement_type(movement_type_id);


--
-- Name: multiple_type_sample_type_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample_type
    ADD CONSTRAINT multiple_type_sample_type_fk FOREIGN KEY (multiple_type_id) REFERENCES multiple_type(multiple_type_id);


--
-- Name: object_booking_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY booking
    ADD CONSTRAINT object_booking_fk FOREIGN KEY (uid) REFERENCES object(uid);


--
-- Name: object_container_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container
    ADD CONSTRAINT object_container_fk FOREIGN KEY (uid) REFERENCES object(uid);


--
-- Name: object_document_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY document
    ADD CONSTRAINT object_document_fk FOREIGN KEY (uid) REFERENCES object(uid);


--
-- Name: object_event_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY event
    ADD CONSTRAINT object_event_fk FOREIGN KEY (uid) REFERENCES object(uid);


--
-- Name: object_object_identifier_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY object_identifier
    ADD CONSTRAINT object_object_identifier_fk FOREIGN KEY (uid) REFERENCES object(uid);


--
-- Name: object_sample_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample
    ADD CONSTRAINT object_sample_fk FOREIGN KEY (uid) REFERENCES object(uid);


--
-- Name: object_status_object_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY object
    ADD CONSTRAINT object_status_object_fk FOREIGN KEY (object_status_id) REFERENCES object_status(object_status_id);


--
-- Name: object_storage_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage
    ADD CONSTRAINT object_storage_fk FOREIGN KEY (uid) REFERENCES object(uid);


--
-- Name: operation_sample_type_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample_type
    ADD CONSTRAINT operation_sample_type_fk FOREIGN KEY (operation_id) REFERENCES operation(operation_id);


--
-- Name: project_project_group_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY project_group
    ADD CONSTRAINT project_project_group_fk FOREIGN KEY (project_id) REFERENCES project(project_id);


--
-- Name: project_sample_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample
    ADD CONSTRAINT project_sample_fk FOREIGN KEY (project_id) REFERENCES project(project_id);


--
-- Name: protocol_operation_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY operation
    ADD CONSTRAINT protocol_operation_fk FOREIGN KEY (protocol_id) REFERENCES protocol(protocol_id);


--
-- Name: sample_metadata_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample
    ADD CONSTRAINT sample_metadata_fk FOREIGN KEY (sample_metadata_id) REFERENCES sample_metadata(sample_metadata_id);


--
-- Name: sample_sample_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample
    ADD CONSTRAINT sample_sample_fk FOREIGN KEY (parent_sample_id) REFERENCES sample(sample_id);


--
-- Name: sample_subsample_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY subsample
    ADD CONSTRAINT sample_subsample_fk FOREIGN KEY (sample_id) REFERENCES sample(sample_id);


--
-- Name: sample_type_sample_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample
    ADD CONSTRAINT sample_type_sample_fk FOREIGN KEY (sample_type_id) REFERENCES sample_type(sample_type_id);


--
-- Name: sampling_place_sample_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY sample
    ADD CONSTRAINT sampling_place_sample_fk FOREIGN KEY (sampling_place_id) REFERENCES sampling_place(sampling_place_id);


--
-- Name: storage_condition_container_type_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY container_type
    ADD CONSTRAINT storage_condition_container_type_fk FOREIGN KEY (storage_condition_id) REFERENCES storage_condition(storage_condition_id);


--
-- Name: storage_reason_storage_fk; Type: FK CONSTRAINT; Schema: zaalpes; Owner: collec
--

ALTER TABLE ONLY storage
    ADD CONSTRAINT storage_reason_storage_fk FOREIGN KEY (storage_reason_id) REFERENCES storage_reason(storage_reason_id);


--
-- de la version 1.06 à 1.08
--
CREATE SEQUENCE "dbversion_dbversion_id_seq";

CREATE TABLE "dbversion" (
                "dbversion_id" INTEGER NOT NULL DEFAULT nextval('"dbversion_dbversion_id_seq"'),
                "dbversion_number" VARCHAR NOT NULL,
                "dbversion_date" TIMESTAMP NOT NULL,
                CONSTRAINT "dbversion_pk" PRIMARY KEY ("dbversion_id")
);
COMMENT ON TABLE "dbversion" IS 'Table des versions de la base de donnees';
COMMENT ON COLUMN "dbversion"."dbversion_number" IS 'Numero de la version';
COMMENT ON COLUMN "dbversion"."dbversion_date" IS 'Date de la version';


ALTER SEQUENCE "dbversion_dbversion_id_seq" OWNED BY "dbversion"."dbversion_id";

insert into dbversion(dbversion_number, dbversion_date) values ('1.0.8', '2017-06-02');


