SELECT  * 
FROM 
( --sous-select : toutes les données + pk value
		SELECT *,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id
		FROM sauv_data s 
) al,
(--trouve les données modifiées plusieurs fois
	SELECT distinct  pk, (json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id, integrateur i,count(integrateur)
	FROM sauv_data s
	WHERE replay = FALSE AND action1 = 'UPDATE' OR action1 = 'DELETE'
	GROUP BY pk, id, i 
	HAVING count(integrateur)>1 --filtre nombre d'édition par integrateur
) trouv

WHERE trouv.pk = al.pk AND trouv.id = al.id AND trouv.i = al.integrateur 
AND  al.ts in   (select d.ts from
                    ( --trouve le dernier ts par pk/id
                        select pk,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id,  max(ts) ts
                        from sauv_data s
                        group by id,pk
                    ) d
                )
