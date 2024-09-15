select 
aareadesc as [Client],
cast(sum(actionchargeamount) as money) as [Billed Time],
isnull(cast(sum(ppamount)*count(distinct ppid)/count(actions.faultid) as money),0) as [Pre-Pay Time],
cast(sum(actionchargeamount) + isnull(sum(ppamount)*count(distinct ppid)/count(actions.faultid),0) as money) as [Total Time]
from actions 
join faults on actions.faultid=faults.faultid
join area on aarea=areaint
left join prepayhistory on ppareaint=aarea
where (actprocesseddate between @startdate and @enddate or ppdate between @startdate and @enddate)
group by aareadesc,aarea
