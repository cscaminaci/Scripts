select
      convert(nvarchar(7), dateoccured, 126) as [Date]
    , round(isnull(avg(elapsedhrs),0),2) as [MTTR (hours)]
from faults
where requesttype=1 and requesttypenew in (select rtid from requesttype where rtisopportunity=0 and rtisproject=0) and status in (8,9)
and dateoccured > @startdate and dateoccured < @enddate
group by
convert(nvarchar(7), dateoccured, 126)


