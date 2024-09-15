select 
[Date]
, [Email] 
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Email] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Email] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Resolution Email]
, [Web]
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Web] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Web] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Resolution Web]
, [Auto]
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Auto] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Auto] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Resolution Auto]
, [Manual]
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Manual] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Manual] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Resolution Manual]
, [Total Incidents]

from (
select convert(nvarchar(7), dateoccured, 126) as [Date]
, count(efaultid) as [Email], round(sum(eElapsedhrs) / nullif(count(*), 0), 2) as [Average Resolution Email] 
, count(wfaultid) as [Web], round(sum(wElapsedhrs) / nullif(count(*), 0), 2) as [Average Resolution Web]
, count(afaultid) as [Auto], round(sum(aElapsedhrs) / nullif(count(*), 0), 2) as [Average Resolution Auto]
, count(mfaultid) as [Manual], round(sum(mElapsedhrs) / nullif(count(*), 0), 2) as [Average Resolution Manual]
, count(faultid) as [Total Incidents]
from faults left join
(select faultid as [efaultid], elapsedhrs as [eelapsedhrs] from faults where frequestsource=0)Email on efaultid=faultid left join
(select faultid as [wfaultid], elapsedhrs as [welapsedhrs] from faults where frequestsource=1)Web on  wfaultid=faultid left join
(select faultid as [afaultid], elapsedhrs as [aelapsedhrs] from faults where frequestsource=2)Auto on afaultid=faultid left join
(select faultid as [mfaultid], elapsedhrs as [melapsedhrs] from faults where frequestsource=3)Manual on mfaultid=faultid
         
where requesttype in (1) and FexcludefromSLA = 0 and fdeleted=0 and
dateoccured > @startdate and dateoccured < @enddate   
group by convert(nvarchar(7), dateoccured, 126)
) z







