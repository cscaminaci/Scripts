         select faults.faultid as [Ticket ID],
actions.nonbilltime as [Non Billable Time],
(select aareadesc from area where aarea=areaint) as [Client],
whe_ as [When],
symptom as [Subject]  ,
(select uname from uname where unum=assignedtoint) as [Technician]
from faults join actions on actions.faultid=faults.faultid where actions.nonbilltime>0  and fdeleted=0



