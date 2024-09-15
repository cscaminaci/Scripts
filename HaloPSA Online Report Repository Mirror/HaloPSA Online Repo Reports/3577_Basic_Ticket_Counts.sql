SELECT DISTINCT
    sdsectionname AS [Team],
    ISNULL(oCount, 0) AS [Opened],
    ISNULL(cCount, 0) AS [Closed],
    ISNULL(rCount, 0) AS [Responded To],
    ISNULL(rSLAmet, 0) AS [Response Targets Met],
    ISNULL(rSLAmissed, 0) AS [Response Targets Missed],
    ISNULL(cSLAmet, 0) AS [Resolution Targets Met],
    ISNULL(cSLAmissed, 0) AS [Resolution Targets Missed],
    ROUND(rAvg, 2) AS [Average Response Time (Hours)],
    ROUND(cAvg, 2) AS [Average Resolution Time (Hours)],
    ROUND(CONVERT(FLOAT, rSLAmet) / NULLIF(rCount, 0) * 100, 2) AS [Response Met %],
    ROUND(CONVERT(FLOAT, cSLAmet) / NULLIF(cCount, 0) * 100, 2) AS [Resolution Met %]
FROM sectiondetail
LEFT JOIN (
    SELECT
        sectio_,
        SUM(IIF(dateoccured BETWEEN @startdate AND @enddate, 1, 0)) AS [oCount],
        SUM(IIF(datecleared BETWEEN @startdate AND @enddate, 1, 0)) AS [cCount],
        SUM(IIF(datecleared BETWEEN @startdate AND @enddate AND slastate LIKE 'i', 1, 0)) AS [cSLAmet],
        SUM(IIF(datecleared BETWEEN @startdate AND @enddate AND slastate LIKE 'o', 1, 0)) AS [cSLAmissed],
        AVG(IIF(datecleared BETWEEN @startdate AND @enddate, elapsedhrs, NULL)) AS [cAvg],
        SUM(IIF(fresponsedate BETWEEN @startdate AND @enddate, 1, 0)) AS [rCount],
        SUM(IIF(fresponsedate BETWEEN @startdate AND @enddate AND slaresponsestate LIKE 'i', 1, 0)) AS [rSLAmet],
        SUM(IIF(fresponsedate BETWEEN @startdate AND @enddate AND slaresponsestate LIKE 'o', 1, 0)) AS [rSLAmissed],
        AVG(IIF(fresponsedate BETWEEN @startdate AND @enddate, fresponsetime, NULL)) AS [rAvg]
    FROM faults
    WHERE fdeleted = 0 
        AND fmergedintofaultid = 0
    GROUP BY sectio_
) AS [countsBasic] ON sectio_ LIKE sdsectionname

