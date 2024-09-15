SELECT 
    sectio_ AS [Team], 
    ROUND((AVG(4 - (CONVERT(FLOAT, fbscore) - 1)) / 4) * 100, 2) AS [Average Feedback %]
FROM feedback
    JOIN faults ON faultid = fbfaultid 
WHERE fbdate BETWEEN @startdate AND @enddate
GROUP BY sectio_

