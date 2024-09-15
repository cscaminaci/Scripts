SELECT d.[Year]
       ,d.[Month]
	   ,d.[Client]
       ,d.[Site]
       ,d.[User]
       ,d.[Rank]
       ,d.[Total]
       ,CAST(100*CAST(d.[Total] as DECIMAL(18,2))/SUM(d.[Total]) OVER (PARTITION BY d.[Site],d.[Month],d.[Year]) as DECIMAL(18,2)) as [Percentage]

FROM (
       SELECT Datepart(yyyy, dateoccured) AS [Year]
              ,(
                     SELECT DISTINCT (month_nm)
                     FROM calendar
                     WHERE DATEPART(mm, dateoccured) = date_month
                     ) AS [Month]
			  ,(select aareadesc from area where Sarea=Aarea) as [Client]
              ,sdesc AS [Site]
              ,Username AS [User]
              ,Rank() OVER (
                     PARTITION BY sdesc
                     ,datepart(mm, dateoccured)
                     ,datepart(yyyy, dateoccured) ORDER BY count(Username) DESC
                     ) AS [Rank]
              ,count(*) AS [Total]
       FROM Faults
       LEFT JOIN site ON ssitenum = sitenumber
	   where Username <> 'General User'
       GROUP BY sarea
			  ,sdesc
              ,Username
              ,datepart(mm, dateoccured)
              ,datepart(yyyy, dateoccured)
       ) d
WHERE RANK <= 10
