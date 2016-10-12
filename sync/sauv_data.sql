CREATE TABLE sauv_data
(
  integrateur character varying,
  ts timestamp with time zone,
  schema_bd character varying,
  tbl character varying,
  actio character varying,
  sauv json
)

-- Function: sauv_data()

-- DROP FUNCTION sauv_data();

CREATE OR REPLACE FUNCTION sauv_data() RETURNS TRIGGER AS $sauv$
BEGIN	

	IF (TG_OP = 'DELETE') THEN
        INSERT INTO sauv_data SELECT session_user, now(), TG_TABLE_SCHEMA, TG_TABLE_NAME ,TG_OP, json_build_array(OLD.*);
        RETURN OLD;
    	ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO sauv_data SELECT session_user, now(), TG_TABLE_SCHEMA, TG_TABLE_NAME ,TG_OP, json_build_array(OLD.*);
        RETURN NEW;
    	ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO sauv_data SELECT session_user, now(), TG_TABLE_SCHEMA, TG_TABLE_NAME ,TG_OP, json_build_array(NEW.*);
        RETURN NEW;
    	END IF;
    	RETURN NULL; -- le résultat est ignoré car il s'agit d'un trigger AFTER
END;
$sauv$ language plpgsql;

CREATE TRIGGER sauv
  AFTER INSERT OR DELETE OR UPDATE ON parcelle
  FOR EACH ROW  
  EXECUTE PROCEDURE sauv_data(); 
