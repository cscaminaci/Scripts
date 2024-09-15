select dateoccured as [Date Opened],
faultid as [Ticket ID],
tstatusdesc as [Status],
sectio_ as [Section],
uname as [Technician],
case when datecleared-dateoccured<7 then '0-7 days' 
when datecleared-dateoccured<14 then '8-14 days' 
when datecleared-dateoccured<28 then '15-28 days'  
else '28+ days' end as [Open For]
from faults 
join tstatus on tstatus=status
join uname on unum=assignedtoint
where dateoccured>@Startdate and dateoccured<@enddate
and fdeleted=0 and status <>9

