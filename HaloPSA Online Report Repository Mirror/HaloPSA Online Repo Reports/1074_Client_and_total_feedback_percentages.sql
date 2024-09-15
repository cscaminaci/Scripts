
select aareadesc as [Client]
	,(select count(*) from feedback where FBScore=1 and FBDate>@startdate and FBDate<@enddate and FBFaultID in (select faultid from faults where aarea=areaint )) as [Awesome]
	,cast(round((select cast(count(*) as real) from feedback where FBScore=1 and FBDate>@startdate and FBDate<@enddate and FBFaultID in (select faultid from faults where aarea=areaint ))/nullif((select cast(count(*) as real) from feedback where FBFaultID in (select faultid from faults where aarea=areaint ) and FBDate>@startdate and FBDate<@enddate),0)*100,2) as nvarchar) + '%' as [% Awesome]
	,(select count(*) from feedback where FBScore=2 and FBDate>@startdate and FBDate<@enddate and FBFaultID in (select faultid from faults where aarea=areaint )) as [Good]
	,cast(round((select cast(count(*) as real) from feedback where FBScore=2 and FBDate>@startdate and FBDate<@enddate and FBFaultID in (select faultid from faults where aarea=areaint ))/nullif((select cast(count(*) as real) from feedback where FBFaultID in (select faultid from faults where aarea=areaint ) and FBDate>@startdate and FBDate<@enddate),0)*100,2) as nvarchar) + '%' as [% Good]
	,(select count(*) from feedback where FBScore=3 and FBDate>@startdate and FBDate<@enddate and FBFaultID in (select faultid from faults where aarea=areaint )) as [OK]
	,cast(round((select cast(count(*) as real) from feedback where FBScore=3 and FBDate>@startdate and FBDate<@enddate and FBFaultID in (select faultid from faults where aarea=areaint ))/nullif((select cast(count(*) as real) from feedback where FBFaultID in (select faultid from faults where aarea=areaint ) and FBDate>@startdate and FBDate<@enddate),0)*100,2) as nvarchar) + '%' as [% OK]
	,(select count(*) from feedback where FBScore=4 and FBDate>@startdate and FBDate<@enddate and FBFaultID in (select faultid from faults where aarea=areaint )) as [Bad]
	,cast(round((select cast(count(*) as real) from feedback where FBScore=4 and FBDate>@startdate and FBDate<@enddate and FBFaultID in (select faultid from faults where aarea=areaint ))/nullif((select cast(count(*) as real) from feedback where FBFaultID in (select faultid from faults where aarea=areaint ) and FBDate>@startdate and FBDate<@enddate),0)*100,2) as nvarchar) + '%' as [% Bad]
from area

UNION

Select ' Total' as [Client]
	,(select count(*) from feedback where FBScore=1 and FBFaultID in (select faultid from faults) and FBDate>@startdate and FBDate<@enddate) as [Awesome]
	,cast(round((select cast(count(*) as real) from feedback where FBScore=1 and FBFaultID in (select faultid from faults ) and FBDate>@startdate and FBDate<@enddate)/nullif((select cast(count(*) as real) from feedback where FBFaultID in (select faultid from faults) and FBDate>@startdate and FBDate<@enddate),0)*100,2) as nvarchar) + '%' as [% Awesome]
	,(select count(*) from feedback where FBScore=2 and FBFaultID in (select faultid from faults ) and FBDate>@startdate and FBDate<@enddate) as [Good]
	,cast(round((select cast(count(*) as real) from feedback where FBScore=2 and FBFaultID in (select faultid from faults) and FBDate>@startdate and FBDate<@enddate)/nullif((select cast(count(*) as real) from feedback where FBFaultID in (select faultid from faults) and FBDate>@startdate and FBDate<@enddate),0)*100,2) as nvarchar) + '%' as [% Good]
	,(select count(*) from feedback where FBScore=3 and FBFaultID in (select faultid from faults ) and FBDate>@startdate and FBDate<@enddate) as [OK]
	,cast(round((select cast(count(*) as real) from feedback where FBScore=3 and FBFaultID in (select faultid from faults) and FBDate>@startdate and FBDate<@enddate)/nullif((select cast(count(*) as real) from feedback where FBFaultID in (select faultid from faults) and FBDate>@startdate and FBDate<@enddate),0)*100,2) as nvarchar) + '%' as [% OK]
	,(select count(*) from feedback where FBScore=4 and FBFaultID in (select faultid from faults ) and FBDate>@startdate and FBDate<@enddate) as [Bad]
	,cast(round((select cast(count(*) as real) from feedback where FBScore=4 and FBFaultID in (select faultid from faults) and FBDate>@startdate and FBDate<@enddate)/nullif((select cast(count(*) as real) from feedback where FBFaultID in (select faultid from faults) and FBDate>@startdate and FBDate<@enddate),0)*100,2) as nvarchar) + '%' as [% Bad]
from area
