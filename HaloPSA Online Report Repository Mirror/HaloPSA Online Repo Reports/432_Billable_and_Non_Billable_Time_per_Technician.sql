select whe_ as [Date],
uname as [Agent],
timetaken as [Hours],
timetaken+timetakenadjusted as [Hours (with rounding)],
case when actionchargehours>0 then 'Billable' else 'Non-Billable' end as [Billable?]
from faults
join actions on faults.faultid=actions.faultid
join uname on unum=assignedtoint

