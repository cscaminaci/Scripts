select aareadesc as [Client]
	,(select count(*) from faults where aarea=areaint and dateoccured>@startdate and dateoccured<@enddate) as [Number of Tickets]
	,round((select sum(timetaken) from actions where faultid in (select faultid from faults where aarea=areaint and dateoccured>@startdate and dateoccured<@enddate)) / nullif((select count(*) from faults where aarea=areaint and dateoccured>@startdate and dateoccured<@enddate),0),2) as [Average Closure Time]
	,round((select sum(fresponsetime) from faults where aarea=areaint and dateoccured>@startdate and dateoccured<@enddate) / nullif((select count(*) from faults where aarea=areaint and dateoccured>@startdate and dateoccured<@enddate),0),2) as [Average Response Time]
from area
