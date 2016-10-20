--SAVE EDITION DATA FOR REPLAY ON A REPLICATED DATABASE
--Maintainer: Julien Ancelin
-----------------------------------------------------
--Create audit table to store all modifications of database
CREATE TABLE sauv_data
(
  integrateur character varying,
  ts timestamp with time zone,
  schema_bd character varying,
  tbl character varying,
  action1 character varying,
  sauv json,
  pk character varying
);
--for delete table: DROP TABLE sauv_data
------------------------------------------------------
-- Create function: sauv_data() to store on sauv_data table all db tables modifications
CREATE OR REPLACE FUNCTION sauv_data() RETURNS TRIGGER AS $sauv$
BEGIN	
	IF (TG_OP = 'DELETE') THEN
        INSERT INTO sauv_data SELECT session_user, now(), TG_TABLE_SCHEMA, TG_TABLE_NAME ,'DELETE',
	json_build_array(OLD.*),(select kc.column_name from information_schema.key_column_usage kc where kc.table_name=TG_TABLE_NAME);
        RETURN OLD;
    	ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO sauv_data SELECT session_user, now(), TG_TABLE_SCHEMA, TG_TABLE_NAME ,'UPDATE',
	json_build_array(NEW.*),(select kc.column_name from information_schema.key_column_usage kc where kc.table_name=TG_TABLE_NAME);
        RETURN NEW;
    	ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO sauv_data SELECT session_user, now(), TG_TABLE_SCHEMA, TG_TABLE_NAME ,'INSERT',
	json_build_array(NEW.*),(select kc.column_name from information_schema.key_column_usage kc where kc.table_name=TG_TABLE_NAME);
        RETURN NEW;
    	END IF;
    	RETURN NULL; -- le résultat est ignoré car il s'agit d'un trigger AFTER
END;
$sauv$ language plpgsql;
-- For delete: DROP FUNCTION sauv_data();
----------------------------------------------------------
--create trigger sauv (Function: sauv_data()) for all tables in the database, less views and table sauv_data
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
	    || ' FOR EACH ROW EXECUTE PROCEDURE sauv_data();'AS trigger_creation_query
	    --'DROP TRIGGER sauv ON ' 
	    --|| tbl_name.tab_name
	    --||';' AS trigger_creation_query
	FROM (
	    SELECT
		quote_ident(table_schema) || '.' || quote_ident(table_name) as tab_name
	    FROM
		information_schema.tables
	    WHERE
		table_schema NOT IN ('pg_catalog', 'information_schema')
		AND table_schema NOT LIKE 'pg_toast%'
		AND table_name NOT IN (SELECT viewname FROM pg_views WHERE schemaname NOT IN('information_schema','pg_catalog'))
		AND table_name != 'sauv_data'
	) AS tbl_name
	LOOP
	  EXECUTE query;
	END LOOP;
END;
$$;
--Now, when you edit a table, modifications are store in sauv_data table and you can replay on another db with replay_data.sql
