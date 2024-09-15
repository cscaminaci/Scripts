SELECT format(date_id, 'yyyy-MM-dd') AS [WeekBeginning]
                                                          
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE dateoccured >= cast(date_id AS DATETIME)
            AND dateoccured < (cast(date_id AS DATETIME) + 7)
			AND fdeleted = FMergedIntoFaultid
        AND requesttypenew in (SELECT rtid FROM requesttype WHERE rtisproject = 0 AND rtisopportunity = 0)
        ) AS [Tickets Opened]
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE datecleared >= cast(date_id AS DATETIME)
            AND datecleared < (cast(date_id AS DATETIME) + 7)
			AND fdeleted = FMergedIntoFaultid
        AND requesttypenew in (SELECT rtid FROM requesttype WHERE rtisproject = 0 AND rtisopportunity = 0)
        ) AS [Tickets Closed]
	,(
		SELECT count(faultid)
		FROM faults
		WHERE dateoccured BETWEEN cast(date_id as datetime) AND (cast(date_id AS DATETIME) + 7)
		  AND datecleared NOT BETWEEN cast(date_id as datetime) AND (cast(date_id AS DATETIME) + 7)
		  AND requesttypenew in (SELECT rtid FROM requesttype WHERE rtisproject = 0 AND rtisopportunity = 0)
		  AND fdeleted = FMergedIntoFaultid
		) AS [Tickets Outstanding]
FROM calendar
WHERE weekday_id = 2
    AND date_id < getdate()
    and date_id>@startdate
    and date_id<@enddate
