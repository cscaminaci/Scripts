select
      sectio_ as [Section]
    , count(ofaultid) as [Opened Last Week]
    /*, SUM(IIF(status not in(8,9) and dateoccured>@startdate and dateoccured<@enddate, 1, 0)) AS [Created Last Week2] */
    , count(cfaultid) as [Closed Last Week]
    , COUNT(ocfaultid) AS [Opened & Closed within Same Week]
    , CAST(ROUND(ISNULL(count(ocfaultid)/NULLIF(count(ofaultid) * 1.0, 0), 1)*100, 2) AS DECIMAL(5, 2)) as [% (Opened+Closed)/(Opened) Solved] 
    , (count(cfaultid)-count(ofaultid)) as [Backlog Impact]
    , count(bfaultid) as [Backlog]
    , count(distinct cfaultid) / NULLIF(count(distinct ofaultid), 0) *100 AS [% (Created/Opened) Solved]
from 
faults left join 
(select faultid as [bfaultid] from faults where status not in(8,9))backlog on bfaultid=faultid left join
(select faultid as [ofaultid] from faults where dateoccured>@startdate and 
dateoccured<@enddate)Opened on ofaultid=faultid left join
(select faultid as [cfaultid] from faults where status in (8,9) and datecleared>@startdate and 
datecleared<@enddate)Closed on  cfaultid=faultid 
left join
(select faultid as [ocfaultid] from faults where status in (8,9) and datecleared>@startdate and 
datecleared<@enddate and dateoccured>@startdate and dateoccured<@enddate)openclosed on  ocfaultid=faultid 

where requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
group by sectio_

                                                     

