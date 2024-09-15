select faultid as 'Ticket ID',
       symptom as 'Description',
       uname as 'Technician', aareadesc as [Client]
	   ,case when fresponsedate is null then dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),frespondbydate),slaid)
            else dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),fixbydate),slaid) end as [SLA Time Left]
from faults
left join uname on unum = assignedtoint left join area on aarea=areaint
where (dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),fixbydate),slaid)<2 or dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),frespondbydate),slaid)<0) and status not in (8,9)
and slaresponsestate is null and (reportedby not like '%spreadsheet%' or reportedby is null)
and fexcludefromsla=0 
and fdeleted = 0


