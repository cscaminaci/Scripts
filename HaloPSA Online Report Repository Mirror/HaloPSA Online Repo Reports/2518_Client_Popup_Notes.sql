SELECT
    AAreaDesc AS [Client],
    APOPDateAdded AS [Date Added],
    APOPNote AS [Note]
FROM
    Area
    INNER JOIN AreaPopup ON AArea = APOPArea
    where aisinactive=0
