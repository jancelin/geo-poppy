--requete de base pour récupérer un record set de la table sauv_data (attention une seulle ligne dans la table)
SELECT * from json_populate_recordset(null::inventaire_gps,(select sauv from sauv_data))

--affiche un tableau avec juste les champs
SELECT * from json_populate_recordset(null::inventaire_gps,(select sauv from sauv_data)) LIMIT 0;

-- test upsert : working
INSERT INTO public.inventaire_gps SELECT * FROM json_populate_recordset(null::public.inventaire_gps,'[{"ig_id":7076,"ig_date":"2016-04-26","ig_buffer":3000,"ig_cla_id":57,"ig_id_plante":61,"geom":"01010000206A080000DCF992BA0BF21A41F681E82974195941","ig_terrain_id":3,"gid":null,"ope_id":27}]') ON CONFLICT (ig_id)
 DO UPDATE set (ig_id,ig_date,ig_buffer,ig_cla_id,ig_id_plante,geom,ig_terrain_id,gid,ope_id) = (EXCLUDED.ig_id, EXCLUDED.ig_date, EXCLUDED.ig_buffer, EXCLUDED.ig_cla_id, EXCLUDED.ig_id_plante, EXCLUDED.geom, EXCLUDED.ig_terrain_id, EXCLUDED.gid, EXCLUDED.ope_id );

--extract array to json element
 select json_array_elements(sauv) from sauv_data

-- liste des champs dans un tableau
select json_object_keys('{"ig_id":7076,"ig_date":"2016-04-26","ig_buffer":3000,"ig_cla_id":57,"ig_id_plante":61,"geom":"01010000206A080000DCF992BA0BF21A41F681E82974195941","ig_terrain_id":3,"gid":null,"ope_id":27}')
-- liste des champs dans un tableau
select json_object_keys((select json_array_elements(sauv) from sauv_data)) j

----------------------------------------------------------------------------------------------------------------------
-----liste des champs sous la forme d'une ligne séparé par des virgules.
select string_agg(s.j, ' , ') from (select json_object_keys((select json_array_elements(sauv) from sauv_data)) j ) s
-----------------------------------------------------------------------------------------------------------------------

--ecriture pour integration script replay.sql
SELECT
CASE
WHEN action1 = 'UPDATE' THEN
'(' ||
(select string_agg(s.j, ',') from (select json_object_keys((select json_array_elements(sauv) from sauv_data)) j ) s)
||')=(EXCLUDED.'||
(select string_agg(s.j, ',EXCLUDED.') from (select json_object_keys((select json_array_elements(sauv) from sauv_data)) j ) s)
||');'
END
  FROM sauv_data
ORDER BY ts asc

--integration dans replay
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



--test replay sur une ligne: working
INSERT INTO public.inventaire_gps SELECT * FROM json_populate_recordset(null::public.inventaire_gps,'[{"ig_id":7076,"ig_date":"2016-04-26","ig_buffer":3000,"ig_cla_id":57,"ig_id_plante":61,"geom":"01010000206A080000DCF992BA0BF21A41F681E82974195941","ig_terrain_id":3,"gid":null,"ope_id":27}]') ON CONFLICT (ig_id) DO UPDATE set (ig_id,ig_date,ig_buffer,ig_cla_id,ig_id_plante,geom,ig_terrain_id,gid,ope_id)=(EXCLUDED.ig_id,EXCLUDED.ig_date,EXCLUDED.ig_buffer,EXCLUDED.ig_cla_id,EXCLUDED.ig_id_plante,EXCLUDED.geom,EXCLUDED.ig_terrain_id,EXCLUDED.gid,EXCLUDED.ope_id);
