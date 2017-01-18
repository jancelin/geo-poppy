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
		||' ON CONFLICT ('|| pk ||') DO UPDATE set ('||
		(select string_agg(s.j, ',') from (select json_object_keys((select json_array_elements(sauv) from sauv_data)) j ) s)
		||')=(EXCLUDED.'||
		(select string_agg(s.j, ',EXCLUDED.') from (select json_object_keys((select json_array_elements(sauv) from sauv_data)) j ) s)
		||');'
		--|| ((json_array_elements(sauv)->>pk)::TEXT::NUMERIC ) ||';'--old id pk	

	WHEN action1 = 'DELETE' THEN
		--delete
		'DELETE FROM ' || schema_bd || '.' || tbl
		||' WHERE ' || pk || '=' || 
		((json_array_elements(sauv)->>pk)::TEXT::NUMERIC ) ||';'--old id pk	
	END
  FROM sauv_data
  ORDER BY ts asc
	LOOP
	  EXECUTE query;
	END LOOP;
END;
$$
