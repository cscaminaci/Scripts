SELECT
    *,
    CAST(ISNULL([Previously Added], 0) - ISNULL([Previously Used], 0) + SUM([Effective Hours]) OVER (PARTITION BY [Client Name],[Contract Reference] ORDER BY [Date] ASC, [Ticket ID] ASC) AS DECIMAL(10, 2)) AS [Running Total]
FROM
    (
        /* PrePay Hours Used By Actions */
        SELECT
            AAreaDesc AS [Client Name],
            FaultID AS [Ticket ID],
            username as [End User],
            ACTIONCONTRACTID AS [Contract ID],
            (select CHcontractRef from contractheader where CHID=ACTIONCONTRACTID) AS [Contract Reference],
            ActionDateOccurred as [Date],
            RTDesc AS [Request Type],
            Symptom AS [Summary],
            Category2 AS [Category],
            CAST([Hours] AS DECIMAL(10, 2)) AS [Hours],
            'Support' AS [Type],
            Tech AS [Agent],
            -[Hours] AS [Effective Hours],
            (select note from actions where actions.faultid=faults.faultid and actionnumber=whichaction) as [Ticket Note],
            TSTATUSDESC as [Status],
            (select tstatusdesc from actions join tstatus on tstatus=ActionStatusAfter where actions.faultid=faults.faultid and actionnumber=whichaction) as [Status After Action],
            whichaction as [Action Number]
        FROM
            Faults
            INNER JOIN (
                SELECT
                    FaultID AS [AFaultID],
                    SUM(ActionPrePayHours) AS [Hours],
                    ACTIONcontractid AS [ACTIONcontractid],
                    actionnumber as [whichaction],
                    Whe_ as [ActionDateOccurred],
                    who as [Tech]
                FROM
                    Actions
                GROUP BY
                    FaultID,ACTIONcontractid,actionnumber, Whe_, who
            ) Actions ON AFaultID = FaultID
            INNER JOIN Area ON AreaInt = AArea
            LEFT JOIN RequestType ON RequestTypeNew = RTID
            LEFT JOIN UName ON ClearWhoInt = UNum
            join tstatus on tstatus=status
        WHERE
            FDeleted = 0
            AND FMergedIntoFaultID = 0
            AND [Hours] > 0
            AND ActionDateOccurred BETWEEN @startdate AND @enddate

        UNION ALL

        /* PrePay Topups */
        SELECT
            AAreaDesc AS [Client Name],
            NULL AS [Ticket ID],
            NULL as [End User],
            PPContractID AS [Contract ID],
            (select CHcontractRef from contractheader where CHID=PPContractID) AS [Contract Reference],
            PPDate AS [Date],
            NULL AS [Request Type],
            NULL AS [Summary],
            NULL AS [Category],
            CAST(ISNULL(PPHours, PPAmount) AS DECIMAL(10, 2)) AS [Hours],
            'Top Up' AS [Type],
            NULL AS [Employee Name],
            ISNULL(PPHours, PPAmount) AS [Effective Hours],
            NULL as [Ticket Note],
            NULL AS [Status],
            NULL as [Status After Action],

            NULL AS [Action Number]
        FROM
            PrePayHistory
            INNER JOIN Area ON PPAreaInt = AArea
        WHERE
            PPDate BETWEEN @startdate AND @enddate
    ) IQ
    /* PrePay Hours Used Before The Date Range */
    LEFT JOIN (
        SELECT
            AAreaDesc AS [Used Area],
            CAST(SUM(ActionPrePayHours) AS DECIMAL(10, 2)) AS [Previously Used]
        FROM
            Actions
            LEFT JOIN Faults ON Actions.FaultID = Faults.FaultID
            LEFT JOIN Area ON AreaInt = AArea
        WHERE
            FDeleted = 0
            AND FMergedIntoFaultID = 0
            AND Whe_ < @startdate
        GROUP BY
            AAreaDesc
    ) TimeNegative ON [Client Name] = [Used Area]
    /* PrePay Hours Added Before The Date Range */
    LEFT JOIN (
        SELECT
            AAreaDesc AS [Added Area],
            CAST(SUM(ISNULL(PPHours, PPAmount)) AS DECIMAL(10, 2)) AS [Previously Added]
        FROM
            PrePayHistory
            LEFT JOIN Area ON PPAreaInt = AArea
        WHERE
            PPDate < @startdate
        GROUP BY
            AAreaDesc
    ) TimePositive ON [Client Name] = [Added Area]
ORDER BY
    [Client Name] ASC,
    [Date] ASC
OFFSET 0 ROWS
