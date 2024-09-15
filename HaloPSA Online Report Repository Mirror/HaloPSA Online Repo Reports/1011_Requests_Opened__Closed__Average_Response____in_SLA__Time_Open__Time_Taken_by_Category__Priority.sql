SELECT Discipline
	,Priority
	,TotalTicketsLogged AS 'Total Tickets Logged'
	,TotalTicketsClosed AS 'Total Tickets Closed'
	,AverageResponseTime AS 'Average Response Time'
	,AverageResolutionTime AS 'Average Resolution Time'
	,TotalTimeTaken / TotalTickets AS 'Average Time Taken'
	,RespondedtoinSLA AS '% Responded to in SLA'
FROM (
	SELECT cdcategoryname AS Discipline
		,(
			SELECT pdesc
			FROM policy
			WHERE f.seriousness = ppolicy
				AND f.slaid = pslaid
			) AS Priority
		,(
			SELECT count(faultid)
			FROM Faults
			WHERE STATUS = 9
				AND category2 = O.cdcategoryname
				AND dateoccured > @startdate
				AND dateoccured < @enddate
				AND f.seriousness = seriousness
				AND f.slaid = slaid
			) AS 'TotalTicketsLogged'
		,(
			SELECT count(faultid)
			FROM Faults
			WHERE STATUS = 9
				AND category2 = O.cdcategoryname
				AND datecleared > @startdate
				AND datecleared < @enddate
				AND f.seriousness = seriousness
				AND f.slaid = slaid
			) AS 'TotalTicketsClosed'
		,(
			SELECT round(sum(FResponseTime) / nullif(count(*), 0), 2)
			FROM Faults
			WHERE STATUS = 9
				AND category2 = O.cdcategoryname
				AND dateoccured > @startdate
				AND dateoccured < @enddate
				AND f.seriousness = seriousness
				AND f.slaid = slaid
			) AS 'AverageResponseTime'
		,(
			SELECT round(sum(Elapsedhrs) / nullif(count(*), 0), 2)
			FROM Faults
			WHERE STATUS = 9
				AND category2 = O.cdcategoryname
				AND dateoccured > @startdate
				AND dateoccured < @enddate
				AND f.seriousness = seriousness
				AND f.slaid = slaid
			) AS 'AverageResolutionTime'
		,(
			SELECT round(sum(timetaken), 2)
			FROM actions
			JOIN faults ON faults.faultid = actions.faultid
			WHERE STATUS = 9
				AND category2 = O.cdcategoryname
				AND dateoccured > @startdate
				AND dateoccured < @enddate
				AND f.seriousness = seriousness
				AND f.slaid = slaid
			) AS 'TotalTimeTaken'
		,(
			SELECT round(nullif(count(*), 0), 2)
			FROM faults
			WHERE STATUS = 9
				AND category2 = O.cdcategoryname
				AND dateoccured > @startdate
				AND dateoccured < @enddate
				AND f.seriousness = seriousness
				AND f.slaid = slaid
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
				AND f.seriousness = seriousness
				AND f.slaid = slaid
			) AS 'RespondedToInSLA'
	FROM categorydetail O
	LEFT JOIN faults f ON f.category2 = O.cdcategoryname
	WHERE cdtype = 2
	GROUP BY cdcategoryname
		,cdid
		,cdtype
		,seriousness
		,slaid
	) a
WHERE Priority IS NOT NULL

