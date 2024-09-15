SELECT
    UName AS [Technician],
    CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL([Hours Logged], 0), 2) * 60 AS INT), 0) / 60) AS NVARCHAR(9)) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL([Hours Logged], 0), 2) * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) AS [Hours Logged],
    CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL([Travel Time], 0), 2) * 60 AS INT), 0) / 60) AS NVARCHAR(9)) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL([Travel Time], 0), 2) * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) AS [Travel Time],
    CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(SUM(NWorkHours - UHrsReducer), 0), 2) * 60 AS INT), 0) / 60) AS NVARCHAR(9)) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL(SUM(NWorkHours - UHrsReducer), 0), 2) * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) AS [Expected Hours],
    CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL([Hours Logged], 0) + ISNULL([Travel Time], 0), 2) * 60 AS INT), 0) / 60) AS NVARCHAR(9)) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(CAST(ROUND(ISNULL([Hours Logged], 0) + ISNULL([Travel Time], 0), 2) * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) AS [Total Hours],
    CAST(ISNULL(ROUND(((ISNULL([Hours Logged], 0) + ISNULL([Travel Time], 0)) / NULLIF(ISNULL(SUM(NWorkHours - UHrsReducer), 0), 0)) * 100, 0), 0) AS VARCHAR(50)) + '%' AS [%],
	IIF(SUM(NWorkHours - UHrsReducer) < ([Hours Logged] + [Travel Time]), 'Complete', 'Incomplete') AS [Note]
FROM
    UName
    CROSS APPLY (
        SELECT
            Date_ID,
            Weekday_NM,
            NWorkHours
        FROM
            Calendar
            LEFT JOIN NewWorkdays ON Weekday_ID = NDayID
        WHERE
            NIncluded = 1
            AND NWorkDay = UWorkDayID
            AND Date_ID >= @startdate AND Date_ID < @enddate
    ) NewWorkdays
    LEFT JOIN (
        SELECT
            WhoAgentID,
            SUM(TimeTaken) AS [Hours Logged],
            SUM(TravelTime) AS [Travel Time]
        FROM
            Actions
        WHERE
            Whe_ >= @startdate AND Whe_ < @enddate
        GROUP BY
            WhoAgentID
    ) Actions ON UNum = WhoAgentID
WHERE
    UIsDisabled = 0
GROUP BY
    UName,
    [Hours Logged],
    [Travel Time]
