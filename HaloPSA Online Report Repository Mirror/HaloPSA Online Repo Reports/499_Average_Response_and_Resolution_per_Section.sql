
SELECT SDSectionName AS Section
    ,isnull(cast((
                SELECT round(sum(FResponseTime) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND Sectio_ = O.SDSectionName
                    AND datecleared > getdate()-7
                    AND datecleared < getdate()
 and fdeleted=0

                ) AS NVARCHAR(10)), '') AS 'AVG Response (Last 7 Days)'
    ,isnull(cast((
                SELECT round(sum(FResponseTime) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND Sectio_ = O.SDSectionName
                    AND datecleared > getdate()-30
                    AND datecleared < getdate()
 and fdeleted=0

                ) AS NVARCHAR(10)), '') AS 'AVG Response (Last 30 Days)'
    ,isnull(cast((
                SELECT round(sum(Elapsedhrs) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND Sectio_ = O.SDSectionName
                    AND datecleared > getdate()-7
                    AND datecleared < getdate()
 and fdeleted=0

                ) AS NVARCHAR(10)), '') AS 'AVG Resolution (Last 7 Days)'
    ,isnull(cast((
                SELECT round(sum(Elapsedhrs) / nullif(count(*), 0), 2)
                FROM Faults
                WHERE STATUS = 9
                    AND Sectio_ = O.SDSectionName
                    AND datecleared > getdate()-30
                    AND datecleared < getdate()
 and fdeleted=0

                ) AS NVARCHAR(10)), '') AS 'AVG Resolution (Last 30 Days)'
FROM SectionDetail O                                                                                           
                        
GROUP BY SDSectionName    


