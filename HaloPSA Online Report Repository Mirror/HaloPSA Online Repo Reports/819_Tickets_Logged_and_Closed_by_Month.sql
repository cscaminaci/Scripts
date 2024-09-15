SELECT Month
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE datepart(yy, dateoccured) = datepart(yy, date_id)
            AND datepart(mm, dateoccured) = datepart(mm, date_id)
            AND Requesttypenew IN (
					SELECT rtid
					FROM requesttype
					WHERE rtisopportunity = 0
						AND rtisproject = 0
					)
        ) AS [Tickets Logged]
    ,(                            
        SELECT count(faultid)
        FROM faults
        WHERE datepart(yy, datecleared) = datepart(yy, date_id)
            AND datepart(mm, datecleared) = datepart(mm, date_id)
            AND Requesttypenew IN (
					SELECT rtid
					FROM requesttype
					WHERE rtisopportunity = 0
						AND rtisproject = 0
					)
        ) AS [Tickets Closed]
FROM (
    SELECT cast(right('00' + cast(datepart(MM, date_id) AS NVARCHAR(2)), 2) AS NVARCHAR(2)) + '/' + right(cast(datepart(year, date_id) AS NVARCHAR(4)), 2) AS [Month]
        ,date_id
    FROM calendar
    WHERE date_day = 1
        AND date_id > @startdate
        AND date_id < @enddate
    ) d 



