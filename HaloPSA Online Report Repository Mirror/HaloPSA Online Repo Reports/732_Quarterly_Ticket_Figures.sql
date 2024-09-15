SELECT date_id AS [QuarterBeginning]
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
        WHERE dateoccured < (cast(date_id AS DATETIME) + 90)
            AND (
                datecleared > (cast(date_id AS DATETIME) + 90)
                OR datecleared IS NULL
                OR datecleared < 5
                )
        ) AS [Open Calls at End]                                                                
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE dateoccured >= cast(date_id AS DATETIME)
            AND dateoccured < (cast(date_id AS DATETIME) + 90)
        ) AS [Calls Opened During]
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE datecleared >= cast(date_id AS DATETIME)
            AND datecleared < (cast(date_id AS DATETIME) + 90)
        ) AS [Calls Closed During]
FROM calendar
WHERE month_nm in ('January','April','July','October') 
	and first_day_of_month=date_id
    AND date_id < getdate()
    and date_id>@startdate
    and date_id<@enddate

