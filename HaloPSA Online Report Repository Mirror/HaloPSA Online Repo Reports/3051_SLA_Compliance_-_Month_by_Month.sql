select
                     convert(nvarchar(7), dateoccured, 126)  as [Date Created]
       , round(avg(elapsedhrs),2) as [Fix By Time (Average)]
                   , round(cast(count(ifaultid) as float)/nullif((cast(count(ifaultid) as float)+cast(count(ofaultid) as float)),0)*100,0) as [SLA Compliance %]
from faults left join
                (select faultid ifaultid from faults where slastate = 'i')inside on faultid=ifaultid left join
                (select faultid ofaultid from faults where slastate = 'o')outside on faultid=ofaultid 
where 
      dateoccured > @startdate
  and dateoccured < @enddate
  and requesttype=1
  and FexcludefromSLA = 0
group by 
  convert(nvarchar(7), dateoccured, 126)
