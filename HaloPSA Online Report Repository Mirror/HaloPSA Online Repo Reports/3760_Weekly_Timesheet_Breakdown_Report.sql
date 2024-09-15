select year(date_id) as [Year]
,DATEPART(WEEK,date_id) as [Pd]
,usection as [Team]
,uname as [Agent]
,(select cast(date_id as nvarchar) from CALENDAR c where year(c.date_id)=year(calendar.date_id) and DATEPART(WEEK,c.date_id)=DATEPART(WEEK,calendar.date_id) and weekday_id=1) 
+ ' - ' + (select cast(date_id as nvarchar) from CALENDAR c where year(c.date_id)=year(calendar.date_id) and DATEPART(WEEK,c.date_id)=DATEPART(WEEK,calendar.date_id) and weekday_id=7) as [Date Range]
,cast(Sum(case when act.actioncode>-1 then ACT.timetaken else 0 end) as money) as [Billable]
,cast(Sum(case when act.actioncode=-1 then ACT.timetaken else 0 end) as money) as [Non-Billable]
,cast(isnull(sum(act.timetaken),0) as money) as [Total]
from calendar
left join uname on 1=1
left join (
select dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),Whe_) as [Date]
,year(dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),Whe_)) as [Year]
,DATEPART(WEEK,dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),Whe_)) as [Pd]
,whoagentid
,isnull(timetaken,0) as [Timetaken]
,isnull(timetakenAdjusted,0) as [Adjusted Time]
,actioncode
,ActionBillingPlanID
from actions a
join faults f on a.faultid=f.faultid
join uname on whoagentid=Unum
where whe_>@startdate
and whe_<@enddate
and uisdisabled=0
)ACT on ACT.[Year]=year(date_id) and ACT.[Pd]=DATEPART(WEEK,date_id) and ACT.whoagentid=uname.unum
where weekday_id=1
and date_id>@startdate
and date_id<@enddate

group by year(date_id),DATEPART(WEEK,date_id),usection,uname
