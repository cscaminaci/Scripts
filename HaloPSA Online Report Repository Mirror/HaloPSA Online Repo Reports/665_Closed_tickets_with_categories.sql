select faultid as [Ticket ID],
(select aareadesc from area where aarea=areaint) as [Client],
datecleared as [Date Closed],
dateoccured as [Date Opened],
symptom as [Subject],
(select sum(isnull(timetaken,0)+isnull(timetakenadjusted,0)) from actions where actions.faultid=faults.faultid)
as [Total Time (Decimal Hrs)],
Category2 as [Category 1],
Category3 as [Category 2],
Category4 as [Category 3],
Category5 as [Category 4]
from faults where status=9

