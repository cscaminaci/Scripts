select faultid as 'TicketID',
       symptom as 'Description',
       uname as 'Technician',
       sectio_ as [Team]
       ,Dbo.Fn_GetWorkingHours(fixbydate,slaid,0,NULL) as [SLA Time]
from faults
left join uname on unum = assignedtoint
left join requesttype on rtid = requesttypenew 
where Dbo.Fn_GetWorkingHours(fixbydate,slaid,0,NULL) <2
and status not in (8,9)
and (reportedby not like '%spreadsheet%' or reportedby is null)
and fexcludefromsla=0 and sectio_ not in ('Development','Sales','Infrastructure')
and fdeleted = 0
and fslaonhold!=1
and rtisopportunity=0

