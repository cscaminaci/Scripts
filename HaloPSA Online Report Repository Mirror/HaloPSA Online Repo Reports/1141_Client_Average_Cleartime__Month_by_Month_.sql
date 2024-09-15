SELECT [Client]
,[Year]
,round([Jan],2) as [Jan]
,round([Feb],2) as [Feb]
,round([Mar],2) as [Mar]
,round([Apr],2) as [Apr]
,round([May],2) as [May]
,round([Jun],2) as [Jun]
,round([Jul],2) as [Jul]
,round([Aug],2) as [Aug]
,round([Sep],2) as [Sep]
,round([Oct],2) as [Oct]
,round([Nov],2) as [Nov]
,round([Dec],2) as [Dec]

FROM

(SELECT (select aareadesc from area where aarea=areaint) AS [Client]
       ,date_year AS [Year]
       ,isnull([1] ,0) AS [Jan]
       ,isnull([2] ,0)  AS [Feb]
       ,isnull([3] ,0) AS [Mar]
       ,isnull([4] ,0) AS [Apr]
       ,isnull([5] ,0) AS [May]
       ,isnull([6] ,0) AS [Jun]
       ,isnull([7] ,0) AS [Jul]
       ,isnull([8] ,0) AS [Aug]
       ,isnull([9] ,0) AS [Sep]
       ,isnull([10],0)  AS [Oct]
       ,isnull([11],0)  AS [Nov]
       ,isnull([12],0)  AS [Dec]
FROM (
       SELECT DISTINCT areaint
              ,date_year
              ,date_month
              ,AVG(cleartime) OVER (
                     PARTITION BY areaint
                     ,date_year
                     ,date_month
                     ) AS [xC]
       FROM (
              SELECT DISTINCT faultid
                     ,areaint
                     ,dateoccured
					 ,cleartime
                     ,date_year
                     ,date_month
              FROM faults
              JOIN calendar ON date_year = datepart(year, dateoccured)
                     AND date_month = datepart(month, dateoccured)
			  JOIN area ON aarea=areaint
			  WHERE fmergedintofaultid=0 and fdeleted=0
              ) a
       ) src
pivot(max([xC]) FOR date_month IN (
                     [1]
                     ,[2]
                     ,[3]
                     ,[4]
                     ,[5]
                     ,[6]
                     ,[7]
                     ,[8]
                     ,[9]
                     ,[10]
                     ,[11]
                     ,[12]
                     )) pvr
)a






