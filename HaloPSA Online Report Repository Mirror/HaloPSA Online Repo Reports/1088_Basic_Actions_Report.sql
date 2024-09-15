select
Faultid as [Ticket ID]
,Actoutcome as [Action Type]
,(select uname from uname where who = uname) as [Technician]
,Whe_ as [Date/Time]
,note as [Note]
,timetaken as [Time]
from actions
where whe_ > @startdate and whe_ < @enddate
