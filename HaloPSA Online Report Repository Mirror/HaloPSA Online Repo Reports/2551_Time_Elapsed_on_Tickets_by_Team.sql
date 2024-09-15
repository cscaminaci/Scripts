SELECT
    RTLSection AS [Team],
    UName AS [Agent Assigned],
    FaultID AS [Ticket ID],
    TStatusDesc AS [Ticket Status],
    CAST(RTLElapsedHours AS DECIMAL(10, 2)) AS [Elapsed Hours]
FROM
    ResourceTimeLog
    INNER JOIN Faults ON RTLFaultID = FaultID
    INNER JOIN TStatus ON Status = TStatus
    INNER JOIN UName ON RTLUnum = UNum
WHERE
    FDeleted = 0
    AND FMergedIntoFaultID = 0
    AND DateOccured BETWEEN @startdate AND @enddate
