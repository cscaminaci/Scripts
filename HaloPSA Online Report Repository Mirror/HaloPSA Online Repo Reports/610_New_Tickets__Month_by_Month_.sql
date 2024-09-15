select
         convert(nvarchar(7), dateoccured, 126)  as [Date Created]
       , count(faultid) as [# Tickets]
from
         faults
where
         dateoccured > @startdate
  and dateoccured < @enddate
  and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
group by
    convert(nvarchar(7), dateoccured, 126)





