SELECT faultid AS [Ticket No]
	,(
		SELECT aareadesc
		FROM area
		WHERE aarea = areaint
		) AS [Client]
	,symptom AS [Summary]
	,(
		SELECT pdesc
		FROM policy
		WHERE seriousness = Ppolicy And Slaid = Pslaid
		) AS [Priority]
	,(
		SELECT uname
		FROM uname
		WHERE unum = assignedtoint
		) AS [Technician]
	,CASE WHEN status = 9 THEN 'Closed'
              ELSE 'Open'
              END as [Status]
FROM faults
where dateoccured > @startdate and dateoccured < @enddate



