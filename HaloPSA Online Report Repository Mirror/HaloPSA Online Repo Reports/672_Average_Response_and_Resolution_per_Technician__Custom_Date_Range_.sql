SELECT uname AS Technician
    ,isnull(cast((
                SELECT round(sum(FResponseTime) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND clearwhoint = O.unum
                    AND datecleared > @startdate 
                    AND datecleared < @enddate 
                ) AS NVARCHAR(10)), '') AS 'AVG Response'
    ,isnull(cast((
                SELECT round(sum(Elapsedhrs) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND clearwhoint = O.unum
                    AND datecleared > @startdate 
                    AND datecleared < @enddate      
                ) AS NVARCHAR(10)), '') AS 'AVG Resolution'
FROM uname O                                                                                                   
WHERE unum <> 1
GROUP BY uname             
    ,unum




