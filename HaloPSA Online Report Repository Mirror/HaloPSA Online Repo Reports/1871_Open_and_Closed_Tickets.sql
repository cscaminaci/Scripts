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
        AND sectio_ not in ('US Support','AUS Support') AND requesttypenew in ('60','102','1') AND fdeleted = fmergedintofaultid
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
        AND sectio_ not in ('US Support','AUS Support') AND requesttypenew in ('60','102','1') AND fdeleted = fmergedintofaultid
        ) AS [Open Calls at End]                                                                
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE dateoccured >= cast(date_id AS DATETIME)
            AND dateoccured < (cast(date_id AS DATETIME) + 7)
        AND sectio_ not in ('US Support','AUS Support') AND requesttypenew in ('60','102','1') AND fdeleted = fmergedintofaultid
        ) AS [Tickets Opened During]
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE datecleared >= cast(date_id AS DATETIME)
            AND datecleared < (cast(date_id AS DATETIME) + 7)
        AND sectio_ not in ('US Support','AUS Support') AND requesttypenew in ('60','102','1') AND fdeleted = fmergedintofaultid
        ) AS [Tickets Closed During]
FROM calendar
WHERE weekday_id = 2
    AND date_id < getdate()
    and date_id>@startdate
    and date_id<@enddate




