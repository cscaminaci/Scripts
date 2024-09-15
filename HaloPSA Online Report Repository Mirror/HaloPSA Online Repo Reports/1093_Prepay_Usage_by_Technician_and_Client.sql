SELECT uname AS Technician
	,aareadesc AS [Client]
	,sum(actionprepayhours)  AS [Total prepay hours used]
	,AAutoTopUpCostPerHour AS [Auto-Topup cost per hour]
	,sum(actionprepayhours) * AAutoTopUpCostPerHour AS [Total cost to customer]
FROM uname
JOIN actions ON uname = who
JOIN faults ON actions.faultid = faults.faultid
JOIN area ON areaint = aarea
WHERE uisdisabled <> 1
	AND whe_ > @startdate
	AND whe_ < @enddate
GROUP BY uname
	,aareadesc
	,AAutoTopUpCostPerHour
HAVING sum(actionprepayhours)>0
