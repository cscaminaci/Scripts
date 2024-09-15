SELECT faults.faultid AS [Ticket ID]
	,symptom AS [Summary]
	,dateoccured [Date Opened]
	,(
		SELECT TOP 1 note
		FROM ACTIONS
		WHERE ACTIONS.Faultid = FAULTS.faultid
		ORDER BY Whe_ DESC
		) AS [Last Action Note]
	,Flastactiondate [Last Action Date]
	,sectio_ AS [Team]
	,uname AS [Agent]
	,round(cast(Flastactiondate - dateoccured AS FLOAT) / 24, 2) AS [Days Open]
FROM faults
JOIN UNAME ON Unum = assignedtoint
WHERE STATUS NOT IN (
		8
		,9
		)
and fdeleted=0
