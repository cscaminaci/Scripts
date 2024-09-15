	select (select round(sum(isnull(timetaken,0)+isnull(timetakenadjusted,0)),2) from actions where faultid in (select faultid from faults where areaint=aarea and dateoccured > @startdate and dateoccured < @enddate)) as [Total Time Spent]
	, aareadesc as [Client Name]
	from area 
	group by aareadesc, aarea

