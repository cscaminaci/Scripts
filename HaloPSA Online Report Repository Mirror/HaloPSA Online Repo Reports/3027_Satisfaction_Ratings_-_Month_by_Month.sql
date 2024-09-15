select
      convert(nvarchar(7), dateoccured, 126) as [Date],
cast(isnull(CONVERT(DECIMAL(4,2),(count(pfbfaultid)/NULLIF((count(pfbfaultid)+count(nfbfaultid))*1.0,0)))*100,100) as integer) as 
[Satisfaction_Rate_%], 
      
cast(isnull(CONVERT(DECIMAL(4,2),(count(ifaultid)/NULLIF((count(ifaultid)+count(ofaultid))*1.0,0)))*100,100) as integer) as [Response_Rate_%]   
from faults
 left join (select faultid as [ifaultid] from faults where SLAresponseState='I')inside on faultid=ifaultid
left join (select faultid as [ofaultid] 
from faults where SLAresponseState='O')outside on faultid=ofaultid
left join (select fbfaultid as [pfbfaultid] 
from feedback where fbscore in (1,2) and fbsubject='Feedback From Ticket')positive on pfbfaultid=faultid
left join (select fbfaultid as [nfbfaultid] 
from feedback where fbscore in (3,4) and fbsubject='Feedback From Ticket')negative on nfbfaultid=faultid
where dateoccured > @startdate and dateoccured < @enddate 
and requesttypenew in (select rtid from requesttype
where rtisproject=0 and rtisopportunity=0)
group by convert(nvarchar(7), dateoccured, 126)               

