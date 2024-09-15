SELECT TOP 100
category2 AS [Category],
COUNT(*) AS [Total Tickets]
FROM faults
WHERE   category2 IS NOT NULL 
        AND category2 <> '' 
        AND dateoccured > @startdate
        AND dateoccured < DATEADD(month,12,@startdate)
GROUP BY category2
ORDER BY category2 ASC
