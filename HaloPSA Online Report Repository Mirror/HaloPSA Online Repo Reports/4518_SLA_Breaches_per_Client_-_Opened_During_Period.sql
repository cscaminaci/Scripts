SELECT
[Client],
SUM((CASE
WHEN [Response State] = 'Not Met' THEN 1
ELSE 0
END)) AS [Responses Missed],
SUM((CASE
WHEN [Resolution State] = 'Not Met' THEN 1
ELSE 0
END)) AS [Resolutions Missed],
SUM((CASE
WHEN [Resolution State] = 'Not Met' OR [Response State] = 'Not Met' THEN 1
ELSE 0
END)) AS [SLA Breaches]

FROM

(SELECT
AAreaDesc AS [Client],
FaultID AS [Ticket],
DateOccured AS [Logged],
CASE
WHEN GETDATE() < FRespondByDate AND SLAResponseState IS NULL THEN 'Meeting'
WHEN GETDATE() > FRespondByDate AND SLAResponseState IS NULL THEN 'Not Met'
WHEN SLAResponseState = 'I' THEN 'Met'
WHEN SLAResponseState = 'O' THEN 'Not Met'
END AS [Response State],
CASE
WHEN GETDATE() < FixByDate AND SLAState IS NULL THEN 'Meeting'
WHEN GETDATE() > FixByDate AND SLAState IS NULL THEN 'Not Met'
WHEN SLAState = 'I' THEN 'Met'
WHEN SLAState = 'O' THEN 'Not Met'
END AS [Resolution State]

FROM Faults
JOIN Area ON AArea = AreaInt)z

WHERE [Logged] BETWEEN @StartDate AND @EndDate

GROUP BY [Client]
