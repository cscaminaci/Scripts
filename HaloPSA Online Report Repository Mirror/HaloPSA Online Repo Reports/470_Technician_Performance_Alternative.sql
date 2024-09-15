SELECT uname AS Technician
    ,(
        SELECT COUNT(faultid)
        FROM faults
        WHERE STATUS = 9
            AND clearwhoint = O.unum
            AND Assignedtoint <> O.unum
            AND datecleared > @startdate
            AND datecleared < @enddate
        ) AS 'Other Technicians Tickets Closed'
    ,(
        SELECT COUNT(faultid)
        FROM faults
        WHERE STATUS = 9
            AND clearwhoint = O.unum
            AND Assignedtoint = O.unum
            AND datecleared > @startdate
            AND datecleared < @enddate
        ) AS 'Own Tickets Closed'
    ,(
        SELECT COUNT(actionnumber)
        FROM actions
        WHERE who = (
                SELECT uname
                FROM uname
                WHERE unum = O.unum
                )
            AND Whe_ > @startdate
            AND Whe_ < @enddate
        ) AS 'Number of Ticket Updtes'
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
        ) AS 'Number of Tickets Updted'        
    ,round(isnull((
                (
                    SELECT sum(isnull(timetaken, 0) + isnull(actions.nonbilltime, 0))
                    FROM actions
                    WHERE who = O.uname
                        AND whe_ > @startdate
                        AND whe_ < @enddate
                    ) / (
                    SELECT nullif(COUNT(Faultid), 0)
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
                    )
                ), ''), 2) * 60 AS 'Average Time (Minutes)'
    ,(
        SELECT round(isnull(sum(isnull(timetaken, 0) + isnull(actions.nonbilltime, 0)), 0), 2)
        FROM actions
        WHERE who = O.uname
            AND whe_ > @startdate
            AND whe_ < @enddate
        ) AS 'Total Time Spent on Tickets (Hours)'
    ,isnull(cast(100 - (
                round(cast((
                            SELECT nullif(count(faultid), 0)
                            FROM faults
                            WHERE slastate = 'O'
                                AND clearwhoint = O.unum
                                AND datecleared > @startdate
                                AND datecleared < @enddate
                                AND STATUS = 9
                                AND FexcludefromSLA = 0
                            ) AS FLOAT) / replace(cast((
                                (
                                    SELECT COUNT(faultid)
                                    FROM faults
                                    WHERE STATUS = 9
                                        AND clearwhoint = O.unum
                                        AND datecleared > @startdate
                                        AND datecleared < @enddate
                                        AND FexcludefromSLA = 0
                                    )
                                ) AS FLOAT), 0, 1), 4) * 100
                ) AS NVARCHAR(50)), '') AS 'Fix SLA (%)'
    ,isnull(cast(100 - (
                round(cast((
                            SELECT nullif(count(faultid), 0)
                            FROM faults
                            WHERE slaresponsestate = 'O'
                                AND dateoccured > @startdate
                                AND dateoccured < @enddate
                                AND assignedtoint = O.unum
                                AND FexcludefromSLA = 0
                            ) AS FLOAT) / replace(cast((
                                (
                                    SELECT COUNT(faultid)
                                    FROM faults
                                    WHERE assignedtoint = O.unum
                                        AND dateoccured > @startdate
                                        AND dateoccured < @enddate
                                        AND FexcludefromSLA = 0
                                    )
                                ) AS FLOAT), 0, 1), 4) * 100
                ) AS NVARCHAR(50)), '') AS 'Response SLA (%)'
    ,isnull(cast((
                SELECT round(sum(convert(float,datecleared-dateoccured)) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND clearwhoint = O.unum
                    AND datecleared > @startdate
                    AND datecleared < @enddate
                ) AS NVARCHAR(10)), '') AS 'Average Ticket Closure Time (Hours)'
FROM uname O                                                                                                   
WHERE unum <> 1
GROUP BY uname             
    ,unum

