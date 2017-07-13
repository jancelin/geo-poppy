

SELECT dblink_connect('geo1','host=0.0.0.0 port=5434
				 user=geomatik
				 password=geomatik
				 dbname=framboise_entomo');

DO
LANGUAGE plpgsql
$$
DECLARE
query text;
BEGIN
FOR query IN
			SELECT 'SELECT dblink_exec(''geo1'',''INSERT INTO sync.sauv_data values ('''
			|| '''moi_a'''||''','''''||ts||''''','''''||schema_bd||''''','''''||tbl||''''','''''||action1||''''','''''||sauv||''''','''''|| pk ||''''')'');'
			from sauv_data
LOOP
	  EXECUTE query;
	END LOOP;
END;
$$;

SELECT dblink_disconnect('geo1');



--SELECT dblink_exec('geo1','INSERT INTO sync.sauv_data  values (''moi_4'',''2017-04-05 06:50:23.989936+00'',''public'',''operateur_utilisateur'',''UPDATE'',''[{"ope_id":1,"ope_initiales":"5401","ope_nom":null,"ope_prenom":null,"ope_fonction":null,"ope_annee":null,"ope_nom_pre":null}]'',''ope_id'')');


--SELECT dblink_is_busy('geo1'); --fin d'exécution de la requête se vérifie



--SELECT * from dblink_get_result('geo1'); --résultats sont finalement récupérés marche pas
