select faultid as [Ticket ID],
symptom as [Subject],
sectio_ as [Team],
dateoccured as [Date Opened],
(select tstatusdesc from tstatus where tstatus=status) as [Status],
category2 as [Category 1],
category3 as [Category 2],
category4 as [Category 3],
category5 as [Category 4]
from faults
where status<>9


