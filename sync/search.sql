--Gestion des conflits du update delete d'une même entité lors d'un replay
SELECT al.*  --selectionne les données modifiées/supprimées par 1 à n utilisateurs

FROM    (--sous select : toute les données + pk value
	SELECT *,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id
	FROM
	sauv_data s 
	) al,
	(--sousselect : données modifiées plusieurs fois dans le update et delete
	SELECT distinct pk, (json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id, count(pk)
	FROM sauv_data s
	WHERE 
	replay = FALSE AND action1 = 'UPDATE' OR action1 = 'DELETE'
	GROUP BY pk, id
	ORDER BY id
	    ) egal
WHERE
al.pk = egal.pk 
AND al.id = egal.id
AND egal.count >1

ORDER BY al.id ASC

