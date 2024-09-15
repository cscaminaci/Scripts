  select faultid as [Ticket ID],
symptom as [Subject],
(select uname from uname where unum=clearwhoint) as [Closed By],
datecleared as [Date Closed],
(select rtdesc from requesttype where rtid=requesttypenew) as [Request Type],
(select aareadesc from area where aarea=areaint) as [Client]
from faults where ffirsttimefix=1 and fdeleted=0


