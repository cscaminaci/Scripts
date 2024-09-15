SELECT
    FaultID AS [Project ID],
    Symptom AS [Subject],
    AAreaDesc AS [Client],
    SDesc AS [Site],
    Username AS [User],
    Category2 AS [Category],
    DateCleared AS [Date Closed],
    DateOccured AS [Date Opened],
    TStatusDesc AS [Status],
    UName AS [Tech],
    FProjectTimeBudget AS [Time Budget],
    FProjectMoneyBudget AS [Money Budget],
    FProjectTimeActual AS [Time Actual],
    FProjectMoneyActual AS [Money Actual]
FROM
    Faults 
    INNER JOIN RequestType on RTID = RequestTypeNew
    LEFT JOIN Area ON AreaInt = AArea
    LEFT JOIN Site ON SiteNumber = SSiteNum
    LEFT JOIN TStatus ON Status = TStatus
    LEFT JOIN UName ON UNum = AssignedToInt
WHERE
    RTIsProject = 1
