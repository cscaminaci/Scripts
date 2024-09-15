select count(afaultid) [Logged today], count(cfaultid) [Of which closed today] , count(bfaultid) as [Closed], count(dfaultid) as [Assigned] 
, count(efaultid) as [engineer calls] , count(ffaultid) as [Unassigned], count(gfaultid) as [Open calls]

from faults 

left join (select faultid afaultid from faults where dateoccured>@startdate and dateoccured<@enddate)a on faultid=afaultid
left join (select faultid bfaultid from faults where datecleared>@startdate and datecleared<@enddate)b on bfaultid=faultid
left join (select faultid cfaultid from faults where dateoccured>@startdate and dateoccured<@enddate and datecleared>@startdate and datecleared<@enddate)c on cfaultid=faultid
left join (select faultid dfaultid from faults where assignedtoint<>1 and dateoccured>@startdate and dateoccured<@enddate)d on faultid=dfaultid
left join (select faultid efaultid from faults where assignedtoint<>1 and status not in (8,9))e on efaultid=faultid 
left join (select faultid ffaultid from faults where assignedtoint=1 and status not in (8,9))f on ffaultid=faultid 
left join (select faultid gfaultid from faults where status not in (8,9))g on gfaultid=faultid 
where FDeleted=0
