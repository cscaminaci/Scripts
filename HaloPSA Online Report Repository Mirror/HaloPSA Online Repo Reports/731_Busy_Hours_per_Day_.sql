select top 100 percent count(faultid) as [Tickets], [Date + Time], [Time], [Day], [Day of Year], [Order], [Date], [Time to Add] from (

select 
faultid, 
cast(DATEPART(hh,dateoccured) as nvarchar)+':00' as [Time], 
cast(format(dateoccured, 'dd/MM/yyyy') as nvarchar) + ' ' + cast(DATEPART(hh,dateoccured) as nvarchar)+':00' as [Date + Time],
weekday_nm as [Day],
day_of_year as [Day of Year],
DATEPART(hh,dateoccured) as [Time to Add],
(day_of_year*10)+DATEPART(hh,dateoccured) as [Order],
cast(format(dateoccured, 'dd/MM/yyyy') as nvarchar) [Date]

from faults join calendar on convert(date,dateoccured,103)=date_id
where dateoccured>@startdate and dateoccured<@enddate

)a

group by [Date + Time], [Time], [Day], [Day of Year] ,[Order], [Date], [Time to Add]

order by [Order] desc

/* OLD QUERY;

select count(faultid) as Count, 
cast(DATEPART(hh,dateoccured) as nvarchar)+':00' as Time, 
weekday_nm as Day,
left(weekday_nm,3)+' '+cast(DATEPART(hh,dateoccured) as nvarchar)+':00' as DayTime,
weekday_id*24+DATEPART(hh,dateoccured) as DayOrder
from faults join calendar on convert(date,dateoccured,103)=date_id
where dateoccured>@startdate and dateoccured<@enddate
group by DATEPART(hh,dateoccured),weekday_nm,weekday_id

*/



