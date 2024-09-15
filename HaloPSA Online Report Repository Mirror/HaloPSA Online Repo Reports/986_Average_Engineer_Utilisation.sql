SELECT [Technician]
	,[Avg Hours Logged]
	,[Expected Hours]
	,cast(isnull(round(([Avg Hours Logged] / nullif([Expected Hours], 0)) * 100, 0), 0) AS VARCHAR(50)) + '%' AS '%'
	,CASE 
		WHEN [Expected Hours] = [Avg Hours Logged]
			THEN 'Complete'
		ELSE 'Incomplete'
		END AS 'Note'
	,[Travel Time]
	,[Tickets Assigned]
FROM (
	SELECT [Technician]
		,[Avg Hours Logged]
		,[Travel Time]
		,[Tickets Assigned]
		,(
			CASE 
				WHEN (
						SELECT walldayssame
						FROM workdays
						WHERE wdid = [WorkDayID]
						) = 1
					THEN (
							SELECT (cast(wincmonday AS INT) + cast(winctuesday AS INT) + cast(wincwednesday AS INT) + cast(wincthursday AS INT) + cast(wincfriday AS INT) + cast(wincsaturday AS INT) + cast(wincsunday AS INT)) * ([WHA] - [uhrsreducer])
							FROM workdays
							WHERE wdid = [WorkDayID]
							)
				ELSE (
						SELECT cast(wincmonday AS INT) * ([WHA1] - [uhrsreducer]) + cast(winctuesday AS INT) * ([WHA2] - [uhrsreducer]) + cast(wincwednesday AS INT) * ([WHA3] - [uhrsreducer]) + cast(wincthursday AS INT) * ([WHA4] - [uhrsreducer]) + cast(wincfriday AS INT) * ([WHA5] - [uhrsreducer]) + cast(wincsaturday AS INT) * ([WHA6] - [uhrsreducer]) + cast(wincsunday AS INT) * ([WHA7] - [uhrsreducer])
						FROM workdays
						WHERE wdid = [WorkDayID]
						)
				END
			) AS [Expected Hours]
	FROM (
		SELECT uname AS [Technician]
			,isnull(round((
						SELECT sum(timetaken)
						FROM actions
						WHERE who = uname
							AND whe_ > @startdate
							AND whe_ < @enddate
						) / nullif(datediff(ww, @startdate, @enddate), 0), 2), 0) AS [Avg Hours Logged]
			,uworkdayid AS [WorkDayID]
			,uhrsreducer AS [uhrsreducer]
			,isnull(datediff(hh, wstart, wend),0) AS [WHA]
			,isnull(datediff(hh, wstart1, wend1),0) AS [WHA1]
			,isnull(datediff(hh, wstart2, wend2),0) AS [WHA2]
			,isnull(datediff(hh, wstart3, wend3),0) AS [WHA3]
			,isnull(datediff(hh, wstart4, wend4),0) AS [WHA4]
			,isnull(datediff(hh, wstart5, wend5),0) AS [WHA5]
			,isnull(datediff(hh, wstart6, wend6),0) AS [WHA6]
			,isnull(datediff(hh, wstart7, wend7),0) AS [WHA7]
			,isnull(round((
						SELECT sum(traveltime)
						FROM actions
						WHERE who = uname
							AND whe_ > @startdate
							AND whe_ < @enddate
						) / nullif(datediff(ww, @startdate, @enddate), 0), 2), 0) AS [Travel Time]
			,(
				SELECT count(faultid)
				FROM faults
				WHERE assignedtoint = unum
					AND dateoccured > @startdate
					AND dateoccured < @enddate
				) / nullif(datediff(ww, @startdate, @enddate), 0) AS [Tickets Assigned]
		FROM uname
		JOIN workdays ON uworkdayid = wdid
		) a
	) b

