
--------------------------------------------------------------------------------------------------------------------
--Recherche toutes les données sans conflit à rejouer dans replay
--	filtres:
--		* selection de la dernière entrée utilisateur si plusieurs modification  de la meme donnée.
--		* si une donnée à été modifié par plusieurs utilisateur elle est exclue. Jouer conflict.sql pour les trouver et les résoudre.
--
--------------------------------------------------------------------------------------------------------------------
SELECT integrateur,ts,schema_bd,tbl,action1,sauv,pk,replay
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
		having count(pk)=1 -- =1 donne les entrées uniques & >1 donne les doublons rentrant en conflit d'edition
)
ORDER BY ts ASC
;
 
