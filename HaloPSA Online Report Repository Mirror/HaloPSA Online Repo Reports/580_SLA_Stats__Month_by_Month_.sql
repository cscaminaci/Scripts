select
         round(avg(fresponsetime),2) as [First Response Time (Average)]
       , round(avg(elapsedhrs),2) as [Fix By Time (Average)]
       , convert(nvarchar(7), dateoccured, 126)  as [Date Created]
from 
         faults
where 
         dateoccured > @startdate
  and dateoccured < @enddate
  and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
  and FexcludefromSLA = 0
group by 
         convert(nvarchar(7), dateoccured, 126)









