--dynamic

WITH cte AS (
    SELECT FAQid,
        FAQListDesc,
        cast(FAQListDesc AS varchar(200)) AS hierPath
    FROM faqlisthead
    UNION ALL
    SELECT r.FAQid,
        r.FAQListDesc,
        cast(
            cte.hierPath + ' > ' + r.FAQListDesc AS varchar(200)
        ) AS hierPath
    FROM faqlisthead r
        INNER JOIN cte ON cte.FAQid = r.FAQLevelFAQID
)

SELECT
    KB.datecreated AS [Date Created],
    ( select U1.uname FROM Uname U1 WHERE KB.whocreated = U1.unum) AS [Agent],
   
    (select top 1 hierPath from cte where cte.FAQid = FH.FAQid order by len(hierPath) desc) AS [Group],
    
    KB.abstract AS [Title],
    KB.Lastreviewdate AS [Last Review],
    KB.Nextreviewdate AS [Next Review],
    ( select U3.uname FROM Uname U3 WHERE KB.Reviewedby = U3.unum) AS [Reviewed by],
    KB.dateedited AS [Date Edited],
    ( select U2.uname FROM Uname U2 WHERE KB.whoedited = U2.unum) AS [Edited by]
    
FROM KBENTRY KB
JOIN FAQLISTDET FLD ON FLD.faqdkbid = KB.id
JOIN faqlisthead FH ON FLD.faqdid = FH.faqid

