select 
 aareadesc as [Customer]
, chcontractref as [Contract]
, cast([PeriodStart] as date) [Period Start Date]
, MONTH([PeriodStart]) AS [Month]
, cast ([PeriodEnd]-1 as date) [Period End Date]
, round([HoursAvailable],2) as [Available Hours]
, round([PeriodTimeUsage],2) as [Time Usage]
, round([Balance],2) as [Hour Balance]
, case when (cast((([HoursAvailable])-floor([HoursAvailable]))*60 as nvarchar))<10 then cast(floor([HoursAvailable]) as nvarchar) + ':0' + cast((([HoursAvailable])-floor([HoursAvailable]))*60 as nvarchar) 
else cast(floor([HoursAvailable]) as nvarchar) + ':' + cast((([HoursAvailable])-floor([HoursAvailable]))*60 as nvarchar) end as [Hours Available]
, case when (cast((([PeriodTimeUsage])-floor([PeriodTimeUsage]))*60 as nvarchar))<10 then cast(floor([PeriodTimeUsage]) as nvarchar) + ':0' + cast((([PeriodTimeUsage])-floor([PeriodTimeUsage]))*60 as nvarchar) 
else cast(floor([PeriodTimeUsage]) as nvarchar) + ':' + cast((([PeriodTimeUsage])-floor([PeriodTimeUsage]))*60 as nvarchar) end as [Hours Used] 
, case when (cast((([Balance])-floor([Balance]))*60 as nvarchar))<10 then cast(floor([Balance]) as nvarchar) + ':0' + cast((([Balance])-floor([Balance]))*60 as nvarchar) 
else cast(floor([Balance]) as nvarchar) + ':' + cast((([Balance])-floor([Balance]))*60 as nvarchar) end as [Balance] 

from
(select p.*
, isnull(chprepayrecurringhours,0)*[Row] [Total Hours Added]
, isnull(((isnull(chprepayrecurringhours,0)*[Row])-[previoususage]-[PeriodTimeUsage]),0) [Balance]
, (Case when [row]=1 then chprepayrecurringhours else (isnull(chprepayrecurringhours,0)*([Row]))-[previoususage] end) [HoursAvailable]

from
(select ppdate [PeriodStart]
, (dateadd(mm,1,ppdate)) [PeriodEnd]
, ppareaint [AreaID]
, pphours [PeriodicHoursAdded]
, ppcontractid [ContractID]
, chcontractref
, chprepayrecurringhours
, isnull((select sum(isnull(actionprepayhours,0)) from actions a 
    join faults f on f.faultid=a.faultid
    where fdeleted=0 
    and actionprepayhours>0 
    and areaint=ppareaint
    and whe_ between ppdate-1 and (dateadd(mm,1,ppdate)-1)),0) [PeriodTimeUsage]
, isnull((select sum(isnull(actionprepayhours,0)) from actions a 
    join faults f on f.faultid=a.faultid
    where fdeleted=0 
    and actionprepayhours>0 
    and areaint=ppareaint
    and whe_  between chstartdate and (dateadd(mm,1,ppdate))),0) [Total Usage]
, isnull((select sum(isnull(actionprepayhours,0)) from actions a 
    join faults f on f.faultid=a.faultid
    where fdeleted=0 
    and actionprepayhours>0 
    and areaint=ppareaint
    and whe_  between chstartdate and ppdate),0)[totalperiodstart]
, isnull((select sum(isnull(actionprepayhours,0)) from actions a 
    join faults f on f.faultid=a.faultid
    where fdeleted=0 
    and actionprepayhours>0 
    and areaint=ppareaint
    and whe_<ppdate-1),0) [PreviousUsage]
, row_number() over (partition by ppareaint order by ppdate asc) [row]
from prepayhistory
join contractheader on ppcontractid=chid
) p
) q 

join area on [AreaID]=aarea

where dateadd(mm,0,[PeriodStart])between @startdate and @enddate
