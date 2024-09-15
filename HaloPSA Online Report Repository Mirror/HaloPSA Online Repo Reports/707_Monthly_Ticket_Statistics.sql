SELECT Month
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE datepart(yy, dateoccured) = datepart(yy, date_id)
            AND datepart(mm, dateoccured) = datepart(mm, date_id)
            AND Requesttypenew=1
        ) AS [Tickets Logged]
    ,(                            
        SELECT count(faultid)
        FROM faults
        WHERE datepart(yy, datecleared) = datepart(yy, date_id)
            AND datepart(mm, datecleared) = datepart(mm, date_id)
            AND Requesttypenew=1
        ) AS [Tickets Closed]
    ,(
        SELECT isnull(CAST(FLOOR(round(avg(FRT), 2)) AS VARCHAR) + ':' + RIGHT('0' + CAST(FLOOR((((round(cast(avg(FRT) AS DECIMAL(18, 4)), 2) * 3600) % 3600) / 60)) AS VARCHAR), 2), '')
        FROM (
            SELECT convert(FLOAT, (
                        SELECT TOP 1 whe_
                        FROM actions
                        WHERE faults.faultid = actions.faultid
                            AND actoutcome LIKE 'Responded'
                        ORDER BY whe_ ASC
                        ) - dateoccured) AS FRT
            FROM faults
            WHERE datepart(yy, datecleared) = datepart(yy, date_id)
                AND datepart(mm, datecleared) = datepart(mm, date_id)
                AND Requesttypenew=1
                AND (
                    SELECT count(actionnumber)
                    FROM actions
                    WHERE faults.faultid = actions.faultid
                        AND actoutcome LIKE 'Responded'
                    ) > 0 
            ) b
        ) AS [FRSLA]
    ,(
        SELECT isnull(CAST(FLOOR(round(avg(Elapsedhrs), 2)) AS VARCHAR) + ':' + RIGHT('0' + CAST(FLOOR((((round(cast(avg(Elapsedhrs) AS DECIMAL(18, 4)), 2) * 3600) % 3600) / 60)) AS VARCHAR), 2), '')
        FROM (
            SELECT Elapsedhrs
            FROM faults
            WHERE datepart(yy, datecleared) = datepart(yy, date_id)
                AND datepart(mm, datecleared) = datepart(mm, date_id)
                AND Requesttypenew=1
            ) b
        ) AS [ART]
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE datepart(yy, datecleared) = datepart(yy, date_id)
            AND datepart(mm, datecleared) = datepart(mm, date_id)
            AND Requesttypenew=1
            AND fFirstTimeFix = 0
        ) AS [First Fix Resolution]
FROM (
    SELECT cast(right('00' + cast(datepart(MM, date_id) AS NVARCHAR(2)), 2) AS NVARCHAR(2)) + '/' + right(cast(datepart(year, date_id) AS NVARCHAR(4)), 2) AS [Month]
        ,date_id
    FROM calendar
    WHERE date_day = 1
        AND date_id > @startdate
        AND date_id < @enddate
    ) d   






