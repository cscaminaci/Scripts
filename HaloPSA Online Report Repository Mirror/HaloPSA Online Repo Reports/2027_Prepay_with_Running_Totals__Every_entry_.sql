select whe_ as [Date],round(ActionPrePayHours,2) as [Hours],aareadesc as [Customer],
round((select sum(pphours) from Prepayhistory hp where hp.ppareaint=f.Areaint and hp.ppdate<=a.Whe_)
-
(select sum(ha.actionprepayhours) from actions ha join faults hf on hf.faultid=ha.faultid where ha.whe_<=a.whe_ and f.Areaint=hf.areaint),2)  as [Running Total] , 'Labour' as [Type]
from actions a
join faults f on a.faultid=f.Faultid
join area on aarea=f.Areaint
where ActionPrePayHours>0
union all
select top 100 percent ppdate as [Date],round(pphours,2) as [Hours],aareadesc as [Customer],
round((select sum(pphours) from Prepayhistory hp where hp.ppareaint=pp.ppareaint and hp.ppdate<=pp.ppdate)
-
(select sum(ha.actionprepayhours) from actions ha join faults hf on hf.faultid=ha.faultid where ha.whe_<=ppdate and ppareaint=hf.areaint),2)
 as [Running Total] , 'Top up' as [Type] 
 from Prepayhistory as pp
 join area on aarea=pp.ppareaint
