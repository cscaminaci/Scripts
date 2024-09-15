SELECT
DateOccured AS [Date Opened],
[FaultID] AS [Ticket ID],
[Status],
SUM([Total Time]) AS [Total Time (Mins)],
ROUND((SUM([Total Time])/60),2) AS [Total Time (~Hours)]

FROM

(SELECT

DateOccured,
FaultID,
(SELECT TStatusDesc FROM TStatus WHERE TStatus = ActionStatusBefore) AS [Status],
SUM([MinDiff]) AS [Total Time]

FROM

(SELECT
FaultID,
ActionStatusBefore,
DATEDIFF(Minute, (SELECT TOP 1 a2.Whe_ FROM Actions a2 WHERE a2.FaultID = z.FaultID AND a2.ActionStatusAfter <> a2.ActionStatusBefore AND a2.Whe_ < z.Whe_ ORDER BY Whe_ DESC), z.Whe_) AS [MinDiff],
DateOccured

FROM

(SELECT
a1.FaultID,
Whe_,
ActionStatusBefore,
ActionStatusAfter,
DateOccured

FROM Actions a1
JOIN Faults f1 ON f1.FaultID = a1.FaultID
WHERE a1.ActionStatusAfter <> a1.ActionStatusBefore AND a1.ActionStatusBefore <> 0)z)y

GROUP BY ActionStatusBefore, FaultID, DateOccured


UNION ALL


SELECT
DateOccured,
f.FaultID,
TStatusDesc AS [Status],
DATEDIFF(Minute,(SELECT TOP 1 Whe_ FROM Actions a WHERE a.FaultID = f.FaultID AND ActionStatusBefore <> ActionStatusAfter AND ActionStatusAfter = Status ORDER BY Whe_ DESC),DATEADD(Hour,-1,GETDATE())) AS [Total Time]

FROM Faults f JOIN TStatus ON TStatus = f.Status)x

GROUP BY [FaultID], [Status], DateOccured
