select
         convert(date,dateadd(week, datediff(week, 0, dateoccured), 0)) as [Week Commencing]
       , count(faultid) as [# Tickets]
from                                        
         faults
where
         dateoccured > @startdate
  and dateoccured < @enddate
  and fdeleted=fmergedintofaultid                                                                     
  and requesttypenew=122
group by
     convert(date,dateadd(week, datediff(week, 0, dateoccured), 0))









