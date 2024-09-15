SELECT uname AS Technician
    ,isnull(cast((
                SELECT round(sum(FResponseTime) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND clearwhoint = O.unum
                    AND datecleared > getdate()-7
                    AND datecleared < getdate()
                ) AS NVARCHAR(10)), '') AS 'AVG Response (Last 7 Days)'
    ,isnull(cast((
                SELECT round(sum(FResponseTime) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND clearwhoint = O.unum
                    AND datecleared > getdate()-30
                    AND datecleared < getdate()
                ) AS NVARCHAR(10)), '') AS 'AVG Response (Last 30 Days)'
    ,isnull(cast((
                SELECT round(sum(Elapsedhrs) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND clearwhoint = O.unum
                    AND datecleared > getdate()-7
                    AND datecleared < getdate()
                ) AS NVARCHAR(10)), '') AS 'AVG Resolution (Last 7 Days)'
    ,isnull(cast((
                SELECT round(sum(Elapsedhrs) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND clearwhoint = O.unum
                    AND datecleared > getdate()-30
                    AND datecleared < getdate()
                ) AS NVARCHAR(10)), '') AS 'AVG Resolution (Last 30 Days)'
FROM uname O                                                                                                   
WHERE unum <> 1
GROUP BY uname             
    ,unum


