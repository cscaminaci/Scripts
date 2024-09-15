SELECT
faults.faultid as [TicketID],
faults.symptom as [Summary],
faults.symptom2 as [Details],
faults.clearance as [Closure Notes],
faults.DateOccured as [Date & Time]
FROM Faults
JOIN RequestType ON requesttype.RTID=faults.requesttypenew
WHERE requesttype.rtdesc='LGSR Issues'
