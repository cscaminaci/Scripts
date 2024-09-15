Select
apkid1 as [Invoice ID]
,avalue as [Action]
,case when isnull(apclientid,'')='' then (select aareadesc from area where IHaarea=aarea) else (select aareadesc from area where apclientid=aarea) end as [Client]
,(select uname from uname where unum=aunum) as [Agent] 
,ADate as [Date]
, AFrom as [From]
, ATo as [To]
from audit 
left join invoiceheader on IHid=apkid1
where atablename='invoiceheader'
