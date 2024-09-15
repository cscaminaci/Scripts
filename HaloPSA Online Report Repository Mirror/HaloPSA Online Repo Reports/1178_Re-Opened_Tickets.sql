select 
	  count(faults.faultid) as [Count]
from faults where 
(select top 1 actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber)
<
(select top 1 actionnumber from actions where actions.faultid=faults.faultid order by actionnumber desc)
and (select whe_ from actions where actions.faultid=faults.faultid and actionnumber=(select top 1 actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber desc)
+1)>getdate()-7  and fdeleted=0
