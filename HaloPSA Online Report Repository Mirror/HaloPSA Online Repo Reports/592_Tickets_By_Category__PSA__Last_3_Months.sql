 select
    category2 as [Category],
    count(faultid) as [# Tickets]
from
faults
left join area on aarea=areaint
                       
where dateoccured between @startdate and @enddate and CFProduct=2


group by category2 
