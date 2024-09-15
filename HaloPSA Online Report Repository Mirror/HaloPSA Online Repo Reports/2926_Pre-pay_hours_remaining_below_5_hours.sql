select *
,case when (([Total Time]-[Time Used])-floor([Total Time]-[Time Used]))*0.6=0 then cast([Total Time]-[Time Used] as nvarchar)
else cast(floor([Total Time]-[Time Used]) as nvarchar) + ':' + cast((([Total Time]-[Time Used])-floor([Total Time]-[Time Used]))*60 as nvarchar) end as [Time Remaining]
, [Total Time] - [Time Used] as 'Decimal Hours Remaining'
from (

SELECT aareadesc as [Client] 
,(select sum(pphours) from PREPAYHISTORY where ppareaint=Areaint) as [Total Time]
,isnull(sum(isnull(ActionPrePayHours, 0)), 0) as [Time Used]
FROM actions
JOIN faults ON actions.faultid = faults.faultid
join area on Areaint=Aarea
group by aareadesc,Areaint)d
where [Total Time]>0
