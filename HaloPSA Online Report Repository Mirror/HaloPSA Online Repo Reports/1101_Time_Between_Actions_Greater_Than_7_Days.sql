SELECT d.faultid AS [Ticket Number]
	,(
		SELECT aareadesc
		FROM area
		WHERE areaint = aarea
		) AS [Client]
	,(
		SELECT uname
		FROM uname
		WHERE assignedtoint = unum
		) AS [Technician]
FROM (
	SELECT a.faultid
		,actionnumber
		,whe_
		,(
			SELECT whe_
			FROM actions b
			WHERE a.faultid = b.faultid
				AND a.actionnumber + 1 = b.actionnumber
			) AS [NAD]
		,DATEDIFF(dd, whe_, CASE 
				WHEN (
						SELECT whe_
						FROM actions b
						WHERE a.faultid = b.faultid
							AND a.actionnumber + 1 = b.actionnumber
						) IS NULL
					THEN getdate()
				ELSE (
						SELECT whe_
						FROM actions b
						WHERE a.faultid = b.faultid
							AND a.actionnumber + 1 = b.actionnumber
						)
				END) AS [DD]
		,areaint
		,Assignedtoint
	FROM actions a
	LEFT JOIN faults ON faults.faultid = a.faultid
	) d
WHERE [DD] >= 7
	AND whe_ > @startdate
	AND [NAD] < @enddate
GROUP BY d.faultid
	,areaint
	,assignedtoint
