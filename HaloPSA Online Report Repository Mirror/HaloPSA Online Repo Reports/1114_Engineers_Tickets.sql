select faultid  as [Ticket ID]
	,who as [Agent]
	,round(Sum(timetaken),2) as [Time on Ticket]
	,(select aareadesc from area where aarea=(select areaint from faults where faults.faultid=actions.faultid)) as [Client]
	,(select sdesc from site where Ssitenum=(select sitenumber from faults where faults.faultid=actions.faultid)) as [Site]
from actions
where who in (select uname from uname)
and whe_>@startdate
and whe_<@enddate
group by faultid, who
