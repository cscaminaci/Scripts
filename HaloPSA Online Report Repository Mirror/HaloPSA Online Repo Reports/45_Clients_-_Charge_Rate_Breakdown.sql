SELECT (
        SELECT aareadesc
        FROM area
        WHERE aarea = areaint
        ) AS 'Area'
    ,(
        SELECT fvalue
        FROM lookup
        WHERE fid = 17
            AND fcode = actioncode + 1
        ) AS 'ChargeRate'
    ,round(sum(timetaken), 2) AS [Hours Used (decimal)]
    ,replace(cast(convert(DECIMAL(10, 2), cast(sum(timetaken) AS INT) + (((sum(timetaken) - cast(sum(timetaken) AS INT)) * .60))) AS VARCHAR), '.', ':') AS 'Hours Used (hhmm)'
    ,(
        SELECT rtdesc
        FROM requesttype
        WHERE requesttypenew = rtid
        ) AS 'Ticket Type'
FROM faults
INNER JOIN actions ON faults.faultid = actions.faultid
WHERE whe_ > @startdate
   AND whe_ < @enddate
GROUP BY actioncode
    ,areaint                        
    ,requesttypenew                      
                                                                                              

