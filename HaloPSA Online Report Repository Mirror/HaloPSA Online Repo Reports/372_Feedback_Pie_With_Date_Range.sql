SELECT 'Awesome' AS Score
    ,(
        SELECT cast(count(fbid) AS FLOAT)
        FROM feedback
        WHERE fbdate > @startdate
            AND fbdate < @enddate
            AND fbscore = 1
        ) / (
        SELECT nullif((
                    cast((
                            SELECT count(fbid)
                            FROM feedback
                            WHERE fbdate > @startdate
                                AND fbdate < @enddate
                                AND fbscore > 0
                            ) AS FLOAT)
                    ), 0)
        ) * 100 AS [Percentage]
    ,(
        SELECT cast(count(fbid) AS FLOAT)
        FROM feedback
        WHERE fbdate > @startdate
            AND fbdate < @enddate
            AND fbscore = 1
        ) AS [Count]
FROM feedback
WHERE fbdate > @startdate
    AND fbdate < @enddate

UNION

SELECT 'Good' AS Score
    ,(
        SELECT cast(count(fbid) AS FLOAT)
        FROM feedback
        WHERE fbdate > @startdate
            AND fbdate < @enddate
            AND fbscore = 2
        ) / (
        SELECT nullif((
                    cast((
                            SELECT count(fbid)
                            FROM feedback
                            WHERE fbdate > @startdate
                                AND fbdate < @enddate
                                AND fbscore > 0
                            ) AS FLOAT)
                    ), 0)
        ) * 100 AS [Percentage]
    ,(
        SELECT cast(count(fbid) AS FLOAT)
        FROM feedback
        WHERE fbdate > @startdate
            AND fbdate < @enddate
            AND fbscore = 2
        ) AS [Count]
FROM feedback
WHERE fbdate > @startdate
    AND fbdate < @enddate

UNION

SELECT 'OK' AS Score
    ,(
        SELECT cast(count(fbid) AS FLOAT)
        FROM feedback
        WHERE fbdate > @startdate
            AND fbdate < @enddate
            AND fbscore = 3
        ) / (
        SELECT nullif((
                    cast((
                            SELECT count(fbid)
                            FROM feedback
                            WHERE fbdate > @startdate
                                AND fbdate < @enddate
                                AND fbscore > 0
                            ) AS FLOAT)
                    ), 0)
        ) * 100 AS [Percentage]
    ,(
        SELECT cast(count(fbid) AS FLOAT)
        FROM feedback
        WHERE fbdate > @startdate
            AND fbdate < @enddate
            AND fbscore = 3
        ) AS [Count]
FROM feedback
WHERE fbdate > @startdate
    AND fbdate < @enddate

UNION

SELECT 'Bad' AS Score
    ,(
        SELECT cast(count(fbid) AS FLOAT)
        FROM feedback
        WHERE fbdate > @startdate
            AND fbdate < @enddate
            AND fbscore = 4
        ) / (
        SELECT nullif((
                    cast((
                            SELECT count(fbid)
                            FROM feedback
                            WHERE fbdate > @startdate
                                AND fbdate < @enddate
                                AND fbscore > 0
                            ) AS FLOAT)
                    ), 0)
        ) * 100 AS [Percentage]
    ,(
        SELECT cast(count(fbid) AS FLOAT)
        FROM feedback
        WHERE fbdate > @startdate
            AND fbdate < @enddate
            AND fbscore = 4
        ) AS [Count]
FROM feedback
WHERE fbdate > @startdate
    AND fbdate < @enddate





























