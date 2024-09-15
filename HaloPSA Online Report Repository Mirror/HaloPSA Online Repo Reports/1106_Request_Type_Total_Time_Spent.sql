SELECT [Request Type]
	,[Team Category]
	,[Tickets Logged]
	,[Tickets Logged (with time)]
	,RIGHT('0' + CAST(FLOOR(COALESCE(cast([Total Time] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Total Time] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) AS [Total Time]
	,RIGHT('0' + CAST(FLOOR(COALESCE(cast(round([Total Time] / [Tickets Logged (with time)], 2) * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(cast(round([Total Time] / [Tickets Logged (with time)], 2) * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) AS [Average Time]
FROM (
	SELECT rtdesc AS [Request Type]
		,CDCategoryName as [Team Category]
		,convert(REAL, (
				SELECT count(*)
				FROM faults
				WHERE requesttypenew = rtid
					AND category2 = CDCategoryName
					AND STATUS = 9
					AND dateoccured > @startdate
					AND dateoccured < @enddate
				), 0) AS [Tickets Logged]
		,convert(REAL, (
				SELECT count(*)
				FROM faults
				WHERE requesttypenew = rtid
					AND category2 = CDCategoryName
					AND STATUS = 9
					AND dateoccured > @startdate
					AND dateoccured < @enddate
					AND (select sum(timetaken) from actions where actions.faultid=faults.faultid) > 0
				), 0) AS [Tickets Logged (with time)]
		,round(convert(REAL, nullif((
						SELECT sum(timetaken)
						FROM actions
						WHERE actions.faultid IN (
								SELECT faults.faultid
								FROM faults
								WHERE requesttypenew = rtid
									AND category2 = CDCategoryName
									AND STATUS = 9
									AND dateoccured > @startdate
									AND dateoccured < @enddate
									AND (select sum(timetaken) from actions where actions.faultid=faults.faultid) > 0
								)
						), 0)), 2) AS [Total Time]
	FROM REQUESTTYPE,CATEGORYDETAIL
	where CDType = 2
	) d
where [Tickets Logged]>0
