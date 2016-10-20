DO
LANGUAGE plpgsql
$$
DECLARE
replay text;
BEGIN
  FOR replay IN

	IF ((SELECT action1 FROM sauv_data) = 'INSERT') THEN
		--insert
		SELECT 'INSERT INTO ' || schema_bd || '.' || tbl
		|| ' SELECT * FROM json_populate_recordset(null::' ||schema_bd || '.' || tbl || ',''' || sauv || ''')' --tableau json
		||' ON CONFLICT ('|| pk ||') DO UPDATE set '|| pk ||'=DEFAULT;'
		FROM sauv_data

	ELSIF ((SELECT action1 FROM sauv_data) = 'UPDATE') THEN
		--update
		SELECT 'INSERT INTO ' || schema_bd || '.' || tbl
		|| ' SELECT * FROM json_populate_recordset(null::' ||schema_bd || '.' || tbl || ',''' || sauv || ''')' --tableau json
		||' ON CONFLICT ('|| pk ||') DO UPDATE set '|| pk || '='
		|| ((json_array_elements(sauv)->>pk)::TEXT::NUMERIC ) ||';'--récupère la valeur id pk
		FROM sauv_data
	ELSIF ((SELECT action1 FROM sauv_data) = 'DELETE') THEN
		--delete
		SELECT 'DELETE FROM ' || schema_bd || '.' || tbl
		||' WHERE ' || pk || '=' || 
		((json_array_elements(sauv)->>pk)::TEXT::NUMERIC ) ||';'--récupère la valeur id pk
		FROM sauv_data
	END IF
	LOOP
	  EXECUTE replay;
	END LOOP;
END;
$$;
