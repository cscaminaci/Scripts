select faultid as 'TicketID',
       symptom as 'Description',
       uname as 'Technician',
       sectio_ as [Team]
       ,case when fresponsedate is null then dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),frespondbydate),slaid)
            else dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),fixbydate),slaid)end as [SLATimeLeft]
from faults
left join uname on unum = assignedtoint
left join requesttype on rtid = requesttypenew 
where (dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),fixbydate),slaid)<0 or (dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),frespondbydate),slaid)<0) and slaresponsestate is null) and status not in (8,9)
 and (reportedby not like '%spreadsheet%' or reportedby is null)
and fexcludefromsla=0 and sectio_ not in ('Development','Sales','Infrastructure')
and fdeleted = 0
and fslaonhold!=1
and rtisopportunity=0

