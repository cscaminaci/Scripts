select convert(nvarchar,tsdate,103) as [Date]
,tsdate
,uname as [Agent]
,TSstartdate as [Start Time]
,TSenddate as [Finish Time]
,round(cast(DATEDIFF(MINUTE,TSstartdate,TSenddate) as float)/60,2) as [Hours Worked]
,round(sum(timetaken),2) as [Hours Logged]
from Timesheet
left join uname on TSunum=Unum
left join actions on whoagentid=unum and  dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),actionarrivaldate)   between 
tsdate
and 
dateadd(day, 1, tsdate)  
where timetaken>0
group by tsdate,uname,TSstartdate,TSenddate
