SELECT top 10000 
     date_id AS [Date],
     IIF( AVG(CONVERT(money, DATEDIFF(hh, dateoccured, whe_)) + (CONVERT(money, DATEDIFF(minute, dateoccured, whe_))/60)%1 - DATEDIFF(dd, dateoccured, whe_)*16 - DATEDIFF(ww, dateoccured, whe_)*16) <0, 0, AVG(CONVERT(money, DATEDIFF(hh, dateoccured, whe_)) + (CONVERT(money, DATEDIFF(minute, dateoccured, whe_))/60)%1 - DATEDIFF(dd, dateoccured, whe_)*16 - DATEDIFF(ww, dateoccured, whe_)*16)) AS [Time Taken (hours)]
FROM faults
JOIN (SELECT faultid as fid, MIN(actionnumber) AS actnum, MIN(whe_) AS whe_ FROM actions WHERE actoutcome = 'Re-assign' GROUP BY faultid) act ON fid = faultid
JOIN calendar ON CONVERT(date, dateoccured) >= date_id AND DATEADD(day, -7, CONVERT(date, dateoccured)) < date_id 

WHERE weekday_id = 2 AND dateoccured BETWEEN @startdate AND @enddate

GROUP BY date_id, weekday_nm

ORDER BY date_id
