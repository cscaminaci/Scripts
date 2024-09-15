select uname as [Agent],
faults.faultid as [Ticket ID],
symptom as [Ticket Summary],
sdesc as [Site],
CASE WHEN TimeSpent<1 THEN cast(round(Timespent*60,0) as nvarchar)+' mins' ELSE cast(round(TimeSpent,1) as nvarchar)+' hours' END as [Time Spent]
from faults
left join site on sitenumber=ssitenum
outer apply (select whoagentid, sum(timetaken)TimeSpent from actions where actions.faultid=faults.faultid and whe_ >@startdate and whe_<@enddate group by whoagentid)tt
inner join uname on unum=whoagentid and unum>1

