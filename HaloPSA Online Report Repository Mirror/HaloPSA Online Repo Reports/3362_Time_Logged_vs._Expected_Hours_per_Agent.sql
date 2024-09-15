SELECT
UName AS [Name],
CAST(ISNULL(FLOOR(SUM([TimeTaken Sum])),0) AS VARCHAR) + 'h, ' + CAST(ISNULL(((SUM([TimeTaken Sum]) - FLOOR(SUM([TimeTaken Sum])))*60),0) AS VARCHAR) + 'm' AS [Time Logged],
CAST(ISNULL(FLOOR(SUM([TravelTime Sum])),0) AS VARCHAR) + 'h, ' + CAST(ISNULL(((SUM([TravelTime Sum]) - FLOOR(SUM([TravelTime Sum])))*60),0) AS VARCHAR) + 'm' AS [Travel Logged],
CAST((ISNULL(FLOOR(SUM([TimeTaken Sum])),0) + ISNULL(FLOOR(SUM([TravelTime Sum])),0)) AS VARCHAR) + 'h, ' + CAST((ISNULL(((SUM([TimeTaken Sum]) - FLOOR(SUM([TimeTaken Sum])))*60),0) + ISNULL(((SUM([TravelTime Sum]) - FLOOR(SUM([TravelTime Sum])))*60),0)) AS VARCHAR) + 'm' AS [Total Time],
CAST(CAST(SUM([NWorkHour] - uhrsreducer) AS FLOAT) AS VARCHAR) + 'h'  AS [Expected Hours],
CAST(ROUND(((ISNULL((SUM([TimeTaken Sum]) + SUM([TravelTime Sum])),0) / ISNULL((SUM([NWorkHour] - uhrsreducer)),0)) * 100),2) AS VARCHAR) + '%' AS [Percent of Total Met],
IIF((SUM([NWorkHour] - uhrsreducer)) < (SUM([TimeTaken Sum])+SUM([TravelTime Sum])),'Completed', 'Incomplete') AS [Quota Met?]

FROM
(SELECT
    date_id,
    uname,
    uhrsreducer,
    ISNULL(SUM(Actions.TimeTaken),0) AS [TimeTaken Sum],
    ISNULL(SUM(Actions.TravelTime),0) AS [TravelTime Sum],
    (SELECT NWorkHours FROM NewWorkdays WHERE Ndayid = weekday_id AND NWorkDay = UWorkDayID and NIncluded = 1) AS [NWorkHour]
FROM calendar 

CROSS APPLY uname

LEFT JOIN Actions ON whoagentid = unum AND CONVERT(DATE,Actions.Whe_) = CONVERT(DATE,Date_ID)

WHERE 
    date_id BETWEEN @startdate AND @enddate

GROUP BY UName, Date_ID, UWorkDayID, WeekDay_ID, uhrsreducer)a

GROUP BY UName
