SELECT sectio_ AS [Team], COUNT(*) AS [Number Re-Opened]
FROM actions act1
JOIN actions act2 ON act1.faultid = act2.faultid
JOIN faults ON act1.faultid = faults.faultid


WHERE (act1.actoutcome = 'Closed' OR act1.actoutcome = 'Close')
AND act2.actionnumber = (SELECT MIN(actionnumber) FROM actions WHERE act1.faultid = faultid AND act1.actionnumber < actionnumber AND (actoutcome like 'Email Updat%' OR actoutcome = 'Customer Reopened' OR actoutcome like 'User Updat%'))

GROUP BY sectio_
