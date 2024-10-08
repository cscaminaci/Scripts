SELECT TOP 4
    CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 0, dateoccured), 0)) AS [Week],
    COUNT(*) AS [Num]
FROM faults

WHERE 
    RequestTypeNew = 68 
    AND dateoccured > @startdate

GROUP BY
    CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 0, dateoccured), 0))

ORDER BY 
    CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 0, dateoccured), 0)) DESC

/* CLIENTS MAY WANT A DIFFERENT CUSTOM VARIABLE TO BE USED INSTEAD OF dateoccured, ALSO CHECK TICKET TYPE */
