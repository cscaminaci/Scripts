Select
 aareadesc as [Customer],
 faultid as [Ticket ID],
 dateoccured as [Date Logged],
 symptom as [Summary],
 symptom2 as [Details],
 rtdesc as [Ticket Type]
from faults left join area on areaint = aarea left join requesttype on rtid = requesttypenew
where fdeleted =0 and fmergedintofaultid=0 and status not in (8,9)
