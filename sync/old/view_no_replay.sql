
--------------------------------------------------------------
--Vue des les lignes qui ne seront pas jouées: édition multiple d'une même entité.
--
--
--------------------------------------------------------------
CREATE OR REPLACE VIEW public.no_replay AS
SELECT * FROM sauv_data WHERE ts IN (
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
			    ) d) 
)
