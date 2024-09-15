select faults.faultid as [Ticket ID],
(select replace(cast(convert(decimal(10,2),cast((isnull(timetaken,0)+isnull(timetakenadjusted,0))  as int)+
((((isnull(timetaken,0)+isnull(timetakenadjusted,0)) -cast((isnull(timetaken,0)+isnull(timetakenadjusted,0))  as 
int))*.60))) as varchar),'.',':')) as [No Charge Time], 
(select aareadesc from area where aarea=areaint) as [Client],
whe_ as [When],
symptom as [Subject],
(select uname from uname where unum=assignedtoint) as [Technician]                            
from faults join actions on actions.faultid=faults.faultid where actioncode=-1 and timetaken>0





