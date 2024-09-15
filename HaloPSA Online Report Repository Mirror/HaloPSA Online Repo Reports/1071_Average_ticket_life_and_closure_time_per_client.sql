
SELECT [Client]
	,round([Days] / [Tickets], 2) AS [Average Ticket Life]
	,round([ACT] / [Tickets], 2) AS [Average Closure Time]
FROM (
	SELECT aareadesc AS [Client]
		,(
			SELECT sum([DO])
			FROM (
				SELECT datediff(dy, dateoccured, datecleared)+1 AS [DO]
				FROM faults
				WHERE aarea = areaint
					AND dateoccured > @startdate
					AND dateoccured < @enddate
					AND datecleared IS NOT NULL
					AND datecleared <> ''
					and datecleared > 5
				) d
			) AS [Days]
		,(
			SELECT sum(timetaken)
			FROM actions
			WHERE faultid IN (
					SELECT faultid
					FROM faults
					WHERE aarea = Areaint
						AND STATUS = 9
						AND dateoccured > @startdate
						AND dateoccured < @enddate
					)
			) AS [ACT]
		,nullif((
				SELECT count(*)
				FROM faults
				WHERE STATUS = 9
					AND dateoccured > @startdate
					AND dateoccured < @enddate
					AND aarea = areaint
				), 0) AS [Tickets]
	FROM area
	) d
GROUP BY [Client]
	,[Days]
	,[Tickets]
	,[ACT]

