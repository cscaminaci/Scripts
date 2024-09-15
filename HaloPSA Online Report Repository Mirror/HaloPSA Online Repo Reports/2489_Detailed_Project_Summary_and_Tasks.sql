SELECT
    RIGHT('0000000' + CAST(FP.FaultID AS NVARCHAR(7)), 7) + ' - ' + FP.Symptom + ' - (' + SP.TStatusDesc + ')' AS [Project Info],
    FP.DateOccured AS [Project Date Occured],
    SP.TStatusDesc AS [Project Status],
    FC.FaultID AS [Project Task ID],
    FC.Symptom AS [Task Description],
    SC.TStatusDesc AS [Task Status],
    FC.DateOccured AS [Task Created On],
    FC.DateCleared AS [Task Cleared On],
    UName AS [Task Assigned To],
    [FCChargeType] AS [Labour Types],
    [FCChargeHours] AS [Labour Hours],
    [FCChargeRate] AS [Labour Rate],
    [FCChargeAmount] AS [Total Labour Charge]
FROM
    Faults FP
    INNER JOIN RequestType RTMain ON FP.RequestTypeNew = RTMain.RTID
    CROSS APPLY (
        SELECT
            *
        FROM
            Faults FC
            INNER JOIN RequestType RTChild ON FC.RequestTypeNew = RTChild.RTID
            INNER JOIN 
            (
                SELECT
                    [AFaultID],
                    STRING_AGG([FCChargeType], CHAR(13) + CHAR(10)) AS [FCChargeType],
                    STRING_AGG([FCChargeHours], CHAR(13) + CHAR(10)) AS [FCChargeHours],
                    STRING_AGG([FCChargeRate], CHAR(13) + CHAR(10)) AS [FCChargeRate],
                    STRING_AGG([FCChargeAmount], CHAR(13) + CHAR(10)) AS [FCChargeAmount]
                FROM
                    (
                        SELECT
                            FaultID AS [AFaultID],
                            REPLACE(FValue, ' ', CHAR(160)) AS [FCChargeType],
                            CAST(SUM(ActionChargeHours) AS DECIMAL(10, 1)) AS [FCChargeHours],
                            '£' + CAST(CAST(SUM(CRRate) AS MONEY) AS NVARCHAR(100)) + '/hr' AS [FCChargeRate],
                            '£' + CAST(CAST(SUM(ActionChargeAmount) AS MONEY) AS NVARCHAR(100)) AS [FCChargeAmount]
                        FROM
                            Actions
                            LEFT JOIN ChargeRate ON CRID = (ActionCode + 1)
                            LEFT JOIN Lookup ON FID = 17 AND FCode = CRID
                        WHERE
                            ActionCode + 1 <> 0
                            AND ActIsBillable = 1
                        GROUP BY
                            FaultID,
                            FValue
                    ) AS [InnerActionTimes]
                GROUP BY
                    [AFaultID]
            ) AS [ActionTimes] ON FC.FaultID = AFaultID 
        WHERE
            FXRefTo = FP.FaultID
            AND RTDesc = 'Project Task'
            AND FDeleted = 0
            AND FMergedIntoFaultID = 0
    ) FC
    INNER JOIN UName ON FC.AssignedToInt = UNum
    INNER JOIN TStatus SP ON FP.Status = SP.TStatus
    INNER JOIN TStatus SC ON FC.Status = SC.TStatus
WHERE
    RTMain.RTIsProject = 1
    AND FP.FDeleted = 0
    AND FP.FMergedIntoFaultID = 0
ORDER BY FP.DateOccured DESC OFFSET 0 ROWS
