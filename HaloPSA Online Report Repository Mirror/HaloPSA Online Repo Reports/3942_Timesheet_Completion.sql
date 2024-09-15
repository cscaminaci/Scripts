select [Agent],[Date],[Day],
case when [Timesheet Started]>0 then 'Complete' else 'Incomplete' end as [Timesheet Start],
case when [Timesheet Ended]>0 then 'Complete' else 'Incomplete' end as [Timesheet End]
from
(select distinct
uname as [Agent],
date_id as [Date], 
weekday_nm as [Day],
(select count(tsstartdate) from timesheet where tsunum=unum and CONVERT(DATE,tsstartdate)=date_id) as [Timesheet Started],
(select count(tsenddate) from timesheet where tsunum=unum and CONVERT(DATE,tsenddate)=date_id) as [Timesheet Ended]
from calendar
join uname on 1=1
where uisdisabled=0 and date_id between @startdate and @enddate and weekday_id not in (7,1) and uname not like 'Unassigned')a
