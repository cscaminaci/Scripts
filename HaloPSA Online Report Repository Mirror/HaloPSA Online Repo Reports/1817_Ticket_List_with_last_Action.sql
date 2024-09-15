select
Faultid as 'Ticket ID',
(select sdesc from site where ssitenum=sitenumber) as 'Site',
Username,
Symptom as 'Summary',
(select top 1 note from actions where actions.faultid=faults.faultid order by actionnumber desc) as 'Last Action',
(select top 1 who from actions where actions.faultid=faults.faultid order by actionnumber desc) as 'By Who',
sectio_ as 'Section',
(select uname from uname where unum=assignedtoint) as 'Technician',
dateoccured as 'Date Occurred',
fAttachmentCount as 'Attachment Count'
from Faults
where isnull(fdeleted,0)<>1
