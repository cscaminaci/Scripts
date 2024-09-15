SELECT TOP 1000
Faultid AS [Ticket ID],
Symptom AS [Subject],
RTDesc AS [Ticket Type],
tstatusdesc,
DateOccured AS [Date Opened],
DateCleared AS [Date Closed],
/*IIF(ROUND(CAST((DATEDIFF(Minute,DateOccured,DateCleared)) AS Float)/60,2)<-1000000,NULL,ROUND(CAST((DATEDIFF(Minute,DateOccured,DateCleared)) AS Float)/60,2)) AS [Open to Close (h)],
(DATEDIFF(Hour,DateOccured,DateCleared)) AS HourDiff,
FLOOR(((DATEDIFF(Hour,DateOccured,DateCleared)) / 24)) AS DayDiff,
(DATEDIFF(Hour,DateOccured,DateCleared))-(FLOOR(((DATEDIFF(Hour,DateOccured,DateCleared)) / 24))*24) AS XSHourDiff,*/
CASE
WHEN DATEDIFF(Minute,DateOccured,DateCleared) < 0 AND Status NOT IN (8,9) THEN '[Re-Opened]'
WHEN (DATEDIFF(Minute,DateOccured,DateCleared) >= 0 AND Status NOT IN (8,9)) OR (DATEDIFF(Minute,DateOccured,DateCleared) IS NULL) THEN '[Open]'
ELSE CAST(FLOOR(((DATEDIFF(Hour,DateOccured,DateCleared)) / 24)) AS VARCHAR)+'d, '+CAST((DATEDIFF(Hour,DateOccured,DateCleared))-(FLOOR(((DATEDIFF(Hour,DateOccured,DateCleared)) / 24))*24) AS VARCHAR)+'h'
END AS [Open to Closed],
fixbydate AS [Resolution Date],
fresponsedate AS [Responded Date],
CASE
WHEN SLAresponsestate='I' then 'Inside'
WHEN SLAresponsestate='O' then 'Outside'
WHEN SLAresponsestate='E' then 'Excluded from SLA'
ELSE SLAresponsestate
END AS [Response State],
Username AS [User],
category2 AS [Category],
sdesc AS [Site],
sectio_ AS [Section],
(select REPLACE(ROUND(SUM(timetaken+timetakenadjusted),2),'.',',') from actions where actions.faultid=faults.faultid) AS [Time Taken],
aareadesc AS  [Customer],
fexcludefromsla AS [Excluded from SLA?]

from Faults

JOIN requesttype ON requesttypenew=RTID
JOIN tstatus ON status=tstatus
JOIN site ON ssitenum=sitenumber
JOIN area ON areaint=aarea

WHERE fdeleted=0
AND fmergedintofaultid=0

