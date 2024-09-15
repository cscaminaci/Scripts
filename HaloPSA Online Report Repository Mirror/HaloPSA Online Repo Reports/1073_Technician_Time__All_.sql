select uname as [Technician]
	,(select round(sum(timetaken),2) from actions where who = uname and whe_ > @startdate and whe_ < @enddate and (select weekday_id from calendar where convert(nvarchar(10),whe_,120)=date_id) = 2) as [Monday Time]
	,(select round(sum(timetaken),2) from actions where who = uname and whe_ > @startdate and whe_ < @enddate and (select weekday_id from calendar where convert(nvarchar(10),whe_,120)=date_id) = 3) as [Tuesday Time]
	,(select round(sum(timetaken),2) from actions where who = uname and whe_ > @startdate and whe_ < @enddate and (select weekday_id from calendar where convert(nvarchar(10),whe_,120)=date_id) = 4) as [Wednesday Time]
	,(select round(sum(timetaken),2) from actions where who = uname and whe_ > @startdate and whe_ < @enddate and (select weekday_id from calendar where convert(nvarchar(10),whe_,120)=date_id) = 5) as [Thursday Time]
	,(select round(sum(timetaken),2) from actions where who = uname and whe_ > @startdate and whe_ < @enddate and (select weekday_id from calendar where convert(nvarchar(10),whe_,120)=date_id) = 6) as [Friday Time]
	,(select round(sum(timetaken),2) from actions where who = uname and whe_ > @startdate and whe_ < @enddate and (select weekday_id from calendar where convert(nvarchar(10),whe_,120)=date_id) = 7) as [Saturday Time]
	,(select round(sum(timetaken),2) from actions where who = uname and whe_ > @startdate and whe_ < @enddate and (select weekday_id from calendar where convert(nvarchar(10),whe_,120)=date_id) = 1) as [Sunday Time]
	,(select round(sum(timetaken),2) from actions where who = uname and whe_ > @startdate and whe_ < @enddate) as [Total Time]
from uname 
where Uisdisabled = 0
