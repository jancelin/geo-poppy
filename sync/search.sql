SELECT
	ts,
	action1,
	pk,
	(json_array_elements(s.sauv)->>pk)::TEXT::NUMERIC foo
	FROM sauv_data s
	WHERE replay = FALSE AND action1 = 'UPDATE' or action1 = 'DELETE'
	ORDER BY foo
