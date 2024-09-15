SELECT request_view.*
	,sectio_ AS Section
	,category2 AS [Category 1]
	,category3 AS [Category 2]
	,category4 AS [Category 3]
	,category5 AS [Category 4]
	,satisfactionlevel AS [Survey_Rating]
FROM request_view
JOIN faults ON faultid = ticket_id
WHERE (
		SELECT count(actoutcome)
		FROM actions
		WHERE actions.faultid = ticket_id
			AND actoutcome LIKE '%close%'
		) >1
	OR (
		(
			SELECT count(actoutcome)
			FROM actions
			WHERE actions.faultid = ticket_id
				AND actoutcome LIKE '%close%'
			) = 1
		AND faults.STATUS <> 9
		)
