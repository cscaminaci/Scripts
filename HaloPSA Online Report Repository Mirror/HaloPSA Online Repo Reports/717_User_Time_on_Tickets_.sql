select aareadesc as [Client],
sdesc as [Site],
username as [User],
faultid as [Ticket ID],
symptom as [Subject],
symptom2 as [Details],
clearance as [Resolution],
(select sum(isnull(timetaken,0))+sum(isnull(timetakenadjusted,0)) from actions
where actions.faultid=faults.faultid and timetaken>0) as [Time Taken]
from faults join area on aarea=areaint
join site on ssitenum=sitenumber

