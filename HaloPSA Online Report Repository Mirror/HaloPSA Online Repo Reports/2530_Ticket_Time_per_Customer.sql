select actions.faultid as [Ticket ID]
, isnull(round(sum(timetaken),2),0) as [Time Taken]
, who as [Technician]
, aareadesc as [Customer]
from ACTIONS
join faults on faults.faultid=actions.faultid
join area on aarea=areaint

where whe_>=@startdate and whe_<@enddate and timetaken>0


group by actions.faultid,who, aareadesc 

