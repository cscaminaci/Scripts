SELECT [Charge Rate]
	,[Time Taken]
	,[Client]
FROM (
	SELECT (
			SELECT fvalue
			FROM lookup
			WHERE fcode = [Action Code]
				AND fid = 17
			) AS [Charge Rate]
		,round(Sum([Time]), 2) AS [Time Taken]
		,[Client]
	FROM (
		SELECT actions.faultid AS [Fault ID]
			,actionnumber AS [Action Number]
			,(
				SELECT aareadesc
				FROM area
				WHERE aarea IN (
						SELECT areaint
						FROM faults
						WHERE faults.faultid = actions.faultid
						)
				) AS [Client]
			,actoutcome AS [Action Outcome]
			,timetaken AS [Time]
			,actioncode + 1 AS [Action Code]
			,whe_ AS [Date]
		FROM actions
		WHERE whe_ > @startdate
			AND whe_ < @enddate
		) a
	GROUP BY a.[Action Code]
		,[Client]
	) b
GROUP BY [Charge Rate]
	,b.[Time Taken]
	,[Client]

