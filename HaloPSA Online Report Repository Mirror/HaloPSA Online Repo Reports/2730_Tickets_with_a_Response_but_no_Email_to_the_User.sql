select distinct
faults.faultid as [Ticket ID], 
symptom as [Summary], 
aareadesc as [Customer Name],
fresponsedate as [Response Time]
from faults  
join area on aarea=areaint
join actions on actions.faultid=faults.faultid
where status not in (8,9) and fresponsedate is not null and fdeleted=0 and fmergedintofaultid=0 and (select top 1 actoutcome from actions where faults.faultid=actions.faultid and actoutcome like 'Email User') is null
