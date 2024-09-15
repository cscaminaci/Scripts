SELECT who AS 'Technician'
    ,faultid AS 'TicketID'
    ,Whe_ AS 'Date'
    ,(
        SELECT fvalue
        FROM lookup
        WHERE fid = 17
            AND fcode = (actioncode + 1)
        ) 'Labour Rate'
    ,(
        SELECT aareadesc
        FROM area
        WHERE aarea = (
                SELECT areaint
                FROM faults
                WHERE actions.faultid = faults.faultid and fdeleted=0
                )
        ) Client
    ,round(((timetaken + timetakenadjusted)), 2) Hours
    ,ChargeRateType = CASE 
        WHEN actioncode + 1 IN (
                SELECT crchargeid
                FROM chargerate
                )
            AND (
                SELECT areaint
                FROM faults
                WHERE faults.faultid = actions.faultid and fdeleted=0
                ) = (
                SELECT crarea
                FROM chargerate
                WHERE crarea = (
                        SELECT areaint
                        FROM faults
                        WHERE faults.faultid = actions.faultid and fdeleted=0
                        )
                    AND crchargeid = actioncode + 1
                )
            THEN 'Overriding Rate'
        ELSE 'Global'
        END
    ,ChargeRate = CASE 
        WHEN actioncode + 1 IN (
                SELECT crchargeid
                FROM chargerate
                )
            AND (
                SELECT areaint
                FROM faults
                WHERE faults.faultid = actions.faultid and fdeleted=0
                ) = (
                SELECT crarea
                FROM chargerate
                WHERE crarea = (
                        SELECT areaint
                        FROM faults
                        WHERE faults.faultid = actions.faultid and fdeleted=0
                        )
                    AND crchargeid = actioncode + 1
                )
            THEN (
                    SELECT TOP 1 crrate
                    FROM chargerate
                    WHERE (crchargeid - 1) = actioncode
                        AND crstartdate < whe_
                        AND crarea = (
                            SELECT areaint
                            FROM faults
                            WHERE actions.faultid = faults.faultid and fdeleted=0
                            )
                    ORDER BY crstartdate DESC
                    )
        ELSE (
                SELECT TOP 1 crrate
                FROM chargerate
                WHERE (crchargeid - 1) = actioncode
                    AND crstartdate < whe_
                    AND crarea = 0
                ORDER BY crstartdate DESC
                )
        END
    ,(round(((timetaken + timetakenadjusted)), 2)) * (
        CASE 
            WHEN actioncode + 1 IN (
                    SELECT crchargeid
                    FROM chargerate
                    )
                AND (
                    SELECT areaint
                    FROM faults
                    WHERE faults.faultid = actions.faultid and fdeleted=0
                    ) = (
                    SELECT crarea
                    FROM chargerate
                    WHERE crarea = (
                            SELECT areaint
                            FROM faults
                            WHERE faults.faultid = actions.faultid and fdeleted=0
                            )
                        AND crchargeid = actioncode + 1
                    )
                THEN (
                        SELECT TOP 1 crrate
                        FROM chargerate
                        WHERE (crchargeid - 1) = actioncode
                            AND crstartdate < whe_
                            AND crarea = (
                                SELECT areaint
                                FROM faults
                                WHERE actions.faultid = faults.faultid and fdeleted=0
                                )
                        ORDER BY crstartdate DESC
                        )
            ELSE (
                    SELECT TOP 1 crrate
                    FROM chargerate
                    WHERE (crchargeid - 1) = actioncode
                        AND crstartdate < whe_
                        AND crarea = 0
                    ORDER BY crstartdate DESC
                    )
            END
        ) Total
    ,traveltime AS 'Travel Time'
FROM actions
WHERE timetaken <> 0
    AND actioncode <> - 1

