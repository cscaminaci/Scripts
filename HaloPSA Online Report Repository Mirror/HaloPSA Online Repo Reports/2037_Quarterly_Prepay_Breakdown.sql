select 
date_id as [Start of Month]
,month_nm+' '+cast(date_year as nvarchar(4)) as [Month/Year]
, [Customer]
,isnull((select sum(pphours) from Prepayhistory where aarea=ppareaint and ppdate>start_dts and ppdate<=dateadd(day,1,eomonth(dateadd(month,2,last_day_of_month)))),0) as [Bought],
isnull((select sum(actionprepayhours) from actions join faults on faults.faultid=actions.faultid and aarea=areaint and whe_>start_dts and whe_<dateadd(day,1,eomonth(dateadd(month,2,last_day_of_month)))),0)  as [Used],
isnull((select sum(pphours) from Prepayhistory where aarea=ppareaint and ppdate<dateadd(day,1,eomonth(dateadd(month,2,last_day_of_month))))-
(select sum(actionprepayhours) from actions join faults on faults.faultid=actions.faultid and aarea=areaint and whe_<dateadd(day,1,eomonth(dateadd(month,2,last_day_of_month)))),0)  as [Running Total] from (
select aarea,aareadesc as [Customer]
,(select min(ppdate) from Prepayhistory where aarea=ppareaint) as [First Pre Pay]
from area 
)b
join calendar on date_id=cast([First Pre Pay] as date) or (date_month-datepart(month,(select min(ppdate) from Prepayhistory where aarea=ppareaint))) % 3 = 0
where date_day=1
and dateadd(month,1,date_id)>=(select min(ppdate) from Prepayhistory where aarea=ppareaint)
and date_id<getdate()+32

