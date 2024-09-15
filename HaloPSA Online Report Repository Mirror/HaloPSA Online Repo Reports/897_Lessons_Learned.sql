select 
faultid as [Ticket ID],
flessonslearned as [Lessons Learned],
datecleared as [Date Closed]
from faults where
cast(flessonslearned as nvarchar(10))<>''

