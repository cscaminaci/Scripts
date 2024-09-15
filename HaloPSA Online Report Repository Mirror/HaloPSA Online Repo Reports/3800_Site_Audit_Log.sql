select
aareadesc as [Client],
sdesc as [Site],
AValue as [Field Changed],
CASE WHEN AValue IN ('accountmanagertech', 'sectech', 'pritech') THEN (SELECT uname FROM uname WHERE afrom = unum)
	WHEN AValue like '%moved%' then (select aareadesc from area where aarea=afrom)
		   ELSE AFrom 
	  END AS [Changed From],
CASE WHEN AValue IN ('accountmanagertech', 'sectech', 'pritech') THEN (SELECT uname FROM uname WHERE ato = unum)
	 WHEN AValue like '%moved%' then (select aareadesc from area where aarea=ato)
		   ELSE ato 
	  END AS [Changed To],
case when (aactoutcome='Site Created' or aactoutcome='Site Deleted') then 'Created/Deleted' else 'Field Updated' end as [Change Type],
ADate as [Date],
(SELECT uname FROM uname WHERE aunum = unum) as 'Agent'
from audit
left join site on apkid1 = ssitenum 
left join area on aarea = sarea
where atablename='site' and ADate between @startdate and @enddate
