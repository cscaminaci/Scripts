select
Faults.Faultid as 'Ticket ID',
Username as [Contact],
Symptom as 'Summary',
whe_ as 'Date Re-opened',
note as 'Note',
who 'Who',
sectio_ as 'Team',
(select uname from uname where unum=assignedtoint) as 'Agent'
from Faults 
join Actions on actions.faultid=faults.faultid
where ActionStatusAfter=26 and ActionStatusBefore<>26
