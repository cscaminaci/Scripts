select
AFaultid as [Ticket Number],
apkid2 as [Action Number],
AValue as [Field Changed],
case when avalue='timetaken' then CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(afrom, 0), 2) * 60 AS INT), 0) / 60) AS NVARCHAR(9)) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(afrom, 0), 2) * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) else afrom end as [Changed From],
 case when avalue='timetaken' then CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(ato, 0), 2) * 60 AS INT), 0) / 60) AS NVARCHAR(9)) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(ato, 0), 2) * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) else ato end [Changed To],
 ADate as [Date],
(SELECT uname FROM uname WHERE aunum = unum) as 'Agent'
from audit
where atablename='actions' and ADate between @startdate and @enddate and avalue not like 'Action ID % Created' and avalue not like 'Action ID % Deleted'
