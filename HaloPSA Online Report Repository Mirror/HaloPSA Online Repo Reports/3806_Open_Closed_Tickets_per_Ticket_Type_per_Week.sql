SELECT TOP 10000
    a.[Week Commencing],
    rtdesc AS [Ticket Type],
    ISNULL(table0.r, 0) AS [Tickets Opened], 
    ISNULL(table1.r, 0) AS [Tickets Closed]
FROM (
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY DATEADD(WEEK, DATEDIFF(WEEK, 0, date_id), 0) ORDER BY date_id ASC) AS r,
        CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 0, date_id), 0)) AS [Week Commencing]
    FROM calendar 
    WHERE date_id BETWEEN @startdate and @enddate
) a 

CROSS APPLY requesttype

LEFT JOIN (
    SELECT
        DATEADD(WEEK, DATEDIFF(WEEK, 0, dateoccured), 0) AS [Week Commencing],
        rtdesc as [Ticket Type],
        COUNT(*) AS r
    FROM faults 
    JOIN requesttype ON requesttypenew = rtid 
    GROUP BY 
        DATEADD(WEEK, DATEDIFF(WEEK, 0, dateoccured), 0),
        rtdesc
) table0 ON a.[Week Commencing] = table0.[Week Commencing] AND requesttype.rtdesc = table0.[Ticket Type]

LEFT JOIN (
    SELECT
        DATEADD(WEEK, DATEDIFF(WEEK, 0, datecleared), 0) AS [Week Commencing],
        rtdesc as [Ticket Type],
        COUNT(*) AS r
    FROM faults 
    JOIN requesttype ON requesttypenew = rtid 
    GROUP BY 
        DATEADD(WEEK, DATEDIFF(WEEK, 0, datecleared), 0),
        rtdesc
) table1 ON a.[Week Commencing] = table1.[Week Commencing] AND requesttype.rtdesc = table1.[Ticket Type]

WHERE 
    a.r = 1
    AND ISNULL(table0.r, 0) + ISNULL(table1.r, 0) <> 0

ORDER BY 
    a.[Week Commencing] ASC
