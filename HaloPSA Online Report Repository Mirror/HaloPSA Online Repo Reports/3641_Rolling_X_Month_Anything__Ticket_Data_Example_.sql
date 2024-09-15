--DYNAMIC SQL
DECLARE @cols AS NVARCHAR(max)
DECLARE @query AS NVARCHAR(max)
DECLARE @maxDateTime AS NVARCHAR(max)
DECLARE @minDateTime AS NVARCHAR(max)

SET @cols = Stuff((SELECT *
                   FROM   (SELECT TOP 10000 ',' + Quotename(month_nm) AS
                                            month_nm
                           FROM   (SELECT Row_number()
                                            OVER(
                                              partition BY month_nm
                                              ORDER BY date_id ASC) AS r,
                                          month_nm,
                                          date_id
                                   FROM   calendar
                                   WHERE  date_id BETWEEN
                                          @startdate AND @enddate) a
                           WHERE  a.r = 1
                           ORDER  BY date_id ASC) b
                   FOR xml path(''), type).value('.', 'NVARCHAR(MAX)'), 1, 1, ''
            )
SET @maxDateTime = (SELECT Datediff(minute, 0, Max(date_id))
                    FROM   calendar
                    WHERE  date_id BETWEEN @startdate AND @enddate)
SET @minDateTime = (SELECT Datediff(minute, 0, Min(date_id))
                    FROM   calendar
                    WHERE  date_id BETWEEN @startdate AND @enddate) 
    
set @query = '
SELECT 
    ''4. Tickets Logged'' as [Description],
    * 
from (
    select
        month_nm,
        (SELECT COUNT(*) FROM faults WHERE CONVERT(DATE, dateoccured) = CONVERT(DATE, date_id) and fdeleted=0 and fmergedintofaultid=0) AS [Count]
    from calendar
    WHERE 
        date_id BETWEEN DATEADD(MINUTE, ('+ @minDateTime +'), 0) AND DATEADD(MINUTE, ('+ @maxDateTime +'), 0)
) src
PIVOT (
    SUM([Count]) for month_nm in (' + @cols + ')
) pvt

/*--------------------------------------------------------*/

UNION

SELECT 
    ''1. Incidents Logged'' as [Description],
    * 
from (
    select
        month_nm,
        (SELECT COUNT(*) FROM faults WHERE CONVERT(DATE, dateoccured) = CONVERT(DATE, date_id) and fdeleted=0 and fmergedintofaultid=0 and requesttype=1) AS [Count]
    from calendar
    WHERE 
        date_id BETWEEN DATEADD(MINUTE, ('+ @minDateTime +'), 0) AND DATEADD(MINUTE, ('+ @maxDateTime +'), 0)
) src
PIVOT (
    SUM([Count]) for month_nm in (' + @cols + ')
) pvt

/*--------------------------------------------------------*/

UNION

SELECT 
    ''2. Requests Logged'' as [Description],
    * 
from (
    select
        month_nm,
        (SELECT COUNT(*) FROM faults WHERE CONVERT(DATE, dateoccured) = CONVERT(DATE, date_id) and fdeleted=0 and fmergedintofaultid=0 and requesttype=3) AS [Count]
    from calendar
    WHERE 
        date_id BETWEEN DATEADD(MINUTE, ('+ @minDateTime +'), 0) AND DATEADD(MINUTE, ('+ @maxDateTime +'), 0)
) src
PIVOT (
    SUM([Count]) for month_nm in (' + @cols + ')
) pvt

/*--------------------------------------------------------*/

UNION

SELECT 
    ''3. Other Types Logged'' as [Description],
    * 
from (
    select
        month_nm,
        (SELECT COUNT(*) FROM faults WHERE CONVERT(DATE, dateoccured) = CONVERT(DATE, date_id) and fdeleted=0 and fmergedintofaultid=0 and requesttype not in (1,3)) AS [Count]
    from calendar
    WHERE 
        date_id BETWEEN DATEADD(MINUTE, ('+ @minDateTime +'), 0) AND DATEADD(MINUTE, ('+ @maxDateTime +'), 0)
) src
PIVOT (
    SUM([Count]) for month_nm in (' + @cols + ')
) pvt
'

execute(@query)
