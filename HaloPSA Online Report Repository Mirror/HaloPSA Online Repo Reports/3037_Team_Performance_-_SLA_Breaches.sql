select faultid as 'Ticket ID',
	symptom as 'Summary',
	uname as 'Agent',
        sectio_ as 'Team',
        dateoccured as [Date Logged],
(select tstatusdesc from tstatus where tstatus=status) as [Status],
	dbo.GetSLATimeLeft(fixbydate,slaid) as 'SLA Time Left'
from faults
left join uname on unum = assignedtoint
where status not in (8,9) and fexcludefromsla=0 and fdeleted=0
