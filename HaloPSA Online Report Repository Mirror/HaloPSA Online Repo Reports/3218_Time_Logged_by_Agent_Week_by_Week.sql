select
         convert(date,dateadd(week, datediff(week, 0, whe_), 0)) as [Week Commencing]
       , (SELECT uname FROM uname WHERE actionbyunum = unum) as 'Agent'
       , round(sum(timetaken),2) as 'Time Spent'
from                                        
         actions
JOIN faults on faults.faultid = actions.faultid
where
         whe_ > @startdate
  and whe_ < @enddate
  and fdeleted=fmergedintofaultid                                                                     
  and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
group by
     convert(date,dateadd(week, datediff(week, 0, whe_), 0)), actionbyunum









