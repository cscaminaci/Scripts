select 
	  faultid as 'Ticket ID' 
	, (select aareadesc from area where aarea=areaint) as 'Client'
	, (select sdesc from site where ssitenum=sitenumber) as 'Site'
	, username as 'Username'
	, symptom as 'Summary'
	, dateoccured as 'Date Logged'
	, (select whe_ from actions where actions.faultid=faults.faultid and actionnumber-1 in (select top 1 actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber)) as 'Date reopened'
	, (select uname from uname where uname.unum=faults.assignedtoint) as 'Technician'

from faults where 
(SELECT count(faultid) FROM actions WHERE faults.faultid = actions.faultid AND ActionStatusAfter = 9 AND Actoutcome != 'Re-Close' AND actoutcome != 'Closed when adding' AND actionstatusbefore != 9) > 1
AND fdeleted = fmergedintofaultid
