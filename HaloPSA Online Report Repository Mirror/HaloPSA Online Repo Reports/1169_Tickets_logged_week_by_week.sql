select
       convert(date,dateadd(week, datediff(week, 0, dateoccured), 0)) as [WeekCommencing]
     , count(faultid) as [Tickets]
from                                        
         faults
where
         dateoccured > getdate()-90
  and dateoccured < getdate()                                                                     
  and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0 and fdeleted=0)
group by convert(date,dateadd(week, datediff(week, 0, dateoccured), 0))

