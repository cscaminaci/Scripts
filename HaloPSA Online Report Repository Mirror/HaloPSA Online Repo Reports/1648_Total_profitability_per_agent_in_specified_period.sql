
select 
[Agent],
round(sum([Hours]),2) as [Total Hours],
round(sum([Cost]),2) as [Total Cost],
round(sum([Price]),2) as [Total Revenue],
round(sum([Price])-sum([Cost]),2) as [Total Profit],
round((sum([Cost]))/sum([Hours]),2) as [Cost per hour],
round((sum([Price]))/sum([Hours]),2) as [Revenue per hour],
round((sum([Price])-sum([Cost]))/sum([Hours]),2) as [Proft per hour]
from(
select
uname as [Agent],
actionchargehours as [Hours],
ucostprice*actionchargehours as [Cost],
ActionChargeAmount as [Price]
from uname
join ACTIONS on unum=whoagentid
where actionchargehours>0
and whe_>@startdate and whe_<@enddate
)b
group by [Agent]


