select uname as [Technician]
       , (select count(faultid) from faults where status<>9 and assignedtoint=unum) as [Tickets Carried]
       , (select count(faultid) from faults where status<>9 and dateoccured > @startdate and dateoccured < @enddate and assignedtoint=unum) as [Tickets Opened]
       , (select count(faultid) from faults where status=9 and datecleared > @startdate and datecleared < @enddate and assignedtoint=unum) as [Tickets Closed]
       , (select count(faultid) from actions where who=uname and actiondatecreated > @startdate and actiondatecreated < @enddate) as [Number of Actions]
       , (select count(faultid) from faults where dateoccured > @startdate and dateoccured < @enddate and assignedtoint=unum and RequestTypeNew=1) as [Incidents]
       , (select count(faultid) from faults where dateoccured > @startdate and dateoccured < @enddate and assignedtoint=unum and RequestTypeNew=3) as [Service Request]
       , (select count(faultid) from faults where dateoccured > @startdate and dateoccured < @enddate and assignedtoint=unum and RequestTypeNew=8) as [Inst]
       , (select count(faultid) from faults where dateoccured > @startdate and dateoccured < @enddate and assignedtoint=unum and RequestTypeNew=30) as [POC]
       , (select count(faultid) from faults where dateoccured > @startdate and dateoccured < @enddate and assignedtoint=unum and RequestTypeNew=37) as [Per Dev]
       , (select count(faultid) from faults where dateoccured > @startdate and dateoccured < @enddate and assignedtoint=unum and RequestTypeNew=26) as [Fit Parts]
       , (select count(faultid) from faults where dateoccured > @startdate and dateoccured < @enddate and assignedtoint=unum and RequestTypeNew in (6,35,36)) as [Projects]
       ,(select count(faultid) from faults where dateoccured > @startdate and dateoccured < @enddate and assignedtoint=unum and RequestTypeNew in (1,3,8,30,37,26,6,35,36)) as [Total Tickets] 
       ,isnull(round((select sum(timetaken) from actions where who=uname and actiondatecreated > @startdate and actiondatecreated < @enddate), 2), 0) as Hours

from Uname   
                                                                                



