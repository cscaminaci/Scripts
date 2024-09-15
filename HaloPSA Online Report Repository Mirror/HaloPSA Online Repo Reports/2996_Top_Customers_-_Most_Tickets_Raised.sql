select 
aareadesc as 'Customer Name',
count(faultid) as'Logged Tickets'

from Faults

join area on faults.areaint = area.aarea
where dateoccured>@startdate and dateoccured<@enddate and aarea not in (1,12)

group by aareadesc
