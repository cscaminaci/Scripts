  select count(faultid) as [Total Opened], rtdesc as [Ticket Type]
from faults join requesttype on requesttypenew=rtid
where dateoccured>@startdate and dateoccured<@enddate and frequestsource=1
group by rtdesc

