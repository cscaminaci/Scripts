Select 
faultid as [Ticket ID],
uname as [Agent],
aareadesc as [Customer],
flastactiondate as [Last Action Date],
symptom as [Summary],
rtdesc as [Ticket Type]
from faults left join area on areaint=aarea left join uname on unum=assignedtoint left join requesttype on rtid = requesttypenew
where fmergedintofaultid = 0 and fdeleted= 0 and status = 24
