select date_id as [Date],weekday_nm as [Day],
(select count(*) from faults join requesttype on rtid=RequestTypeNew where datediff(day, dateoccured, date_id) = 0 and fdeleted=0 and FMergedIntoFaultid=0 and RTIsProject=0 and RTIsOpportunity=0) as [Opened],
(select count(*) from faults join requesttype on rtid=RequestTypeNew where datediff(day, datecleared, date_id) = 0 and fdeleted=0 and FMergedIntoFaultid=0 and RTIsProject=0 and RTIsOpportunity=0) as [Resolved],
round((select sum(isnull(timetaken,0)) from actions join faults on actions.faultid=faults.faultid join requesttype on rtid=RequestTypeNew where datediff(day, whe_, date_id) = 0 and fdeleted=0 and isnull(FMergedIntoFaultid,0)=0 and RTIsProject=0 and RTIsOpportunity=0),2)  as [Hours Logged],
(select count(*) from faults join requesttype on rtid=RequestTypeNew where datediff(day, datecleared, date_id) = 0 and slastate='O' and fdeleted=0 and FMergedIntoFaultid=0 and RTIsProject=0 and RTIsOpportunity=0) as [Resolution SLA Missed],
round((select AVG(elapsedhrs) from faults join requesttype on rtid=RequestTypeNew where datediff(day, datecleared, date_id) = 0  and fdeleted=0 and FMergedIntoFaultid=0 and RTIsProject=0 and RTIsOpportunity=0),2) as [Average Resolution SLA],
(select count(*) from faults join requesttype on rtid=RequestTypeNew where datediff(day, FResponseDate, date_id) = 0 and SLAresponseState='O' and fdeleted=0 and FMergedIntoFaultid=0 and RTIsProject=0 and RTIsOpportunity=0) as [Response SLA Missed],
round((select AVG(FResponseTime) from faults join requesttype on rtid=RequestTypeNew where datediff(day, FResponseDate, date_id) = 0  and fdeleted=0 and FMergedIntoFaultid=0 and RTIsProject=0 and RTIsOpportunity=0),2) as [Average Response SLA]
from calendar
where date_id>=@startdate+1 and date_id<=@enddate


