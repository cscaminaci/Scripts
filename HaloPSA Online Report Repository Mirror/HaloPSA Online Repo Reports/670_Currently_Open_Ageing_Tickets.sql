select dateoccured as [Date Opened],
faultid as [Ticket ID],
tstatusdesc as [Status],
sectio_ as [Section],
uname as [Technician],
rtdesc as [Ticket Type],
case when getdate()-dateoccured<7 then '0-7 days'
when getdate()-dateoccured<14 then '8-14 days'
when getdate()-dateoccured<28 then '15-28 days'
else '28+ days' end as [Open For]
from faults 
join tstatus on tstatus=status
join uname on unum=assignedtoint
join requesttype on rtid=requesttypenew
where status<>9      and fdeleted=0             


