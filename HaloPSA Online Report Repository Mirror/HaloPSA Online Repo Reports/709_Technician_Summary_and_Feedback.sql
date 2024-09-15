SELECT uname AS Technician
    ,(
        SELECT COUNT(faultid)
        FROM faults
        WHERE STATUS = 9
            AND clearwhoint = O.unum
            AND datecleared > @startdate
            AND datecleared < @enddate
        ) AS 'Tickets Resolved'
    ,(
        SELECT COUNT(faultid)
        FROM faults
        WHERE takenby LIKE (
                SELECT uname
                FROM uname
                WHERE unum = O.unum
                )
            AND dateoccured > @startdate
            AND dateoccured < @enddate
        ) AS 'Tickets Logged'
    ,(
        SELECT COUNT(Faultid)
        FROM Faults
        WHERE faults.faultid IN (
                SELECT actions.faultid
                FROM actions
                WHERE who = (
                        SELECT uname
                        FROM uname
                        WHERE unum = O.unum
                        )
                    AND Whe_ > @startdate
                    AND Whe_ < @enddate
                )
        ) AS 'Tickets Updted'
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
            WHERE datecleared > @startdate
                AND datecleared < @enddate
                AND Requesttypenew = 1
                AND FwhoResponded = O.unum
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
            WHERE datecleared > @startdate
                AND datecleared < @enddate
                AND Requesttypenew = 1
                AND Clearwhoint = Unum
            ) b
        ) AS [ART]
    ,(
        SELECT count(faultid)
        FROM faults
        WHERE datecleared > @startdate
            AND datecleared < @enddate
            AND Requesttypenew = 1
            AND fFirstTimeFix = 0
            AND Clearwhoint = Unum
        ) AS [First Fix Resolution]
    ,(
        SELECT count(fbscore)
        FROM feedback
        INNER JOIN faults ON fbfaultid = faultid
        WHERE clearwhoint = O.unum
            AND datecleared > @startdate
            AND datecleared < @enddate
        ) AS [Feedback Count]
    ,(
        SELECT isnull(round((4 - (avg(cast(fbscore as float)))) * (100.0/3), 0), '')
        FROM feedback
        INNER JOIN faults ON fbfaultid = faultid
        WHERE clearwhoint = O.unum
            AND datecleared > @startdate
            AND datecleared < @enddate
        ) AS [Feedback Score (%)]
FROM uname O
WHERE unum <> 1
GROUP BY uname
    ,unum



