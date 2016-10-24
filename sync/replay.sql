DO
LANGUAGE plpgsql
$$
DECLARE
query text;
BEGIN
FOR query IN
  SELECT
	CASE
	WHEN action1 = 'INSERT' THEN
		--insert
		'INSERT INTO ' || schema_bd || '.' || tbl
		|| ' SELECT * FROM json_populate_recordset(null::' ||schema_bd || '.' || tbl || ',''' || sauv || ''')' --json
		||' ON CONFLICT ('|| pk ||') DO UPDATE set '|| pk ||'=DEFAULT;' --new id pk

		
	WHEN action1 = 'UPDATE' THEN
		--update
		'INSERT INTO ' || schema_bd || '.' || tbl
		|| ' SELECT * FROM json_populate_recordset(null::' ||schema_bd || '.' || tbl || ',''' || sauv || ''')'--json
		||' ON CONFLICT ('|| pk ||') DO UPDATE set '|| pk || '='
		|| ((json_array_elements(sauv)->>pk)::TEXT::NUMERIC ) ||';'--old id pk

		
	WHEN action1 = 'DELETE' THEN
		--delete
		'DELETE FROM ' || schema_bd || '.' || tbl
		||' WHERE ' || pk || '=' || 
		((json_array_elements(sauv)->>pk)::TEXT::NUMERIC ) ||';'--old id pk	
	END
  FROM sauv_data
	LOOP
	  EXECUTE query;
	END LOOP;
END;
$$;

