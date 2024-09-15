select top 5 category2 as [Category]
,count(faultid) as [Ticket Count]
from faults f

where FDeleted=0
and FMergedIntoFaultid=0
and f.requesttype in (3)
and dateoccured>@startdate and dateoccured<@enddate
and category2 <> ''
group by category2
order by count(faultid) desc
