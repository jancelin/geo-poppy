------------------------------------------------------
--SAVE EDITION DATA FOR REPLAY ON A REPLICATED DATABASE
--Maintainer: Julien Ancelin
--Diffusé sous licence open-source AGPL
-----------------------------------------------------
--Notice:
--INSERT INTO sync.login (nom,ip,port,utilisateur,mdp,dbname) values ('geopoppy1','0.0.0.0',5434,'geomatik','geomatik','framboise_entomo');
--insert data on table
--INSERT INTO sync.synchro (id_login) values (1);

---Creation extension dblink
CREATE  EXTENSION IF NOT EXISTS dblink;

-----Création schema sync-----
/*
Ce schema contiendra une table et des vues pour la gestion votre synchronisation
*/
--DROP SCHEMA IF EXISTS sync CASCADE;
CREATE SCHEMA IF NOT EXISTS sync AUTHORIZATION postgres;
COMMENT ON SCHEMA sync
  IS 'sync schema for multi bases synchro';

--Create audit table to store all modifications of database
CREATE TABLE sync.sauv_data
(
  integrateur character varying,
  ts timestamp with time zone,
  schema_bd character varying,
  tbl character varying,
  action1 character varying,
  sauv json,
  pk character varying,
  fk json,
  sync integer DEFAULT 0,
  sync_ts timestamp with time zone
);
--for delete table: DROP TABLE sauv_data


--create login table to store remote server dblink parameter
--CREATE EXTENSION chkpass; --http://docs.postgresql.fr/9.5/chkpass.html

--dblink config
CREATE TABLE sync.login
(
  id serial,
  nom character varying,
  ip character varying,
  port integer,
  utilisateur character varying,
  mdp character varying,
  dbname character varying,
  CONSTRAINT pk_login PRIMARY KEY (id)
);
--list of synchro remote server + add a ligne and do a synchro (with trigger sync.synchronis())
CREATE TABLE sync.synchro
(
  id serial,
  ts timestamp with time zone  DEFAULT now(), --TIME OF SYNCHRO
  id_login integer, --get dblink remote server param
  rpi2server character varying,
  CONSTRAINT pk_synchro PRIMARY KEY (id)
);

------------------------------------------------------
-- Create function: sauv_data() to store on sauv_data table all db tables modifications
CREATE OR REPLACE FUNCTION sync.sauv_data() RETURNS TRIGGER AS $sauv$
BEGIN	
	IF (TG_OP = 'DELETE') THEN
        INSERT INTO sync.sauv_data SELECT session_user, now(), TG_TABLE_SCHEMA, TG_TABLE_NAME ,'DELETE',
	json_build_array(OLD.*),(select kc.column_name from information_schema.table_constraints tc,information_schema.key_column_usage kc
				 where tc.table_name= TG_TABLE_NAME and
				 tc.constraint_type = 'PRIMARY KEY' and kc.table_name = tc.table_name 
				 and kc.table_schema = tc.table_schema and kc.constraint_name = tc.constraint_name order by 1), --search Pk
	json_agg(fk.n) from (select kc.column_name n from information_schema.table_constraints tc,information_schema.key_column_usage kc
				where tc.table_name= TG_TABLE_NAME and
				tc.constraint_type = 'FOREIGN KEY' and kc.table_name = tc.table_name 
				and kc.table_schema = tc.table_schema and kc.constraint_name = tc.constraint_name group by kc.column_name)fk; --search Fk h Fk
        RETURN OLD;
    	ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO sync.sauv_data SELECT session_user, now(), TG_TABLE_SCHEMA, TG_TABLE_NAME ,'UPDATE',
	json_build_array(NEW.*),(select kc.column_name from information_schema.table_constraints tc,information_schema.key_column_usage kc
				 where tc.table_name= TG_TABLE_NAME and
				 tc.constraint_type = 'PRIMARY KEY' and kc.table_name = tc.table_name 
				 and kc.table_schema = tc.table_schema and kc.constraint_name = tc.constraint_name order by 1),--search Pk
	json_agg(fk.n) from (select kc.column_name n from information_schema.table_constraints tc,information_schema.key_column_usage kc
				where tc.table_name= TG_TABLE_NAME and
				tc.constraint_type = 'FOREIGN KEY' and kc.table_name = tc.table_name 
				and kc.table_schema = tc.table_schema and kc.constraint_name = tc.constraint_name group by kc.column_name)fk; --search Fk 
        RETURN NEW;
    	ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO sync.sauv_data SELECT session_user, now(), TG_TABLE_SCHEMA, TG_TABLE_NAME ,'INSERT',
	json_build_array(NEW.*),(select kc.column_name from information_schema.table_constraints tc,information_schema.key_column_usage kc
				 where tc.table_name= TG_TABLE_NAME and
				 tc.constraint_type = 'PRIMARY KEY' and kc.table_name = tc.table_name 
				 and kc.table_schema = tc.table_schema and kc.constraint_name = tc.constraint_name order by 1),--search Pk
	json_agg(fk.n) from (select kc.column_name n from information_schema.table_constraints tc,information_schema.key_column_usage kc
				where tc.table_name= TG_TABLE_NAME and
				tc.constraint_type = 'FOREIGN KEY' and kc.table_name = tc.table_name 
				and kc.table_schema = tc.table_schema and kc.constraint_name = tc.constraint_name group by kc.column_name)fk; --search Fk 
				 
        RETURN NEW;
    	END IF;
    	RETURN NULL; -- le résultat est ignoré car il s'agit d'un trigger AFTER
END;
$sauv$ language plpgsql;
-- For delete: DROP FUNCTION sauv_data();
----------------------------------------------------------
--create trigger sauv (Function: sauv_data()) for all tables in the database, less views and table sauv_data
--Now, when you edit a table, modifications are store in sauv_data table and you can replay on another db with replay_data.sql
DO
LANGUAGE plpgsql
$$
DECLARE
query text;
BEGIN
  FOR query IN
	SELECT
	    'CREATE TRIGGER sauv AFTER INSERT OR DELETE OR UPDATE ON ' 
	    || tbl_name.tab_name
	    || ' FOR EACH ROW EXECUTE PROCEDURE sync.sauv_data();'AS trigger_creation_query
	    --'DROP TRIGGER sauv ON ' 
	    --|| tbl_name.tab_name
	    --||';' AS trigger_creation_query
	FROM (
	    SELECT
		quote_ident(table_schema) || '.' || quote_ident(table_name) as tab_name
	    FROM
		information_schema.tables
	    WHERE
		table_schema NOT IN ('pg_catalog', 'information_schema', 'sync', 'topology')
		AND table_schema NOT LIKE 'pg_toast%'
		AND table_name NOT IN (SELECT viewname FROM pg_views WHERE schemaname NOT IN('information_schema','pg_catalog'))
		--AND table_name != 'sauv_data'
	) AS tbl_name
	LOOP
	  EXECUTE query;
	END LOOP;
END;
$$;

--Function to synchronize rpi db to server db
--exemple: select sync.rpi2server('nom_connexion','ip','host','port','user','password','database');

DROP FUNCTION IF EXISTS sync.rpi2server();
CREATE OR REPLACE FUNCTION sync.rpi2server(n text, h text, p integer, u text, pw text, db text, OUT count_data_in int, OUT count_data_out int) AS
$BODY$
DECLARE
query text;
ii int;
BEGIN
	--connect dblink remote server and verify if same connection alive
	IF dblink_get_connections() is NULL
	THEN
		PERFORM dblink_connect(''||n||'','host='||h||' port='||p||' user='||u||' password='||pw||' dbname='||db||'') ;
		raise NOTICE 'connection: %',''||n||'';
	ELSE
		PERFORM dblink_disconnect(''||n||'');
		PERFORM dblink_connect(''||n||'','host='||h||' port='||p||' user='||u||' password='||pw||' dbname='||db||'');
		raise NOTICE 'connection: %',''||n||'';
	END IF;
	--get number of rows to sync
	SELECT count(ts) from sync.sauv_data WHERE sauv_data.sync = 0 INTO count_data_in;
	RAISE NOTICE 'count_data_in : %', count_data_in;
	--get data and execute INSERT INTO in remote server
	--update sync column in sauv_data to 1 (penser à rajouter le schema sync)
	FOR query IN
		SELECT 'SELECT dblink_exec('''||n||''',''INSERT INTO sync.sauv_data values 
		('''''||n||''''','''''||ts||''''','''''||schema_bd||''''','''''||tbl||''''','''''||action1||''''','''''||sauv||''''','''''|| pk ||''''')'');
		UPDATE sync.sauv_data SET sync = 1, sync_ts = now();'
		FROM sync.sauv_data
		WHERE sync.sauv_data.sync = 0
	LOOP
		EXECUTE query;
		RAISE NOTICE 'ACTION:  %',query;	--messages logs
	END LOOP;
	--get number of rows sync
	GET DIAGNOSTICS ii = ROW_COUNT;
	SELECT ii INTO count_data_out;
	RAISE NOTICE 'count_data_out : %', count_data_out;
	--disconnect dblink remote server
	PERFORM dblink_disconnect(''||n||'');
	raise NOTICE 'déconnection: %',''||n||'';
END;
$BODY$
LANGUAGE plpgsql VOLATILE;
--COST 100 
--ROWS 1000;
ALTER FUNCTION sync.rpi2server(text, text, integer, text, text, text)
OWNER TO docker;


--FUNCTION synchronis: lors de l'ajout d'une ligne (choix de la connexion dblink), la synchronistaion des données se lance vers le central,
-- Un ts est intégré ensuite dans la table synchro pour pister la synchro
DROP FUNCTION IF EXISTS sync.synchronis() CASCADE;
CREATE OR REPLACE FUNCTION sync.synchronis() RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP = 'INSERT') THEN
		PERFORM sync.rpi2server(l.nom , l.ip,l.port,l.utilisateur,l.mdp,l.dbname)
		FROM (SELECT * FROM sync.login where id = NEW.id_login ) as l; 
		UPDATE sync.synchro SET id = NEW.id, ts = now(), id_login =NEW.id_login, rpi2server= 'OK'  where id = NEW.id; 
		RETURN NEW;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER synchronis_trig
AFTER INSERT ON sync.synchro
FOR EACH ROW EXECUTE PROCEDURE sync.synchronis();

ALTER FUNCTION sync.synchronis()
  OWNER TO docker;

