select 
[Date]
, [Email] 
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Response Email] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Response Email] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Response Email]
, [Web]
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Response Web] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Response Web] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Response Web]
, [Auto]
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Response Auto] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Response Auto] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Response Auto]
, [Manual]
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Response Manual] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Response Manual] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Response Manual]
, [Total Requests]

from (
select convert(nvarchar(7), dateoccured, 126) as [Date]
, count(efaultid) as [Email], round(avg(efresponsetime),2) as [Average Response Email] 
, count(wfaultid) as [Web], round(avg(wfresponsetime),2) as [Average Response Web]
, count(afaultid) as [Auto], round(avg(afresponsetime),2) as [Average Response Auto]
, count(mfaultid) as [Manual], round(avg(mfresponsetime),2) as [Average Response Manual]
, count(faultid) as [Total Requests]
from faults left join
(select faultid as [efaultid], fresponsetime as [efresponsetime] from faults where frequestsource=0)Email on efaultid=faultid left join
(select faultid as [wfaultid], fresponsetime as [wfresponsetime] from faults where frequestsource=1)Web on  wfaultid=faultid left join
(select faultid as [afaultid], fresponsetime as [afresponsetime] from faults where frequestsource=2)Auto on afaultid=faultid left join
(select faultid as [mfaultid], fresponsetime as [mfresponsetime] from faults where frequestsource=3)Manual on mfaultid=faultid
         
where requesttype in (3) and FexcludefromSLA = 0 and fdeleted=0 and 
dateoccured > @startdate and dateoccured < @enddate   
group by convert(nvarchar(7), dateoccured, 126)
) z







