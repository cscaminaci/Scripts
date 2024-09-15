SELECT uname AS [Technician]
,[Year]
,[Month]
,(
SELECT round(sum(timetaken), 2)
FROM actions
WHERE actioncode = 1
AND uname = who
AND [Year] = convert(NVARCHAR(4), whe_, 111)
AND convert(NVARCHAR(2), Whe_, 101) = [Month ID]
) AS [On-Site Support]
FROM

uname
,(
SELECT DISTINCT month_nm AS [Month]
,date_month AS [Month ID]
,date_year as [Year]
FROM Calendar where date_year >= convert(NVARCHAR(4), getdate()-365, 111) and date_year <= convert(NVARCHAR(4), getdate(), 111)
) d
