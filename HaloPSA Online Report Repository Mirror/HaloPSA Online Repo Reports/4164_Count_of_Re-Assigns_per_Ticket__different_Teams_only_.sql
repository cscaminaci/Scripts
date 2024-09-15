select [Ticket ID], [Team], [Agent], count([Ticket ID]) as [Number of Re-Assigns] from(
select *, STuff([TrimBefore2],1,6,'') as [TrimBefore3], STuff([TrimAfter2],1,4,'') as [TrimAfter3]
 from(
select [Ticket ID], who as [Who], [Trim Before],[Trim After],[Team], [Agent],

SUBSTRING([Trim Before],0,CHARINDEX(',',[Trim Before],0)) as [TrimBefore2],
SUBSTRING([Trim After],0,CHARINDEX(',',[Trim After],0)) as [TrimAfter2]
 
from(

select actions.faultid as [Ticket ID]
, sectio_ as [Team]
, uname as [Agent]
, whe_
, actionnumber as [Action Number]
, note as [Note]
, who
, SUBSTRING(cast(note as nvarchar(max)),CHARINDEX('To',cast(note as nvarchar(max))),LEN(cast(note as nvarchar(max)))) as [Trim After]
, SUBSTRING(note,0,CHARINDEX(';',note,0)) as [Trim Before]
, uname as [Currently Assigned]

from actions

join faults on faults.faultid = actions.faultid
join uname on unum=assignedtoint

where status not in (8,9) and actoutcome like 're-assign' and cast(note as nvarchar(max)) <>'' and whe_ between @startdate and @enddate)a
 )b
)c where [TrimAfter3]!=[TrimBefore3]
group by [Ticket ID], [Team], [Agent]
