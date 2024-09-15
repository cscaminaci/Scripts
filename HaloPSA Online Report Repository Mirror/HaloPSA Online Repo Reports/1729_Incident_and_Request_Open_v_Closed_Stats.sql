
select case when f.requesttype=1 then 'Incident' when f.requesttype=3 then 'Service Request' end as [Ticket type]
,count(a.requesttype) as [Opened]
,count(b.requesttype) as [Closed]
,cast(round(cast(count(b.requesttype)as float)/isnull(cast(count(a.requesttype) as float),0)*100,2) as nvarchar) +'%' as [Percent Closed]
from faults f
left join (select requesttype, faultid as [Opened] from faults where dateoccured>@startdate and dateoccured<@enddate)a on a.Opened=f.Faultid
left join (select requesttype, faultid as [Closed] from faults where datecleared>@startdate and datecleared<@enddate)b on b.Closed=f.Faultid
where FDeleted=0
and FMergedIntoFaultid=0
and f.requesttype in (1,3)
group by f.requesttype


