select faultid as [Ticket ID],
(select aareadesc from area where aarea=areaint) as [Client],
datecleared as [Date Closed],
dateoccured as [Date Opened],
symptom as [Subject]
from faults where (select count(actionnumber) from actions where actions.faultid=faults.faultid and actoutcome='Closed via merge')>0


