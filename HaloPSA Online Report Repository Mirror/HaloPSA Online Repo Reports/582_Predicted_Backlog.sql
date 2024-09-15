select
      sectio_ as [Section]
    , count(bfaultid) as [# Unsolved Tickets]
    , count(cfaultid)/52 as [# Tickets Solved/Week (Avg)]
    , CONVERT(DECIMAL(4,2),count(bfaultid)/NULLIF(((count(cfaultid)/52)*1.0),0)) as [Backlog (Weeks)]
from 
faults left join 
(select faultid as [bfaultid] from faults where status not in(8,9))backlog on bfaultid=faultid left join
(select faultid as [cfaultid] from faults where status in (8,9) and datecleared>=(getdate()-364))Closed on 
cfaultid=faultid 
where requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) and sectio_ in (select sdsectionname from sectiondetail where sdforrequests=1) 
group by sectio_        





