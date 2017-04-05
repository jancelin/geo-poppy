--------------------------------------------------------------------------------------------------------------------
--Recherche et édite les données en conflit
-- !!!!!!Pensez à lancer la function no_replay() avant!!!!!!!!
--	filtres:
--		* selection de la dernière entrée utilisateur si plusieurs modification  de la meme donnée.
--		* Retrouve une donnée qui a été modifié par plusieurs utilisateurs
--	Edition: 
--		*Ouvrir la table et cocher les données à supprimer dans la première colonne "supprime".
--
--------------------------------------------------------------------------------------------------------------------
--DROP VIEW IF EXISTS public.conflict;
CREATE OR REPLACE VIEW public.conflict AS
SELECT  boolean 'f' supprime ,tbl,pk,(json_array_elements(sauv)->>pk)::TEXT::NUMERIC id,integrateur,ts,schema_bd,action1,sauv,replay,no_replay
FROM
( --liste toutes les données sans les multi edition utilisateur.
		SELECT (json_array_elements(sauv)->>pk)::TEXT::NUMERIC id,* FROM sauv_data WHERE ts NOT IN (
		--select last update 
		SELECT ts
		FROM 
		( --sous-select : toutes les données + pk value
				SELECT *,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id
				FROM sauv_data s 
		) al,
		(--trouve les données modifiées plusieurs fois
			SELECT distinct  pk, (json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id, integrateur i,COUNT(integrateur)
			FROM sauv_data s
			WHERE replay = FALSE AND action1 = 'UPDATE' OR action1 = 'DELETE'
			GROUP BY pk, id, i 
			HAVING COUNT(integrateur)>1 --filtre nombre d'édition par integrateur
		) trouv
		WHERE trouv.pk = al.pk AND trouv.id = al.id AND trouv.i = al.integrateur AND  al.ts NOT IN (SELECT d.ts FROM
				    ( --trouve le dernier ts par pk/id
					SELECT pk,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id,  max(ts) ts
					FROM sauv_data s
					GROUP BY id,pk
				    ) d) --il faudra rajouter un insert boolean exclusion dans replay!!!!!!!!!!!!!!!!!!!!!!!!
			)
) al
WHERE al.id IN	
(--liste les single id pouvant être inséré tout de suite, si changement du "having" possibilité de trouver les doublons d'edition.
	SELECT distinct (json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id
		FROM sauv_data s
		WHERE ts NOT IN (
			--select last update 
			SELECT ts
			FROM 
			( --sous-select : toutes les données + pk value
					SELECT *,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id
					FROM sauv_data s
					WHERE replay = FALSE
			) al,
			(--trouve les données modifiées plusieurs fois
				SELECT distinct  pk, (json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id, integrateur i,COUNT(integrateur)
				FROM sauv_data s
				WHERE replay = FALSE AND action1 = 'UPDATE' OR action1 = 'DELETE' AND replay = FALSE
				GROUP BY pk, id, i 
				HAVING COUNT(integrateur)>1 --filtre nombre d'édition par integrateur
			) trouv
			WHERE trouv.pk = al.pk AND trouv.id = al.id AND trouv.i = al.integrateur AND  al.ts NOT IN (SELECT d.ts FROM
					    ( --trouve le dernier ts par pk/id
						SELECT pk,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id,  max(ts) ts
						FROM sauv_data s
						WHERE replay = FALSE
						GROUP BY id,pk
					    ) d) --il faudra rajouter un insert boolean exclusion dans replay!!!!!!!!!!!!!!!!!!!!!!!!
		)
			AND replay = FALSE
		GROUP BY pk, id
		having count(pk)>1 -- =1 donne les entrées uniques & >1 donne les doublons rentrant en conflit d'edition
)
AND replay = 'FALSE'
ORDER BY (json_array_elements(sauv)->>pk)::TEXT::NUMERIC ASC
;
---------------------------------------
--function resolve_conflict: edite la première colonne en true pour ne pas rejouer la ligne et donc arreter le conflit.
----------------------------------------

CREATE OR REPLACE FUNCTION resolve_conflict() RETURNS TRIGGER AS $$
BEGIN

IF (TG_OP = 'UPDATE') THEN
UPDATE sauv_data SET
integrateur = OLD.integrateur,
ts = NEW.ts,
schema_bd = OLD.schema_bd,
tbl = OLD.tbl,
action1 = OLD.action1,
sauv = OLD.sauv,
pk = OLD.pk,
replay = TRUE,
no_replay = 2 --identifiant des conflits supprimés
where ts = OLD.ts;
RETURN NEW;

END IF;
       RETURN NEW;
	
	END;
	$$ LANGUAGE plpgsql;
	
	CREATE TRIGGER update_conflict_sauv_data
INSTEAD OF  UPDATE  ON conflict
FOR EACH ROW EXECUTE PROCEDURE resolve_conflict();
