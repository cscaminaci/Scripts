select 
uusername as 'Contact Name',
count(faultid) as'Unresolved Tickets'

from Faults

join users on faults.userid = users.uid

where dateoccured>@startdate and dateoccured<@enddate
and status not in (8,9)

group by uusername
