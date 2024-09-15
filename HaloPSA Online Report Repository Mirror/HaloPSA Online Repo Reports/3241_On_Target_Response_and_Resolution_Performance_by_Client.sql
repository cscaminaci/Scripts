select    
aareadesc as [Client],   
SUM(IIF(slaresponsestate IN ('I', 'E', 'X', 'O'), 1, 0))  AS [Total tickets],
SUM(IIF(slaresponsestate IN ('I', 'E', 'X'), 1, 0)) AS [Tickets responded on time],
SUM(IIF(slastate IN ('I', 'E', 'X'), 1, 0)) AS [Tickets resolved on time],
CONVERT(VARCHAR, CAST(ROUND(ISNULL(SUM(IIF(slaresponsestate IN ('I', 'E', 'X'), 1, 0))*100.0/NULLIF(SUM(IIF(slaresponsestate IN ('I', 'E', 'X', 'O'), 1, 0)), 0), 100), 2) AS DECIMAL(5, 2))) + '%' as [Responded on time %],    
CONVERT(VARCHAR, CAST(ROUND(ISNULL(SUM(IIF(slastate IN ('I', 'E', 'X'), 1, 0))*100.0/NULLIF(SUM(IIF(slastate IN ('I', 'E', 'X', 'O'), 1, 0)), 0), 100), 2) AS DECIMAL(5, 2))) + '%' as [Resolved on time %]
from faults

JOIN area ON areaint = aarea

where 
    status IN (8, 9) AND dateoccured BETWEEN @startdate AND @enddate           

group by 
    aareadesc  
