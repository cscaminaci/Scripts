 select
(select aareadesc from area where areaint=aarea) as 'Client',
(select sdesc from site where sitenumber=ssitenum) as 'Site',
(select count(faultid) from Faults where sitenumber=ssitenum and Status<>9)as'Open Tickets',
(select count(faultid) from Faults where sitenumber=ssitenum and dateoccured>@startdate and dateoccured<@enddate)as'Logged Tickets',
(select count(faultid) from Faults where sitenumber=ssitenum and status=9 and datecleared>@startdate and datecleared<@enddate)as'Closed Tickets'
from Faults inner join site on sitenumber=ssitenum
group by areaint,ssitenum,sitenumber



