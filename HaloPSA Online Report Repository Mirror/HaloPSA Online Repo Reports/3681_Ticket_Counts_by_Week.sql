SELECT 
    FORMAT(weekStart, 'MM/dd/yy') AS [Week],
    SUM(IIF(dateOpened < weekStart AND dateClosed >= weekStart, 1, 0)) AS [Starting Count],
    SUM(IIF(dateOpened >= weekStart AND dateOpened < weekEnd, 1, 0)) AS [Opened During],
    SUM(IIF(dateClosed >= weekStart AND dateClosed < weekEnd, 1, 0)) AS [Closed During],
    SUM(IIF(dateOpened < weekEnd AND dateClosed >= weekEnd, 1, 0)) AS [Ending Count]
FROM 
(
    SELECT
        CAST(DATEADD(DAY, (DATEPART(WEEKDAY, date_id) * -1) + 1, date_id) AS DATE) AS [weekStart],
        CAST(DATEADD(DAY, (DATEPART(WEEKDAY, date_id) * -1) + 8, date_id) AS DATE) AS [weekEnd]
    FROM calendar
    WHERE date_id BETWEEN @STARTDATE AND @ENDDATE 
        AND weekday_id = 1
) AS [Week Start & End in DateTime] 

CROSS JOIN (
    SELECT 
        faultid,
        CONVERT(DATE, dateoccured) AS [dateOpened],
        CONVERT(DATE, IIF(status IN (8,9), datecleared, '9999-01-01')) AS [dateClosed]
    FROM faults 
    WHERE fdeleted = 0
        AND fmergedintofaultid = 0
        AND requesttype IN (1, 3)
) AS [Ticket Open and Closed Date]

GROUP BY [weekStart]
