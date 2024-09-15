select 
actions.faultid [Ticket ID], 
symptom as [Summary], 
dateoccured AS [Date Opened],
datecleared as [Date Closed],
username AS [User], 
aareadesc AS [Customer],
treedesc AS [Stripe],
uname AS [Agent],
sectio_ AS [Team],
(SELECT pdesc FROM policy WHERE ppolicy = seriousness AND pslaid = slaid) AS [Priority],
rtdesc AS [Ticket Type],
(SELECT dbo.fn_formattimechar(SUM(ISNULL(timetaken, 0))) from actions where actions.faultid=faults.faultid) AS [Total Unadjusted Time],
(SELECT dbo.fn_formattimechar(SUM(ISNULL(timetaken, 0))) from actions where actions.faultid=faults.faultid and actioncode !=-1) AS [Total Unadjusted Billable Time],
(SELECT dbo.fn_formattimechar(SUM(ISNULL(timetaken, 0) + ISNULL(timetakenadjusted, 0))) from actions where actions.faultid=faults.faultid and actioncode !=-1) AS [Total Adjusted Billable Time],
whe_ as [Date Overriden], 
who as [Overriding Agent] 

from actions 
left join faults on faults.faultid=actions.faultid
LEFT JOIN uname ON unum = assignedtoint
LEFT JOIN area ON aarea = areaint
LEFT JOIN tree ON treeid = atreeid
LEFT JOIN tstatus ON tstatus = status
LEFT JOIN requesttype ON rtid = requesttypenew

where actoutcome like '%Overriding actual time%'

GROUP BY
actions.faultid,
faults.faultid,
dateoccured,
datecleared,
symptom,
seriousness,
rtdesc,
tstatusdesc,
username,
aareadesc,
treedesc,
uname,
sectio_,
slaid,
whe_,
Who
