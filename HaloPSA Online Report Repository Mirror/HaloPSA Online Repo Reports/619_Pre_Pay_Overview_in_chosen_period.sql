select Client,Total,[Top Up],(isnull((select sum(pphours) from Prepayhistory where  ppareaint=b.areaint and ppdate<@enddate),0)-
(select round(isnull(sum(isnull(actionprepayhours,0)),0),2) from actions where whe_<@enddate and actions.faultid in (select faultid from faults where areaint=b.areaint) )) as [Balance]
from(
select aareadesc as [Client],
areaint,
round(isnull(sum(isnull(actionprepayhours,0)),0),2) as [Total],
(select isnull(sum(pphours),0) from Prepayhistory where  ppareaint=areaint and ppdate>@startdate and ppdate<@enddate) as [Top Up]
from actions join faults on actions.faultid=faults.faultid join area on aarea=areaint
where whe_>@startdate and whe_<@enddate and actionprepayhours>0
group by aareadesc,areaint)b

