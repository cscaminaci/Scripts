select 
aareadesc as 'Customer Name',
count(faultid) as'Resolved Tickets'

from Faults

join area on faults.areaint = area.aarea
where dateoccured>@startdate and dateoccured<@enddate
and status in (8,9)

group by aareadesc
