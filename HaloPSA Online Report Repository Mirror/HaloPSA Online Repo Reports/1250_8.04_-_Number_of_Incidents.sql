select convert(nvarchar(7), dateoccured, 126) as [Date], count(efaultid) as [Email],count(wfaultid) as
[Web],count(afaultid) as [Auto],count(mfaultid) as [Manual], count(faultid) as [Total Incidents]
from faults left join
(select faultid as [efaultid] from faults where frequestsource=0)Email on efaultid=faultid left join
(select faultid as [wfaultid] from faults where frequestsource=1)Web on  wfaultid=faultid left join
(select faultid as [afaultid] from faults where frequestsource=2)Auto on afaultid=faultid left join
(select faultid as [mfaultid] from faults where frequestsource=3)Manual on mfaultid=faultid
         
where requesttype in (1) and
dateoccured > @startdate and dateoccured < @enddate   
group by convert(nvarchar(7), dateoccured, 126)








