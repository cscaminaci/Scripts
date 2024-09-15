select * from (
select aareadesc as [Client],
sdesc as [Site],
rtdesc as [Request Type],
isnull((select sum(isnull(timetaken,0)) from actions where actions.faultid in (select faultid from faults where sitenumber=ssitenum and 
requesttypenew=rtid)  and whe_>@startdate and   whe_<@enddate),0) as [Week 1],
isnull((select sum(isnull(timetaken,0)) from actions where actions.faultid in (select faultid from faults where sitenumber=ssitenum and 
requesttypenew=rtid) and whe_+7>@startdate and   whe_+7<@enddate),0) as [Week 2],
isnull((select sum(isnull(timetaken,0)) from actions where actions.faultid in (select faultid from faults where sitenumber=ssitenum and 
requesttypenew=rtid) and whe_+14>@startdate and   whe_+14<@enddate),0) as [Week 3],
isnull((select sum(isnull(timetaken,0)) from actions where actions.faultid in (select faultid from faults where sitenumber=ssitenum and 
requesttypenew=rtid) and whe_+21>@startdate and   whe_+21<@enddate),0) as [Week 4]
 from area join site on sarea=aarea join requesttype on 1=1 where rtid in (select requesttypenew from faults where areaint = aarea))b
  where [week 1]>0 or [week 2]>0 or [week 3]>0 or [week 4]>0

