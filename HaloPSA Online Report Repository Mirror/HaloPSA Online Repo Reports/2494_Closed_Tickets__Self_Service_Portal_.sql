select
faultid as [Ticket ID],
symptom as [Subject],
rtdesc as [Type],
category2 as [Category],
dateoccured  as [Date Opened],
datecleared as [Date Closed]
from faults 
join requesttype on rtid=requesttypenew 
where fdeleted=0 and rtisproject=0 and rtisopportunity=0 and status=9 and areaint=$clientid
