select aareadesc as [Client]
	,(select sum(datediff(hh,dateoccured,datecleared))/count(*) from faults where areaint=aarea and status=9 and dateoccured>@startdate and dateoccured<@enddate and fdeleted=0) as [Average Call Closure Time]
from AREA
