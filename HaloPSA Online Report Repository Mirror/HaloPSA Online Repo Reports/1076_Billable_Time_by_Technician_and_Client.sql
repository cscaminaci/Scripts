SELECT [Name]
	,[Client]
	,[Billable Hours]
	,[Monthly Plan Hours]
	,[Non-Billable Hours]
	,[Billable Hours] + [Monthly Plan Hours] + [Non-Billable Hours] AS [Total]
FROM (
	SELECT uname AS [Name]
		,Aareadesc as [Client]
		,(
			SELECT isnull(round(sum(timetaken), 2), 0)
			FROM actions
			inner Join faults on actions.faultid=faults.faultid
			inner join area on aarea=areaint
			WHERE who = uname
				AND aareadesc = b.aareadesc
				AND actioncode = 0
				AND whe_ > @startdate
				AND whe_ < @enddate
			) AS [Billable Hours]
		,(
			SELECT isnull(round(sum(timetaken), 2), 0)
			FROM actions
			inner Join faults on actions.faultid=faults.faultid
			inner join area on aarea=areaint
			WHERE who = uname
				AND aareadesc = b.aareadesc
				AND actioncode = 1
				AND whe_ > @startdate
				AND whe_ < @enddate
			) AS [Monthly Plan Hours]
		,(
			SELECT isnull(round(sum(timetaken), 2), 0)
			FROM actions
			inner Join faults on actions.faultid=faults.faultid
			inner join area on aarea=areaint
			WHERE who = uname
				AND aareadesc = b.aareadesc
				AND actioncode = - 1
				AND whe_ > @startdate
				AND whe_ < @enddate
			) AS [Non-Billable Hours]
	FROM uname cross join area b where unum>1
	) a

UNION

SELECT 'zTotal' AS [Name]
	,'Total' as [Client]
	,sum([Billable Hours]) AS [Billable Hours]
	,Sum([Monthly Plan Hours]) AS [Monthly Plan Hours]
	,sum([Non-Billable Hours]) AS [Non-Billable Hours]
	,sum([Billable Hours] + [Monthly Plan Hours] + [Non-Billable Hours]) AS [Total]
FROM (
	SELECT uname AS [Name]
		,(
			SELECT isnull(round(sum(timetaken), 2), 0)
			FROM actions
			WHERE who = uname
				AND actioncode = 0
				AND whe_ > @startdate
				AND whe_ < @enddate
			) AS [Billable Hours]
		,(
			SELECT isnull(round(sum(timetaken), 2), 0)
			FROM actions
			WHERE who = uname
				AND actioncode = 1
				AND whe_ > @startdate
				AND whe_ < @enddate
			) AS [Monthly Plan Hours]
		,(
			SELECT isnull(round(sum(timetaken), 2), 0)
			FROM actions
			WHERE who = uname
				AND actioncode = - 1
				AND whe_ > @startdate
				AND whe_ < @enddate
			) AS [Non-Billable Hours]
	FROM uname
	) a

