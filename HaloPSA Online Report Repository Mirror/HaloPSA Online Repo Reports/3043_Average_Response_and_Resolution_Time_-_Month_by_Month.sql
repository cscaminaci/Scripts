select
      convert(nvarchar(7), dateoccured, 126) as [Date]  
    , round(isnull(avg(fresponsetime),0),2) as [Average Response Time]
    , round(isnull(avg(elapsedhrs),0),2) as [Average Resolution Time]
from faults
where dateoccured > @startdate and dateoccured < @enddate and status in (8,9)
group by convert(nvarchar(7), dateoccured, 126)

