SELECT

(SELECT AAreaDesc FROM Area WHERE AArea = LArea) AS [Customer],

CASE
WHEN LType=0 THEN CONVERT(NVARCHAR,'Software Licence')
WHEN LType=1 THEN CONVERT(NVARCHAR,'Subscription')
END AS [Licence or Sub],

LDesc AS [Name],

LCount AS [Count now],

IIF(
    (SELECT LCWhen FROM LicenceChange WHERE LCFieldID = -1 AND LCLID = LID) > DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)
    , 0
    , LCount - ISNULL((SELECT SUM(ISNULL(TRY_CAST(LCNewValue AS INT),0) - ISNULL(TRY_CAST(LCOldValue AS INT),0)) 
    FROM LicenceChange
    WHERE LCFieldID = 1 AND LCLID = LID
    AND DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)),0)
) AS [Count at the start of this month],

IIF(
    (SELECT LCWhen FROM LicenceChange WHERE LCFieldID = -1 AND LCLID = LID) > DATEADD(month, DATEDIFF(month, 0, GETDATE()), -1)
    , 0
    , LCount - ISNULL((SELECT SUM(ISNULL(TRY_CAST(LCNewValue AS INT),0) - ISNULL(TRY_CAST(LCOldValue AS INT),0)) 
    FROM LicenceChange
    WHERE LCFieldID = 1 AND LCLID = LID
    AND DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)
    OR DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), -1)),0)
) AS [Count at the start of last month],

IIF(
    (SELECT LCWhen FROM LicenceChange WHERE LCFieldID = -1 AND LCLID = LID) > DATEADD(month, DATEDIFF(month, 0, GETDATE()), -2)
    , 0
    , LCount - ISNULL((SELECT SUM(ISNULL(TRY_CAST(LCNewValue AS INT),0) - ISNULL(TRY_CAST(LCOldValue AS INT),0)) 
    FROM LicenceChange
    WHERE LCFieldID = 1 AND LCLID = LID
    AND DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)
    OR DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), -1)
    OR DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), -2)),0)
) AS [Count at the start of month before last],

IIF(
    (SELECT LCWhen FROM LicenceChange WHERE LCFieldID = -1 AND LCLID = LID) > DATEADD(month, DATEDIFF(month, 0, GETDATE()), -3)
    , 0
    , LCount - ISNULL((SELECT SUM(ISNULL(TRY_CAST(LCNewValue AS INT),0) - ISNULL(TRY_CAST(LCOldValue AS INT),0)) 
    FROM LicenceChange
    WHERE LCFieldID = 1 AND LCLID = LID
    AND DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)
    OR DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), -1)
    OR DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), -2)
    OR DATEADD(month, DATEDIFF(month, 0, LCWhen), 0) = DATEADD(month, DATEDIFF(month, 0, GETDATE()), -3)),0)
) AS [Count at the start of month two before last],

(SELECT LCWhen FROM LicenceChange WHERE LCFieldID = -1 AND LCLID = LID) AS [Date Created],

ISNULL((SELECT TOP 1 TRY_CAST(LCOldValue AS INT) FROM LicenceChange WHERE LCLID = LID AND LCFieldID = 1 ORDER BY LCWhen ASC), LCount) AS [Initial Count]




FROM Licence
