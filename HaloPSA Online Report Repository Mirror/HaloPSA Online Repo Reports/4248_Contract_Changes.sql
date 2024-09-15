Select
apkid1 as [Contract ID]
,CHcontractRef as [Contract Ref]
,avalue as [Action]
,case when isnull(apclientid,'')='' then (select aareadesc from area where CHarea=aarea) else (select aareadesc from area where apclientid=aarea) end as [Client]
,(select uname from uname where unum=aunum) as [Agent] 
,ADate as [Date]
, AFrom as [From]
, ATo as [To]
from audit 
left join contractheader on CHid=apkid1
where atablename='ContractHeader'
