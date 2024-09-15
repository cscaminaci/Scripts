SELECT
    AAreaDesc AS [Client],
    ADateCreated AS [Date Created],
    ISNULL(UserCount, 0) AS [Number of Users],
    ISNULL(TicketCount, 0) AS [Number of Tickets]
FROM
    Area
    LEFT JOIN (
        SELECT
            SArea,
            COUNT(*) AS [UserCount]
        FROM
            Users
            INNER JOIN Site ON USite = SSiteNum
        GROUP BY
            SArea
    ) Users ON SArea = AArea
    LEFT JOIN (
        SELECT
            AreaInt,
            COUNT(*) AS [TicketCount]
        FROM
            Faults
        GROUP BY
            AreaInt
    ) Faults ON AreaInt = AArea
WHERE
    AIsInactive = 0
