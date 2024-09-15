Select
apkid1 as [Sales Order No.]
,avalue as [Action]
,(select uname from uname where unum=aunum) as [Agent] 
,ADate as [Date]
, AFrom as [From]
, ATo as [To]
from audit 
where atablename='orderhead'
