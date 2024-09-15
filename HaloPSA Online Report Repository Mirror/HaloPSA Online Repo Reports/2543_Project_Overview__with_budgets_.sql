select 
Faultid as [Ticket ID]

,username as [User]
,sdesc as [Site]
,aareadesc as [Client]
,Symptom as [Project Name]
,Symptom2 as [Issue Raised]
,RTDesc as [Ticket Type]
, (select btname from budgettype where btid=fbtbtid) [Budget Type]
,CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(fbthours, 0), 2) * 60 AS INT), 0) / 60) AS VARCHAR(9)) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(fbthours, 0), 2) * 60 AS INT), 0) % 60) AS VARCHAR(2)), 2) as [Hours Budgeted]
,CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(fbtactualtime, 0), 2) * 60 AS INT), 0) / 60) AS VARCHAR(9)) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(fbtactualtime, 0), 2) * 60 AS INT), 0) % 60) AS VARCHAR(2)), 2) as [Completed Hours]
,CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(((fbthours)-(fbtactualtime)), 0), 2) * 60 AS INT), 0) / 60) AS VARCHAR(9)) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(((fbthours)-(fbtactualtime)), 0), 2) * 60 AS INT), 0) % 60) AS VARCHAR(2)), 2) as [Hours Remaining]
,tStatusdesc as [Status]
,sectio_ as [Team]
,assigned.uname as [Assigned Tech]
,dateoccured as [Date Opened]
,pdesc as [Priority]
,Sldesc as [SLA]
,(select top 1 note from actions where actions.faultid=faults.faultid and actoutcome like '%Private Note%' order by actionnumber desc) as [Latest note]
,case
when Slastate = 'I'
then 'Inside'
when slastate = 'O'
then 'Outside'
else 'Not Responded'
end as [SLA State]
,category2
,category3
,datecleared as [Date Closed]
,Closer.uname as [Closed BY]
,clearance as [Closure Note]
,cleartime as [Time to Fix]
,fixbydate as [Estimated Closure date]
,fslaholdtime as [Time on Hold]
,Elapsedhrs as  [Time Spent]

 
from
          faults 
left join area on aarea =areaint
left join site on ssitenum = sitenumber
left join uname assigned on assigned.unum =assignedtoint
left join uname closer on closer.unum = clearwhoint
left join tstatus on status = tstatus
left join policy on ppolicy = seriousness and pslaid=slaid
left join slahead on slid=slaid
left join requesttype on rtid = requesttypenew
left join faultbudget on faultid=fbtfaultid
left join budgettype on btid=fbtbtid

/* Common where clauses

Where fdeleted=0 and fmergedintofaultid=0 and dateoccured between @startdate and @enddate

Where fdeleted=0 and fmergedintofaultid=0 and dateoccured between @startdate and @enddate and status not in (8,9)

Where fdeleted=0 and fmergedintofaultid=0 and dateoccured between @startdate and @enddate and status in (8,9)

Where fdeleted=0 and fmergedintofaultid=0 and datecleared between @startdate and @enddate 

*/
