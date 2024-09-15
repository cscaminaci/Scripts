select Technician, Date, count(call)-sum(call)as 'Emails', sum(call) as 'Calls' from (select
(case when Actoutcome='Call' then 1 else 0 end)as 'Call'
, who as 'Technician'
, convert(varchar(10),whe_, 103) as 'Date'
from actions 
where (actoutcome='Call' and whe_>@startdate and whe_<@enddate) or (emailto<>'' and who in (select uname from 
uname) and dateemailed>@startdate and dateemailed<@enddate)
)x group by Technician, Date


