 select top 20 username as 'Username', 
count(faultid)Tickets 
from faults 
where dateoccured>@startdate and dateoccured<@enddate
group by username order by count(faultid) desc     
