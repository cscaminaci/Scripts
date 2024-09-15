select
faultid as [Ticket ID],
symptom as [Subject],
uname as [Agent],
sdesc as [Site],
uusername as [User],
rtdesc as [Ticket Type],
tstatusdesc as [Status],
category2 as [Category],
dateoccured  as [Date Opened],
case when slaresponsestate='I' then 'Inside'
when slaresponsestate='O' then 'Outside'
when slaresponsestate is null then 'Awaiting Response' end as [Response State],
frespondbydate as [Response Date],
fixbydate as [Resolution Date]
from faults 
join tstatus on tstatus=status
join requesttype on rtid=requesttypenew 
join area on aarea=areaint
join site on ssitenum=sitenumber
join users on uid=userid
join uname on unum=assignedtoint
where fdeleted=0 and rtisproject=0 and rtisopportunity=0 and areaint=$clientid
