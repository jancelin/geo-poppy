--Gestion des conflits du update delete d'une même entité lors d'un replay
	SELECT al.*,egal.doublon  --selectionne les données modifiées/supprimées par 1 à n utilisateurs
	FROM    ( --sous-select : toute les données + pk value
		SELECT *,(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id
		FROM sauv_data s 
		) al,
		( --sous-select : données modifiées plusieurs fois dans le update et delete
		SELECT distinct pk, (json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC id, cast (count(pk) as integer) doublon
		FROM sauv_data s
		WHERE replay = FALSE AND action1 = 'UPDATE' OR action1 = 'DELETE'
		GROUP BY pk, id
		HAVING count(pk)>1 --garde seulement les entrées en doublon
		) egal
	WHERE al.pk = egal.pk AND al.id = egal.id
	ORDER BY al.id ASC
	
