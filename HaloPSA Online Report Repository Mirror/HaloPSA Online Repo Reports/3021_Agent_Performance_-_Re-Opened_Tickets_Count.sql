select *

, cast(floor((round(avg([Average Response Time (Hours)]),2)/24))*24+cast(convert(nvarchar(2),cast((round(avg([Average Response Time (Hours)]),2)/24) as datetime),108) as float) as nvarchar(10))+':'+ 
right(convert(nvarchar(5),cast((round(avg([Average Response Time (Hours)]),2)/24) as datetime),108),2) as [Average Response Time (hh:mm)]
, cast(floor((round(avg([Average Resolution Time (Hours)]),2)/24))*24+cast(convert(nvarchar(2),cast((round(avg([Average Resolution Time (Hours)]),2)/24) as datetime),108) as float) as nvarchar(10))+':'+ 
right(convert(nvarchar(5),cast((round(avg([Average Resolution Time (Hours)]),2)/24) as datetime),108),2) as [Average Resolution Time (hh:mm)]

from (

select

      uname as [Agent]

,(select count(faultid) from faults where SLAresponseState='I' and fdeleted=fmergedintofaultid and assignedtoint=unum
and dateoccured>@startdate and dateoccured<@enddate) as [Number of Tickets Responded within SLA]

, cast(isnull(CONVERT(DECIMAL(4,2),(select count(faultid) from faults where slastate='I' and clearwhoint=unum
and fdeleted=fmergedintofaultid and dateoccured>@startdate and dateoccured<@enddate)/(NULLIF((select count(faultid) from faults
where (slastate='O' or slastate='I') and clearwhoint=unum and fdeleted=fmergedintofaultid and dateoccured>@startdate and 
dateoccured<@enddate)*1.0,0)))*100,100)as integer) as [Resolution Rate %]

, cast(isnull(CONVERT(DECIMAL(4,2),((select count(fbfaultid) from feedback join faults on fbfaultid=faultid where 
assignedtoint=unum and fbscore in (1,2) and fbsubject='Feedback From Ticket' and 
dateoccured>@startdate and dateoccured<@enddate)/(NULLIF((select count(fbfaultid) from feedback join faults on fbfaultid=faultid where 
assignedtoint=unum and fbsubject='Feedback From Ticket' and dateoccured>@startdate and
dateoccured<@enddate)*1.0,0))))*100,100) as integer) as [Satisfaction Score %]

, isnull((select isnull(count(faultid),0) from faults where takenby=uname and fdeleted=fmergedintofaultid and dateoccured>@startdate and dateoccured<@enddate
and (slastate='O' or slastate='I') group by takenby),0) as [Tickets Opened]

, isnull((select isnull(count(faultid),0) from faults where assignedtoint=unum and fdeleted=fmergedintofaultid and status not in (8,9) group by assignedtoint),0) as [Assigned Tickets]

, isnull((select isnull(count(faultid),0) from faults where clearwhoint=unum and fdeleted=fmergedintofaultid and datecleared>@startdate and datecleared<@enddate
and (slastate='O' or slastate='I') group by clearwhoint),0) as [Tickets Resolved]

,isnull((select isnull(count(faultid),0) from faults where clearwhoint=unum and fdeleted=fmergedintofaultid and slastate='I' and datecleared>@startdate and datecleared<@enddate
 group by clearwhoint),0) as [On Time Resolution]

/*,round(isnull((select avg(fresponsetime) from faults where clearwhoint=unum and fdeleted=fmergedintofaultid and datecleared>@startdate and datecleared<@enddate
 group by clearwhoint),0),2) as [Average Response Time (Hours)]*/

,round(isnull((select avg(elapsedhrs) from faults where clearwhoint=unum and fdeleted=fmergedintofaultid and datecleared>@startdate and datecleared<@enddate
 group by clearwhoint),0),2) as [Average Resolution Time (Hours)]

, round(isnull((select avg(fresponsetime) from faults where clearwhoint=unum and uname in (select who from actions where actions.faultid=faults.faultid and actoutcome='responded') and fdeleted=fmergedintofaultid and datecleared>@startdate and datecleared<@enddate
 group by clearwhoint),0),2) as [Average Response Time (Hours)]

, (select count (faultid) from faults where requesttypenew=71 and datecleared>@startdate and datecleared<@enddate and clearwhoint=unum and (select top 1 actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Re-Open Request' order by actionnumber)  > 0) as [Re-Opens]

, (select count (faultid) from actions where whe_>@startdate and whe_<@enddate and who=uname) as [Total Actions]

from uname

where Uisdisabled=0

)bgb

group by [Agent], [Number of Tickets Responded within SLA], [Resolution Rate %], [Satisfaction Score %], [Tickets Opened], [Assigned Tickets], [Tickets Resolved], [On Time Resolution], [Average Resolution Time (Hours)], [Average Response Time (Hours)], [Re-Opens], [Total Actions]
