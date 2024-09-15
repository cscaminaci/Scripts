select sum([Total]) as [Total],[Sale Type]
from
(
select ohid as [ID],
ohorderdate as [Order Date],
(olorderqty*olsellingprice) as [Total],
case when areaint=1 then 'New Business' else 'Existing Customer' end as [Sale Type]
from orderhead 
join orderline on olid=ohid
join faults on ohfaultid=faultid
where ohorderdate>DATEADD(month, DATEDIFF(month, 0, getdate())-12, 0) and ohorderdate<DATEADD(month, DATEDIFF(month, 0, getdate()), 0)
)b
group by [Sale Type]
