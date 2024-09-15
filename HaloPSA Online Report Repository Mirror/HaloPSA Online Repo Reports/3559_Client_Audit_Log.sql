select
aareadesc as [Client],
AValue as [Field Changed],
CASE WHEN AValue IN ('accountmanagertech', 'sectech', 'pritech') THEN (SELECT uname FROM uname WHERE afrom = unum)
		   ELSE AFrom 
	  END AS [Changed From],
CASE WHEN AValue IN ('accountmanagertech', 'sectech', 'pritech') THEN (SELECT uname FROM uname WHERE ato = unum)
		   ELSE ato 
	  END AS [Changed To],
case when (aactoutcome='Area Created' or aactoutcome='Area Deleted') then 'Created/Deleted' else 'Field Updated' end as [Change Type],
ADate as [Date],
(SELECT uname FROM uname WHERE aunum = unum) as 'Agent'
from audit
left join area on aarea=apkid1
where atablename='area' and ADate between @startdate and @enddate
