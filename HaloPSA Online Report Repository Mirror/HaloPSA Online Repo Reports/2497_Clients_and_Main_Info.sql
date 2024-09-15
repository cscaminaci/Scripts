SELECT
    AAreaDesc AS [Client Name],
    IIF(AIsInactive = 0, N'Active', N'Inactive') AS [Active],
    TreeDesc AS [Top Level],
    SDesc AS [Main Site Name],
    UUsername AS [Main Contact],
    SUBSTRING(UUsername, 0, CHARINDEX(' ', UUsername)) AS [First Name],
    SUBSTRING(UUsername, CHARINDEX(' ', UUsername), LEN(UUsername)) AS [Last Name],
    UEmail AS [Main Contact Email]
FROM
    Area
    LEFT JOIN Tree ON ATreeID = TreeID
    LEFT JOIN (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY SArea ORDER BY SArea ASC) AS [RowNo]
        FROM
            Site
        WHERE
            SIsInactive = 0
            AND SIsInvoiceSite = 1
    ) AS [Site] ON AArea = SArea AND [RowNo] = 1
    LEFT JOIN Users ON SMainContact = UID
