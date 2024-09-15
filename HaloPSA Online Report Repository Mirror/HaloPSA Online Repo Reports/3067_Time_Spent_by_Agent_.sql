SELECT
    UName AS [Agent],
    USection AS [Team],
    RIGHT('000' + CAST(SUM(Time) / 60 AS VARCHAR(10)), 3) + ':' + RIGHT('00' + CAST(SUM(Time) % 60 AS VARCHAR(2)), 2) AS [Working Hours],
    ISNULL(CTC, 0) AS [Tickets Closed]
FROM
    (
        SELECT
            UName,
            UNum,
            MAX(USection) AS [USection],
            ISNULL(DATEDIFF(MINUTE, StartTime, EndTime), 0) AS [Time]
        FROM
            Calendar
            CROSS APPLY (
                SELECT
                    *
                FROM
                    UName
                WHERE
                    UName NOT LIKE 'Unassigned'
            ) AS [UName]
            LEFT JOIN Timesheet ON UNum = TSUNum AND Date_ID = TSDate
            LEFT JOIN (
                SELECT
                    WhoAgentID,
                    FORMAT(Whe_, 'dd/MM/yyyy') AS [ActionDate],
                    MIN(DATEADD(MINUTE, ISNULL(-60 * TimeTaken, 0), Whe_)) AS [FirstAction],
                    MAX(Whe_) AS [LastAction]
                FROM
                    Actions
                WHERE
                    Whe_ BETWEEN @startdate AND @enddate
                GROUP BY
                    WhoAgentID,
                    FORMAT(Whe_, 'dd/MM/yyyy')
            ) AS [Actions] ON WhoAgentID = UNum AND ActionDate = FORMAT(Date_ID, 'dd/MM/yyyy')
            OUTER APPLY (
                SELECT
                    IIF(TSStartDate > 0, TSStartDate, FirstAction) AS [StartTime],
                    IIF(FORMAT(GETDATE(), 'dd/MM/yyyy') = ActionDate, GETDATE(), IIF(TSEndDate > 0, TSEndDate, LastAction)) AS [EndTime]
            ) AS [Dates]
        WHERE
            Date_ID BETWEEN @startdate AND @enddate
        GROUP BY
            UName,
            UNum,
            EndTime,
            StartTime
    ) AS [Data]
    LEFT JOIN (
        SELECT
            ClearWhoInt,
            COUNT(*) AS [CTC]
        FROM
            Faults
        WHERE
            DateOccured BETWEEN @startdate AND @enddate
            AND FDeleted = 0
            AND FMergedIntoFaultID = 0
        GROUP BY
            ClearWhoInt
    ) AS [Faults] ON UNum = ClearWhoInt
    LEFT JOIN (
        SELECT
            WhoAgentID,
            SUM(TimeTaken) AS [BillableTime]
        FROM
            Actions
        WHERE
            ActIsBillable = 1
            AND Whe_ BETWEEN @startdate AND @enddate
        GROUP BY
            WhoAgentID
    ) AS [Billable] ON UNum = WhoAgentID
GROUP BY
    UName,
    USection,
    CTC,
    BillableTime
