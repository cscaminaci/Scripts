select a.[TicketID],
       a.[Description],
       a.[Technician],
       a.[SLATimeLeft] from 
(select faultid as 'TicketID',
       symptom as 'Description',
       uname as 'Technician'
	   ,cast(floor(dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),frespondbydate),slaid)) as nvarchar) + ':' + right('0' + cast(cast(floor(dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),frespondbydate),slaid)*60) as int)%60 as nvarchar),2) [SLATimeLeft]
from faults
left join uname on unum = assignedtoint
where (dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),frespondbydate),slaid) between 0 and 1) and status not in (8,9)
and slaresponsestate is null and (reportedby not like '%spreadsheet%' or reportedby is null)
and fexcludefromsla=0 
and fdeleted = 0)a 
left join 
(select faultid as 'TicketID',
       symptom as 'Description',
       uname as 'Technician'
	   ,cast(floor(dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),fixbydate),slaid)) as nvarchar) + ':' + right('0' + cast(cast(floor(dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),fixbydate),slaid)*60) as int)%60 as nvarchar),2) [SLATimeLeft]
from faults
left join uname on unum = assignedtoint
where (dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),fixbydate),slaid) between 0 and 1) and status not in (8,9)
and slaresponsestate is null and (reportedby not like '%spreadsheet%' or reportedby is null)
and fexcludefromsla=0  and fdeleted = 0)b
on a.[TicketID]=b.[TicketID]
