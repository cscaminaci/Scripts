SELECT date_id AS [WeekBeginning]
                                                          
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE dateoccured >= cast(date_id AS DATETIME)
            AND dateoccured < (cast(date_id AS DATETIME) + 7)
        AND requesttypenew in (60,1,102)
        ) AS [Calls Opened During]
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE datecleared >= cast(date_id AS DATETIME)
            AND datecleared < (cast(date_id AS DATETIME) + 7)
        AND requesttypenew in (60,1,102)
        ) AS [Calls Closed During]
FROM calendar
WHERE weekday_id = 2
    AND date_id < getdate()
    and date_id>@startdate
    and date_id<@enddate




