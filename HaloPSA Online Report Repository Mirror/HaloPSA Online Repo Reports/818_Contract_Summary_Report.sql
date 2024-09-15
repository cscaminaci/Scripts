select *, cast(round(([Time Used]/[Time Remaining])*100,2)as nvarchar(50)) + '%' as [% Time Used] from
	(select aareadesc as [Customer]
	, cpnumberofunitsfree as [Free Units]
	, round((select sum(timetaken) from actions where actions.faultid in (select faultid from faults where areaint=aarea) and actionbillingplanID=cpid and whe_>@startdate and whe_<@enddate),2) as [Time Used]
	, round(cpnumberofunitsfree-(select sum(timetaken) from actions where actions.faultid in (select faultid from faults where areaint=aarea) and actionbillingplanID=cpid and whe_>@startdate and whe_<@enddate),2) as [Time Remaining]
	from area

	join contractheader 
		on charea=aarea
	join contractplan 
		on chid=cpcontractid
		
		where cpnumberofunitsfree>0)a

