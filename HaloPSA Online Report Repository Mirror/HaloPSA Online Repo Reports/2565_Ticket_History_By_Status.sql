SELECT
    FaultID AS [Ticket ID],
    TStatusDesc AS [Status],
    [Start Date],
    ISNULL(LAG([Start Date]) OVER (PARTITION BY FaultID ORDER BY [Start Date] DESC), GETDATE()) AS [End Date],
    CONVERT(DECIMAL(10, 2), CONVERT(DECIMAL(10, 2), DATEDIFF(SECOND, [Start Date], ISNULL(LAG([Start Date]) OVER (PARTITION BY FaultID ORDER BY [Start Date] DESC), GETDATE()))) / 60) AS [Minutes Elapsed]
FROM
    (
        SELECT
            FaultID,
            ADate AS [Start Date],
            TStatusDesc
        FROM 
            Faults
            INNER JOIN Audit ON FaultID = AFaultID AND AValue = 'status_id'
            INNER JOIN TStatus ON ATo = TStatus
        WHERE
            FDeleted = 0
            AND FMergedIntoFaultID = 0
            AND DateOccured BETWEEN @startdate AND @enddate

        UNION ALL

        SELECT
            FaultID,
            DateOccured AS [Start Date],
            TStatusDesc
        FROM
            Faults
            LEFT JOIN (
                SELECT
                    AFaultID,
                    AFrom AS [Old Status],
                    ROW_NUMBER() OVER (PARTITION BY AFaultID ORDER BY ADate ASC) As [RowNo]
                FROM
                    Audit
                WHERE
                    AValue = 'status_id'
            ) Audit ON FaultID = AFaultID AND RowNo = 1
            OUTER APPLY (
                SELECT
                    ISNULL([Old Status], Status) AS [Status Number]
            ) StatusCheck
            INNER JOIN TStatus ON [Status Number] = TStatus
        WHERE
            FDeleted = 0
            AND FMergedIntoFaultID = 0
            AND DateOccured BETWEEN @startdate AND @enddate
    ) Dat
ORDER BY [Start Date] DESC OFFSET 0 ROWS
