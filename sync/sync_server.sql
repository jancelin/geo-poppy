/*
GéoPoppy-SYNC
Script de création des fonctions de synchronisation serveur
Sync est un module développé en SQL au dessus de Postgres 9.5 minimum pour faciliter la synchronisation de bases de données terrains (multiples) avec une base serveur.
Mise en place : 
  * se connecter à sa base centrale
  * ouvrir une console SQL
  * copier coller ce script dans la console
  * Executer la requête

Source: https://github.com/jancelin/geo-poppy

Logiciel diffusé sous licence open-source AGPL

*/
-------------------------------------------------------
-----Création schema sync-----
/*
Ce schema contiendra une table et des vues pour la gestion votre synchronisation
*/
DROP SCHEMA IF EXISTS sync CASCADE;
CREATE SCHEMA IF NOT EXISTS sync AUTHORIZATION postgres;
COMMENT ON SCHEMA sync
  IS 'sync schema for multi bases synchro';

-----Création table de collecte des données terrain-----
/*
Table de centralisation des données terrain à synchroniser
*/

CREATE TABLE sync.sauv_data
(
  integrateur character varying,  --compte user
  ts timestamp with time zone,    --timestamp de la donnée (servira de pk de la table)
  schema_bd character varying,    --nom du schema de la donnée
  tbl character varying,          --table de la donnée
  action1 character varying,      --action sur la donnée: INSERT UPDATE ou DELETE
  sauv json,                      --chaine de donnée en json (champ:valeur,...)
  pk character varying,           --clef primaire de la table
  fk json,                        --clefs étrangères
  replay boolean DEFAULT false,   --La donnée a t'elle été rejoué dans la base
  no_replay integer               --1= donnée multi-edité fonction: sync.no_replay() , 2= donnée exclus conflit d'edition: sync.resolve_conflict()
);

--list of replay in db + add a ligne and do a replay data (with trigger sync.doreplay())
CREATE TABLE sync.doreplay
(
  id serial,
  ts timestamp with time zone DEFAULT now(), --TIME OF SYNCHRO
  checking character varying, --working?
  integrateur character varying,  --compte user
  CONSTRAINT pk_doreplay PRIMARY KEY (id)
);

-----Création de la vue ts_excluded-----
/*
La Vue des timestamp des entités multi-éditées qui ne devrons pas pas être rejouer dans la base centrale
!!!Cette vue est utilisée dans toutes les autres vues et fonctions du module sync: replay no_replay et conflict!!!
*/

CREATE OR REPLACE VIEW sync.ts_excluded AS
SELECT ts
FROM 
( --sous-select : toutes les données + pk value
	SELECT *,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id
	FROM sync.sauv_data s
	WHERE replay = FALSE
) al,
(--trouve les données modifiées plusieurs fois
	SELECT distinct  pk, (json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id, integrateur i,COUNT(integrateur)
	FROM sync.sauv_data s
	WHERE replay = FALSE
	GROUP BY pk, id, i 
	HAVING COUNT(integrateur)>1 --filtre nombre d'édition par integrateur
) trouv
WHERE trouv.pk = al.pk AND trouv.id = al.id AND trouv.i = al.integrateur AND al.ts NOT IN 
	(SELECT d.ts FROM
	    ( --trouve le dernier ts par pk/id
		SELECT pk,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id,  max(ts) ts, integrateur
		FROM sync.sauv_data s
		WHERE replay = FALSE
		GROUP BY id,pk,integrateur
	    ) d
	);
	
-----Création vue no_replay-----
/*
Vue des les lignes qui ne seront pas jouées: édition multiple d'une même entité.
*/

CREATE OR REPLACE VIEW sync.no_replay AS
SELECT * 
FROM sync.sauv_data 
WHERE replay = 'FALSE'
AND ts IN (--timestamp exlus
		SELECT *
		FROM sync.ts_excluded);

-----Création vue conflict-----
/*
Recherche et édite les données en conflit
!!!!!!Pensez à lancer la function no_replay() avant!!!!!!!!
Filtres:
* selection de la dernière entrée utilisateur si plusieurs modification  de la meme donnée.
* Retrouve une donnée qui a été modifié par plusieurs utilisateurs
Edition: 
*Ouvrir la table et cocher les données à supprimer dans la première colonne "bool".
*/

CREATE OR REPLACE VIEW sync.conflict AS
SELECT  boolean 'f' supprime_data,tbl,pk,(json_array_elements(sauv)->>pk)::TEXT::NUMERIC id,integrateur,ts,schema_bd,action1,sauv,replay,no_replay
FROM ( --liste toutes les données sans les multi edition utilisateur.
	SELECT (json_array_elements(sauv)->>pk)::TEXT::NUMERIC id,* 
	FROM sync.sauv_data
	WHERE ts NOT IN ( --timestamp exclus
			SELECT ts
			FROM sync.ts_excluded)
) al
WHERE replay = 'FALSE'
AND al.id IN (--liste les single id pouvant être inséré tout de suite, si changement du "having" possibilité de trouver les doublons d'edition.
		SELECT distinct (json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id
		FROM sync.sauv_data s
		WHERE ts NOT IN ( --timestamp exlus
				SELECT *
				FROM sync.ts_excluded)
			 AND replay = FALSE
		GROUP BY pk, id
		HAVING count(pk)>1) -- =1 donne les entrées uniques & >1 donne les doublons rentrant en conflit d'edition	
ORDER BY tbl, (json_array_elements(sauv)->>pk)::TEXT::NUMERIC ASC;

--fonction d'edition de la vue conflict pour éliminer les conflits
DROP FUNCTION IF EXISTS sync.resolve_conflict() CASCADE;
CREATE OR REPLACE FUNCTION sync.resolve_conflict() RETURNS TRIGGER AS $$
BEGIN

IF (TG_OP = 'UPDATE') THEN
UPDATE sync.sauv_data SET
integrateur = OLD.integrateur,
ts = NEW.ts,
schema_bd = OLD.schema_bd,
tbl = OLD.tbl,
action1 = OLD.action1,
sauv = OLD.sauv,
pk = OLD.pk,
--fk = OLD.fk,
replay = TRUE,
no_replay = 2 --2 est l'identifiant des conflits supprimés
where ts = OLD.ts;
RETURN NEW;

END IF;
       RETURN NEW;
	
	END;
	$$ LANGUAGE plpgsql;

CREATE TRIGGER update_conflict_sauv_data
INSTEAD OF UPDATE ON sync.conflict
FOR EACH ROW EXECUTE PROCEDURE sync.resolve_conflict();

-----Création vue replay-----
/*
Vue de toutes les données sans conflit à monter dans la base centrale
Filtres:
		* selection de la dernière entrée utilisateur si plusieurs modification  de la même donnée.
		* si une donnée à été modifié par plusieurs utilisateur elle est exclue. Jouer conflict.sql pour les trouver et les résoudre.
*/

CREATE OR REPLACE VIEW sync.replay AS
SELECT integrateur,ts,schema_bd,tbl,action1,sauv,pk,replay
FROM ( --liste toutes les données sans les multi edition utilisateur.
	SELECT (json_array_elements(sauv)->>pk)::TEXT::NUMERIC id,* 
	FROM sync.sauv_data 
	WHERE ts NOT IN ( --timestamp exlus
			SELECT ts
			FROM sync.ts_excluded)
) al
WHERE replay = 'FALSE'
AND al.id IN (--liste les single id pouvant être inséré tout de suite, si changement du "having" possibilité de trouver les doublons d'edition.
		SELECT distinct (json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id
		FROM sync.sauv_data s
		WHERE ts NOT IN (--timestamp exlus
				SELECT *
				FROM sync.ts_excluded)
			 AND replay = FALSE
		GROUP BY pk, id
		HAVING count(pk)=1) -- =1 donne les entrées uniques & >1 donne les doublons rentrant en conflit d'edition
ORDER BY ts ASC;

-----Création Fonction no_replay(); -----
/*
Fonction d'exclusion des données multi editées par l'intégrateur durant une mêmeme session d'edition
La vue no_replay doit être créée avant.
Execution de la fonction : select sync.no_replay();
*/

DROP FUNCTION IF EXISTS sync.no_replay();
CREATE OR REPLACE FUNCTION sync.no_replay() RETURNS table(f1 boolean) AS
$BODY$
DECLARE
req text;
BEGIN
FOR req IN
	SELECT distinct
	'UPDATE sync.sauv_data SET replay = TRUE WHERE ts = '''||n.ts||''';' 	--modifie replay en TRUE
	|| 'UPDATE sync.sauv_data SET no_replay = 1 WHERE ts = '''||n.ts||''';'	--modifie valeur no_replay en 1 : données multi édité
	FROM
	sync.no_replay n
  LOOP
	  EXECUTE req;								--looped query INSERT UPDATE DELETE
	  raise INFO 'ACTION:  %',req;						--messages logs
	  return next;								--number of lines
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
  COST 100
ROWS 1000;

-----Création Fonction replay(); -----
/*
La fonction replay() lance la mise à jour des données terrain dans la base centrale.
Execution de la fonction : select sync.replay();
*/

DROP FUNCTION IF EXISTS sync.replay();
CREATE OR REPLACE FUNCTION sync.replay(users varchar) RETURNS table(f1 boolean) AS
$BODY$
DECLARE
req text;
BEGIN
FOR req IN
SELECT x.q FROM (												--Keep only the replay req
  SELECT distinct												--for grouping
	CASE													--Choice of action
	WHEN action1 = 'INSERT' THEN 										--Writes the data insert procedure 
		'INSERT INTO '||rp.schema_bd||'.'||rp.tbl
		||' SELECT * FROM json_populate_recordset(null::'||rp.schema_bd ||'.'||rp.tbl||','''||rp.sauv||''')'    --json
		||' ON CONFLICT ('||rp.pk||') DO UPDATE set '||rp.pk||'=DEFAULT;'					--new id pk
		||' UPDATE sync.sauv_data SET replay = TRUE WHERE ts = '''||rp.ts||''';'				--check TRUE on sync.sauv_data when replay

	WHEN action1 = 'UPDATE' THEN 										--Writes the data update procedure
		'INSERT INTO '||rp.schema_bd||'.'||rp.tbl
		||' SELECT * FROM json_populate_recordset(null::'||schema_bd||'.'||tbl||','''||sauv||''')'	--json
		||' ON CONFLICT ('||rp.pk||') DO UPDATE set ('||f.f||') = (EXCLUDED.'||f.g||');'	 	-- list of fields
		||' UPDATE sync.sauv_data SET replay = TRUE WHERE ts = '''||rp.ts||''';'			--check TRUE on sync.sauv_data when replay

	WHEN action1 = 'DELETE' THEN 										--Writes the data delete procedure
		'DELETE FROM '||rp.schema_bd||'.'||rp.tbl
		||' WHERE '||rp.pk||'='||i.i||';'								--old id pk
		||' UPDATE sync.sauv_data SET replay = TRUE WHERE ts = '''||rp.ts||''';'			--check TRUE on sync.sauv_data when replay
	END q
	, rp.ts													--rp.ts for order by timestamp
  FROM 	sync.replay  rp, 										 	--CALL the replay view
	(SELECT  (json_array_elements(replay.sauv)->> replay.pk)::NUMERIC i from sync.replay) as i,             --entity ID
	(select e.ts, string_agg(e.json, ',') f,								--list of fields for upsert update
	 string_agg(e.json,',EXCLUDED.') g 									--list of fileds for upsert update + EXCLUDED.
	 from (select ts, json_object_keys(d.json) json								--list fields on json
	      from 
	      (select ts, json_array_elements(sauv) json 							--read ts & json array
	       from sync.replay) d 
	     ) e
	 group by e.ts) f 											--CALL list of fields
  WHERE rp.ts = f.ts AND rp.replay = FALSE AND integrateur = users
  ORDER BY rp.ts ASC
) x
	LOOP
	  EXECUTE req;												--looped query INSERT UPDATE DELETE
	  raise INFO 'ACTION:  %',req;										--messages logs
	  return next;												--number of lines
	END LOOP;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
  
----------------------------------------------------------------------------
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
----------------------------------------------------------------------------

---lancement de l'injection de données sur le central après un insert dans la table sync.doreplay
DROP FUNCTION IF EXISTS sync.sync();
CREATE OR REPLACE FUNCTION sync.sync() RETURNS TRIGGER AS 
$BODY$
BEGIN	
IF (TG_OP = 'INSERT') THEN
        --PERFORM sync.disable_sauv_trigger();
	PERFORM sync.no_replay();
        PERFORM sync.replay(NEW.integrateur);
	UPDATE sync.doreplay SET id =NEW.id, ts=NEW.ts, integrateur=NEW.integrateur, checking = 'OK' WHERE id=NEW.id ;
        --PERFORM sync.enable_sauv_trigger();
	RETURN NEW;
END IF;
RETURN NEW;
END;
$BODY$
 LANGUAGE 'plpgsql';

CREATE TRIGGER doreplay
  AFTER INSERT
  ON sync.doreplay
  FOR EACH ROW
EXECUTE PROCEDURE sync.sync();

-----------------------

DROP VIEW sync.replay_infos;
CREATE OR REPLACE VIEW sync.replay_infos AS
SELECT
CASE 
WHEN  r.integrateur is null THEN ''
ELSE r.integrateur
END,
CASE
WHEN count(r) = 1 THEN 'VOUS AVEZ 1 DONNEE SYNCHRONISEE PRETE A INJECTER DANS LA BDD'
ELSE 'VOUS AVEZ '|| count(r.*) || ' DONNEES SYNCHRONISEES PRETES A INJECTER DANS LA BDD'
END AS infos,
st_setsrid(st_makepoint(100,-11), 4326) AS geom
FROM sync.replay r
Group by r.integrateur;
