SELECT
Who AS [Agent],
Faults.FaultID AS [Ticket ID],
Symptom AS [Summary],
RTDesc AS [Ticket Type],
IIF(FContractID IN (-1,0),'[None]',CHcontractRef) AS [Contract],
AAreaDesc AS [Client],
UUserName AS [User],

FORMAT(FLOOR(SUM(ISNULL(TimeTaken,0)))*100 + (SUM(ISNULL(TimeTaken,0))-FLOOR(SUM(ISNULL(TimeTaken,0))))*60,'00:00') AS [Time Logged (hh:mm)]

FROM Actions
JOIN Faults ON Faults.FaultID=Actions.FaultID
JOIN Area ON AArea=AreaInt
JOIN Users ON UID=UserID
JOIN ContractHeader ON CHID=FContractID
JOIN RequestType ON RTID=RequestTypeNew

WHERE Whe_ BETWEEN @StartDate AND @EndDate
AND TimeTaken <> 0
AND TimeTaken IS NOT NULL

GROUP BY Who, Faults.FaultID, Symptom, AAreaDesc, UUserName, FContractID, CHcontractRef, RTDesc


UNION ALL


SELECT 
z.[Agent] AS [Agent],
'' AS [Ticket ID],
'' AS [Summary],
'' AS [Ticket Type],
'' AS [Contract],
z.[Client] AS [Client],
'Total:' AS [User],
FORMAT(FLOOR(SUM([Time Logged (hh:mm)]))*100 + (SUM([Time Logged (hh:mm)])-FLOOR(SUM([Time Logged (hh:mm)])))*60,'00:00') AS [Time Logged (hh:mm)] FROM
    (
        SELECT
        Who AS [Agent],
        Faults.FaultID AS [Ticket ID],
        Symptom AS [Summary],
        RTDesc AS [Ticket Type],
        IIF(FContractID IN (-1,0),'[None]',CHcontractRef) AS [Contract],
        AAreaDesc AS [Client],
        UUserName AS [User],
        SUM(ISNULL(TimeTaken,0)) AS [Time Logged (hh:mm)]

        FROM Actions
        JOIN Faults ON Faults.FaultID=Actions.FaultID
        JOIN Area ON AArea=AreaInt
        JOIN Users ON UID=UserID
        JOIN ContractHeader ON CHID=FContractID
        JOIN RequestType ON RTID=RequestTypeNew

        WHERE Whe_ BETWEEN @StartDate AND @EndDate
        AND TimeTaken <> 0
        AND TimeTaken IS NOT NULL

        GROUP BY Who, Faults.FaultID, Symptom, AAreaDesc, UUserName, FContractID, CHcontractRef, RTDesc
    )z

GROUP BY z.[Agent], z.[Client]


UNION ALL


SELECT 
z.[Agent] AS [Agent],
'' AS [Ticket ID],
'' AS [Summary],
'' AS [Ticket Type],
'' AS [Contract],
'[All Selected Clients]' AS [Client],
'Total:' AS [User],
FORMAT(FLOOR(SUM([Time Logged (hh:mm)]))*100 + (SUM([Time Logged (hh:mm)])-FLOOR(SUM([Time Logged (hh:mm)])))*60,'00:00') AS [Time Logged (hh:mm)] FROM
    (
        SELECT
        Who AS [Agent],
        Faults.FaultID AS [Ticket ID],
        Symptom AS [Summary],
        RTDesc AS [Ticket Type],
        IIF(FContractID IN (-1,0),'[None]',CHcontractRef) AS [Contract],
        AAreaDesc AS [Client],
        UUserName AS [User],
        SUM(ISNULL(TimeTaken,0)) AS [Time Logged (hh:mm)]

        FROM Actions
        JOIN Faults ON Faults.FaultID=Actions.FaultID
        JOIN Area ON AArea=AreaInt
        JOIN Users ON UID=UserID
        JOIN ContractHeader ON CHID=FContractID
        JOIN RequestType ON RTID=RequestTypeNew

        WHERE Whe_ BETWEEN @StartDate AND @EndDate
        AND TimeTaken <> 0
        AND TimeTaken IS NOT NULL

        GROUP BY Who, Faults.FaultID, Symptom, AAreaDesc, UUserName, FContractID, CHcontractRef, RTDesc
    )z

GROUP BY z.[Agent]
