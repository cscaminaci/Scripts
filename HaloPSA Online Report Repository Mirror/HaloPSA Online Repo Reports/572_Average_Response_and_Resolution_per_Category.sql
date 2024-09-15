 SELECT cdtype,cdcategoryname AS Category
    ,isnull(cast((
                SELECT round(sum(FResponseTime) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9 and requesttype in (2,3)
                    AND category2 = O.cdcategoryname
                    AND datecleared > getdate()-7
                    AND datecleared < getdate()
                ) AS NVARCHAR(10)), '') AS 'AVG Response (Last 7 Days)'
    ,isnull(cast((
                SELECT round(sum(FResponseTime) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9 and requesttype in (2,3)
                    AND category2 = O.cdcategoryname
                    AND datecleared > getdate()-30                                    
                    AND datecleared < getdate()
                ) AS NVARCHAR(10)), '') AS 'AVG Response (Last 30 Days)'
    ,isnull(cast((
                SELECT round(sum(Elapsedhrs) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9 and requesttype in (2,3)
                    AND category2 = O.cdcategoryname
                    AND datecleared > getdate()-7
                    AND datecleared < getdate()
                ) AS NVARCHAR(10)), '') AS 'AVG Resolution (Last 7 Days)'
    ,isnull(cast((
                SELECT round(sum(Elapsedhrs) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9 and requesttype in (2,3)
                    AND category2 = O.cdcategoryname
                    AND datecleared > getdate()-30
                    AND datecleared < getdate()
                ) AS NVARCHAR(10)), '') AS 'AVG Resolution (Last 30 Days)'
FROM categorydetail O                                                                                         
  
GROUP BY cdcategoryname             
    ,cdid,cdtype
