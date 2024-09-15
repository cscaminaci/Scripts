  select faults.faultid as [Ticket ID],
round(isnull(timetaken,0)+isnull(timetakenadjusted,0),2) as [No Charge Time],
(select aareadesc from area where aarea=areaint) as [Client],
whe_ as [When],
symptom as [Subject],
(select uname from uname where unum=assignedtoint) as [Technician]
from faults join actions on actions.faultid=faults.faultid where actioncode=-1 and timetaken>0  and fdeleted=0





