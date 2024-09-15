select
uname as [Technician],
sectio_ as [Team],
area.aareadesc as [Client Name],
sdesc as [Site Name], 
username as [Username],
rtdesc as [Request Type],
faults.faultid as [Request ID], 
whe_ as [Date/Time Done], 
round(timetaken,2) as [Time Taken], 
Actoutcome as [Outcome],
note  as [Note]
from actions
left join faults on actions.faultid=faults.faultid
left join site on ssitenum=sitenumber
left join area on aarea=sarea 
left join uname on who=uname
left join requesttype on rtid=requesttypenew

