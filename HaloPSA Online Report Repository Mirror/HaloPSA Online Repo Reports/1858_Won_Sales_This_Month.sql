select ohid as [ID],ohorderdate as [Order Date],sum(olorderqty*olsellingprice) as [Total] from orderhead join orderline on olid=ohid and olisgroupdesc=0
group by ohid,ohorderdate
