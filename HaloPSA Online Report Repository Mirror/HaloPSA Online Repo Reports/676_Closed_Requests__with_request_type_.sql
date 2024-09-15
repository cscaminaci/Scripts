select
aareadesc as [Client],
sdesc as [Site],
username as [Username],
faultid as [Ticket ID],
rtdesc as [Ticket Type],
symptom as [Subject],
cast(clearance as nvarchar(500)) as [Clearance],
datecleared as [Date Cleared],
uname as [Cleared By]
from faults
join area on aarea=areaint
join site on ssitenum=sitenumber
join requesttype on rtid=requesttypenew
join uname on unum=clearwhoint
