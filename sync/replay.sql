DO
LANGUAGE plpgsql
$$
DECLARE
query text;
BEGIN
FOR query IN
  SELECT distinct 			-- for grouping
	CASE
	WHEN action1 = 'INSERT' THEN 	-- Writes the data insert procedure 
		'INSERT INTO '||s.schema_bd||'.'||s.tbl
		||' SELECT * FROM json_populate_recordset(null::'||s.schema_bd ||'.'||s.tbl||','''||s.sauv||''')'	--json
		||' ON CONFLICT ('||s.pk||') DO UPDATE set '||s.pk||'=DEFAULT;' --new id pk

	WHEN action1 = 'UPDATE' THEN --Writes the data update procedure
		'INSERT INTO '||s.schema_bd||'.'||s.tbl
		||' SELECT * FROM json_populate_recordset(null::'||schema_bd||'.'||tbl||','''||sauv||''')'--json
		||' ON CONFLICT ('||s.pk||') DO UPDATE set ('||f.f||') = (EXCLUDED.'||f.g||');' -- list of fields	

	WHEN action1 = 'DELETE' THEN --Writes the data delete procedure
		'DELETE FROM ' || s.schema_bd || '.' || s.tbl
		||' WHERE ' || s.pk || '=' || 
		((json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC ) ||';'--old id pk	
	END
  FROM 	sauv_data s, --Call the sauv_data table
	(select e.ts, string_agg(e.json, ',') f, string_agg(e.json, ',EXCLUDED.') g
	from (select ts, json_object_keys(d.json) json
	      from 
	      (select ts, json_array_elements(sauv) json 
	       from sauv_data) d 
	     ) e
	group by e.ts) f -- create a list of fields

	LOOP
	  EXECUTE query;
	END LOOP;
END;
$$
