
select Faultid as [Ticket ID]
,dateoccured as [Date Created]
,username as [User]
,Symptom as [Summary]
,(select uname from uname where unum=Assignedtoint) as [Agent]
from faults 
where fdeleted=0 
and FMergedIntoFaultid=0 
and cast(dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),dateoccured)  as date)>@startdate 
and cast(dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),dateoccured)  as date)<@enddate 
and (cast(cast(dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),dateoccured)  as datetime) as time) > cast('17:00:00' as time) 
or cast(cast(dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),dateoccured)  as datetime) as time) < cast('09:00:00' as time)) 
and datepart(weekday,cast(dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),dateoccured)  as date)) in (2,3,4,5,6)

Union

select Faultid as [Ticket ID]
,dateoccured as [Date Created]
,username as [User]
,Symptom as [Summary]
,(select uname from uname where unum=Assignedtoint) as [Agent]
from faults 
where fdeleted=0 
and FMergedIntoFaultid=0 
and cast(dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),dateoccured)  as date)>@startdate 
and cast(dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),dateoccured)  as date)<@enddate 
and datepart(weekday,cast(dateadd(minute,datediff(minute, getutcdate()   at time zone (select rtimezone from control3),getutcdate() ),dateoccured)  as date)) in (1,7)
