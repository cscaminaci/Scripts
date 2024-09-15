SELECT Discipline
	,Technician
	,AverageResponseTime AS 'Average Response Time'
	,AverageResolutionTime AS 'Average Resolution Time'
	,TotalTimeTaken / TotalTickets AS 'Average Time Taken'
	,RespondedtoinSLA AS '% Responded to in SLA'
FROM (
	SELECT cdcategoryname AS 'Discipline'
		,(
			SELECT uname
			FROM uname
			WHERE f.assignedtoint = unum
				AND unum <> 1
			) AS Technician
		,(
					SELECT round(sum(FResponseTime) / nullif(count(*), 0), 2)
					FROM Faults
					WHERE STATUS = 9
						AND category2 = O.cdcategoryname
						AND dateoccured > @startdate
						AND dateoccured < @enddate
						AND f.assignedtoint = assignedtoint
					) AS 'AverageResponseTime'
		,(
					SELECT round(sum(Elapsedhrs) / nullif(count(*), 0), 2)
					FROM Faults
					WHERE STATUS = 9
						AND category2 = O.cdcategoryname
						AND dateoccured > @startdate
						AND dateoccured < @enddate
						AND f.assignedtoint = assignedtoint
					) AS 'AverageResolutionTime'
		,(
					SELECT round(sum(timetaken), 2)
					FROM actions
					JOIN faults ON faults.faultid = actions.faultid
					WHERE STATUS = 9
						AND category2 = O.cdcategoryname
						AND dateoccured > @startdate
						AND dateoccured < @enddate
						AND f.assignedtoint = assignedtoint
					) AS 'TotalTimeTaken'
		,(
					SELECT round(nullif(count(*), 0), 2)
					FROM faults
					WHERE STATUS = 9
						AND category2 = O.cdcategoryname
						AND dateoccured > @startdate
						AND dateoccured < @enddate
						AND f.assignedtoint = assignedtoint
					) AS 'TotalTickets'
		,(
			SELECT Round((
						sum(CASE 
								WHEN slaresponsestate = 'I'
									THEN 1
								ELSE 0
								END) * 100.0 / count(faultid)
						), 2)
			FROM faults
			WHERE STATUS = 9
				AND category2 = O.cdcategoryname
				AND dateoccured > @startdate
				AND dateoccured < @enddate
				AND f.assignedtoint = assignedtoint
			) AS 'RespondedToInSLA'
	FROM categorydetail O
	LEFT JOIN faults f ON f.category2 = O.cdcategoryname
	WHERE cdtype = 2
	GROUP BY cdcategoryname
		,cdid
		,cdtype
		,assignedtoint
	) a
WHERE Technician IS NOT NULL

