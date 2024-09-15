select
      uname as [Agent]
    , cast(isnull(CONVERT(DECIMAL(4,2),(select count(faultid) from faults where SLAresponseState='I' and assignedtoint=unum
and dateoccured>@startdate and dateoccured<@enddate)/(NULLIF((select count(faultid) from faults
where (SLAresponseState='O' or SLAresponseState='I') and assignedtoint=unum and dateoccured>@startdate and 
dateoccured<@enddate)*1.0,0)))*100,100)as integer) as [Response Rate %]
    , cast(isnull(CONVERT(DECIMAL(4,2),((select count(fbfaultid) from feedback join faults on fbfaultid=faultid where 
assignedtoint=unum and fbscore in (1,2) and fbsubject='Feedback From Ticket' and 
dateoccured>@startdate and
dateoccured<@enddate)/(NULLIF((select count(fbfaultid) from feedback join faults on fbfaultid=faultid where 
assignedtoint=unum and fbsubject='Feedback From Ticket' and dateoccured>@startdate and
dateoccured<@enddate)*1.0,0))))*100,100) as integer) as 
[Satisfaction Score %],
isnull((select isnull(count(faultid),0) from faults where clearwhoint=unum and datecleared>@startdate and datecleared<@enddate
and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) group by clearwhoint),0) as [Tickets Resolved],
isnull((select isnull(count(faultid),0) from faults where clearwhoint=unum and slastate='I' and datecleared>@startdate and datecleared<@enddate
and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) group by clearwhoint),0) as [On Time Resolution],
round(isnull((select avg(fresponsetime) from faults where assignedtoint=unum and datecleared>@startdate and datecleared<@enddate
and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) group by assignedtoint),0),2) as [Average Response Time (Hours)],
round(isnull((select avg(elapsedhrs) from faults where clearwhoint=unum and datecleared>@startdate and datecleared<@enddate
and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) group by clearwhoint),0),2) as [Average Resolution Time (Hours)]
from uname
where unum<>1 and Uisdisabled=0

                                          










