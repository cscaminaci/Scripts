select 

uusername as [Contact],
cast(isnull(CONVERT(DECIMAL(4,2),(select count(faultid) from faults where SLAresponseState='I' and userid=uid
and dateoccured>@startdate and dateoccured<@enddate)/(NULLIF((select count(faultid) from faults
where (SLAresponseState='O' or SLAresponseState='I') and userid=uid and dateoccured>@startdate and 
dateoccured<@enddate)*1.0,0)))*100,100)as integer) as [Response Rate %]

from users
join site on usite=ssitenum
join area on sarea=aarea
where uusername not like '%General User%' and aarea not in (1,12)
