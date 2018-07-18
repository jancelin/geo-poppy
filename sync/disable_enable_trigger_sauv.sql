--For disable trigger sauv before  replay() function
--select * from sync.disable_sauv_trigger();
CREATE OR REPLACE FUNCTION sync.disable_sauv_trigger(OUT result text) AS $$
DECLARE
query text;
BEGIN
FOR query IN
SELECT
	    'ALTER TABLE  ' 
	    || tbl_name.tab_name
	    || ' DISABLE TRIGGER sauv;'AS trigger_creation_query
	FROM (
	    SELECT
		quote_ident(table_schema) || '.' || quote_ident(table_name) as tab_name
	    FROM
		information_schema.tables
	    WHERE
		table_schema NOT IN ('pg_catalog', 'information_schema', 'sync', 'topology')
		AND table_schema NOT LIKE 'pg_toast%'
		AND table_name NOT IN (SELECT viewname FROM pg_views WHERE schemaname NOT IN('information_schema','pg_catalog'))
) AS tbl_name
	LOOP
	  EXECUTE query;
	END LOOP;
RAISE NOTICE 'DISABLE: %', result;
END;
$$
LANGUAGE plpgsql VOLATILE;

--For enable trigger sauv before  replay() function
--SELECT * FROM sync.enable_sauv_trigger();
CREATE OR REPLACE FUNCTION sync.enable_sauv_trigger(OUT result text) AS $$
DECLARE
query text;
BEGIN
FOR query IN
SELECT
	    'ALTER TABLE  ' 
	    || tbl_name.tab_name
	    || ' ENABLE TRIGGER sauv;'AS trigger_creation_query
	FROM (
	    SELECT
		quote_ident(table_schema) || '.' || quote_ident(table_name) as tab_name
	    FROM
		information_schema.tables
	    WHERE
		table_schema NOT IN ('pg_catalog', 'information_schema', 'sync', 'topology')
		AND table_schema NOT LIKE 'pg_toast%'
		AND table_name NOT IN (SELECT viewname FROM pg_views WHERE schemaname NOT IN('information_schema','pg_catalog'))
) AS tbl_name
	LOOP
	  EXECUTE query;
	END LOOP;
RAISE NOTICE 'DISABLE: %', result;
END;
$$
LANGUAGE plpgsql VOLATILE;
