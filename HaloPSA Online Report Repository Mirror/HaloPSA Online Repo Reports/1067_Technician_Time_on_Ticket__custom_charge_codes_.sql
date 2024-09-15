select 
	[Client]
	,[Site]
	,[ID]
	,[Technician]
	,round(sum([NCT]),2) as [Non-Chargeable Time]
	,round(sum([CT]),2) as [Chargeable Time]
from(
select
	 [Client]
	,[Site]
	,[ID]
	,[Technician]
	,CASE when actioncode+1 in (0,3,4,6) then [Time Taken]
		ELSE 0
		END as [NCT]
	,CASE when actioncode+1 in (1,2,5) then [Time Taken]
		ELSE 0
		END as [CT]
from(
select
(select aareadesc from area where Areaint=aarea) as [Client]
,(select sdesc from site where ssitenum=sitenumber) as [Site]
,faults.faultid as [ID]
, sum(timetaken) as [Time Taken]
, uname as [Technician]
, actioncode
from faults
join actions on actions.faultid=faults.faultid
join uname on actions.who=uname.uname
where dateoccured between @startdate and @enddate
group by faults.faultid,uname,actioncode,areaint,sitenumber)d
)d
group by [ID],[Technician],[NCT],[CT],[Client],[Site]
