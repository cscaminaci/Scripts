select
         convert(date,dateadd(week, datediff(week, 0, dateoccured), 0)) as [Week Commencing]
       , count(faultid) as [# Tickets]
from                                        
         faults
where
         dateoccured > @startdate
  and dateoccured < @enddate
  and fdeleted=fmergedintofaultid                                                                     
  and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
group by
     convert(date,dateadd(week, datediff(week, 0, dateoccured), 0))









