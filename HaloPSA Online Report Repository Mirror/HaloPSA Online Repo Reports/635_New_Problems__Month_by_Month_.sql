select
         convert(nvarchar(7), dateoccured, 126)  as [Date Created]
       , count(faultid) as [# Problems]
from
         faults
where
    dateoccured > @startdate
and dateoccured < @enddate
and requesttype=4
and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
group by
    convert(nvarchar(7), dateoccured, 126)


