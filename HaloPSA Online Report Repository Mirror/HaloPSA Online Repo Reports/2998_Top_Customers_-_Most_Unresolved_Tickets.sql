select 
aareadesc as 'Customer Name',
count(faultid) as'Unresolved Tickets'

from Faults

join area on faults.areaint = area.aarea
where dateoccured>@startdate and dateoccured<@enddate
and status not in (8,9) and aarea not in (1,12)

group by aareadesc
