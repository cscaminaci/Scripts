select
(select aareadesc from area where aarea=areaint) as [Client],
(select aisinactive from area where aarea=areaint) as [Inactive],
count(faultid) as [Open Tickets]
from faults
where status <> 9
group by areaint




