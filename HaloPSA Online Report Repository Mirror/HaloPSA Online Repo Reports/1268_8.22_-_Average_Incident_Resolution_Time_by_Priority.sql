select 
[Date]
, [Low] 
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Low] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Low] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Resolution Low]
, [Medium]
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Medium] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Medium] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Resolution Medium]
, [High]
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution High] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution High] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Resolution High]
, [Critical]
, RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Critical] * 60 AS INT), 0) / 60) AS NVARCHAR(8)), 2) + 'h ' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Average Resolution Critical] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) + 'm' as [Average Resolution Critical]
, [Total Incidents]

from (
select convert(nvarchar(7), dateoccured, 126) as [Date]
, count(Lfaultid) as [Low], round(sum(LElapsedhrs) / nullif(count(*), 0), 2) as [Average Resolution Low] 
, count(Mfaultid) as [Medium], round(sum(MElapsedhrs) / nullif(count(*), 0), 2) as [Average Resolution Medium]
, count(Hfaultid) as [High], round(sum(HElapsedhrs) / nullif(count(*), 0), 2) as [Average Resolution High]
, count(Cfaultid) as [Critical], round(sum(CElapsedhrs) / nullif(count(*), 0), 2) as [Average Resolution Critical]
, count(faultid) as [Total Incidents]
from faults left join
(select faultid as [Lfaultid], elapsedhrs as [Lelapsedhrs] from faults where seriousness=1)Low on Lfaultid=faultid left join
(select faultid as [Mfaultid], elapsedhrs as [Melapsedhrs] from faults where seriousness=2)Medium on Mfaultid=faultid left join
(select faultid as [Hfaultid], elapsedhrs as [Helapsedhrs] from faults where seriousness=3)High on Hfaultid=faultid left join
(select faultid as [Cfaultid], elapsedhrs as [Celapsedhrs] from faults where seriousness=4)Critical on Cfaultid=faultid      
where requesttype in (1) and FexcludefromSLA = 0 and fdeleted=0 and
dateoccured > @startdate and dateoccured < @enddate   
group by convert(nvarchar(7), dateoccured, 126)
) z







