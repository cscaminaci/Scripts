SELECT 
aareadesc AS [Customer],
sectio_ as [Team],
SUM(IIF(slaresponsestate IN ('I', 'E', 'X', 'O'), 1, 0))  AS [Total Tickets],
SUM(IIF(slaresponsestate IN ('I', 'E', 'X'), 1, 0)) AS [Tickets responded to on time],
SUM(IIF(slastate IN ('I', 'E', 'X'), 1, 0)) AS [Tickets resolved on time],
CONVERT(VARCHAR, CAST(ROUND(ISNULL(SUM(IIF(slaresponsestate IN ('I', 'E', 'X'), 1, 0))*100.0/NULLIF(SUM(IIF(slaresponsestate IN ('I', 'E', 'X', 'O'), 1, 0)), 0), 100), 2) AS DECIMAL(5, 2))) + '%' as [Responded on time %],    
CONVERT(VARCHAR, CAST(ROUND(ISNULL(SUM(IIF(slastate IN ('I', 'E', 'X'), 1, 0))*100.0/NULLIF(SUM(IIF(slastate IN ('I', 'E', 'X', 'O'), 1, 0)), 0), 100), 2) AS DECIMAL(5, 2))) + '%' as [Resolved on time %]
FROM faults

JOIN area ON areaint = aarea

group by sectio_, aareadesc
