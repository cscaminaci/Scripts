select

sectio_ as Team,
(select sum(cast(timetaken+nonbilltime as float)) from actions 
where whe_>'2013-01-01') as 'Time Taken'
from faults 
where dateoccured>@startdate and dateoccured<@enddate
group by sectio_
