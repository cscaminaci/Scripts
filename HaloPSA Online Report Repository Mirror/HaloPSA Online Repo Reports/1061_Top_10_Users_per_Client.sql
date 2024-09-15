SELECT d.[Year]
       ,d.[Month]
       ,d.[Client]
       ,d.[User]
       ,d.[Rank]
       ,d.[Total]
       ,CAST(100*CAST(d.[Total] as DECIMAL(18,2))/SUM(d.[Total]) OVER (PARTITION BY d.[Client],d.[Month],d.[Year]) as DECIMAL(18,2)) as [Percentage]

FROM (
       SELECT Datepart(yyyy, dateoccured) AS [Year]
              ,(
                     SELECT DISTINCT (month_nm)
                     FROM calendar
                     WHERE DATEPART(mm, dateoccured) = date_month
                     ) AS [Month]
              ,aareadesc AS [Client]
              ,username AS [User]
              ,Rank() OVER (
                     PARTITION BY AAREADESC
                     ,datepart(mm, dateoccured)
                     ,datepart(yyyy, dateoccured) ORDER BY count(username) DESC
                     ) AS [Rank]
              ,count(*) AS [Total]
       FROM Faults
       LEFT JOIN Area ON Aarea = Areaint
       GROUP BY aareadesc
              ,username
              ,datepart(mm, dateoccured)
              ,datepart(yyyy, dateoccured)
       ) d
WHERE RANK <= 10

