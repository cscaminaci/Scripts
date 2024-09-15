SELECT date_id AS [WeekBeginning]
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE dateoccured < cast(date_id AS DATETIME)
            AND (
                datecleared > cast(date_id AS DATETIME)
                OR datecleared IS NULL
                OR datecleared < 5
                )
        ) AS [Open Calls at Start]
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE dateoccured < (cast(date_id AS DATETIME) + 7)
            AND (
                datecleared > (cast(date_id AS DATETIME) + 7)
                OR datecleared IS NULL
                OR datecleared < 5
                )
        ) AS [Open Calls at End]                                                                
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE dateoccured >= cast(date_id AS DATETIME)
            AND dateoccured < (cast(date_id AS DATETIME) + 7)
        ) AS [Calls Opened During]
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE datecleared >= cast(date_id AS DATETIME)
            AND datecleared < (cast(date_id AS DATETIME) + 7)
        ) AS [Calls Closed During]
FROM calendar
WHERE weekday_id = 2
    AND date_id < getdate()
    and date_id>@startdate
    and date_id<@enddate




