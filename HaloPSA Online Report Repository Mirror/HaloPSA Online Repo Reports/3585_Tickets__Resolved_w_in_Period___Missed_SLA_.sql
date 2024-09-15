SELECT
    faultid AS [Ticket ID],
    rtdesc AS [Ticket Type],
    tstatusdesc AS [Status],
    symptom AS [Summary],
    pdesc AS [Priority Description],
    CASE WHEN category2 LIKE '' THEN N'not set' ELSE category2 END AS [Category],
    CASE WHEN category3 LIKE '' THEN N'not set' ELSE category3 END AS [Resolution Category],
    FRespondByDate AS [Target Response Date],
    fixbydate AS [Target Resolution Date],
    dateoccured AS [Date Opened],
    fresponsedate AS [Date Responded],
    datecleared AS [Date Resolved],
    CONVERT(VARCHAR, FLOOR(CONVERT(DECIMAL(7, 2), fresponsetime))) + ':' + CONVERT(VARCHAR, FLOOR(CONVERT(FLOAT, RIGHT(CONVERT(DECIMAL(7, 2), fresponsetime), 3)) * 60)) AS [Response Time (hh:mm)],
    CONVERT(VARCHAR, FLOOR(CONVERT(DECIMAL(7, 2), elapsedhrs))) + ':' + CONVERT(VARCHAR, FLOOR(CONVERT(FLOAT, RIGHT(CONVERT(DECIMAL(7, 2), elapsedhrs), 3)) * 60)) AS [Resolution Time (hh:mm)], 
    ROUND(fresponsetime, 2) AS [Response Time (hours)],
    ROUND(elapsedhrs, 2) AS [Resolution Time (hours)],
    CASE WHEN slastate='i' THEN N'in' WHEN slastate='o' THEN N'out' END AS [Resolution State],
    CASE WHEN slaresponsestate='i' THEN N'in' WHEN slaresponsestate='o' THEN N'out' END AS [Response State],
    aareadesc AS [Client],
    sdesc AS [Site],
    username AS [User],
    sectio_ AS [Team],
    Uname AS [Agent],
    seriousness AS [Priority Number],
    symptom2 AS [Details]
FROM faults
JOIN requesttype ON requesttypenew = rtid
JOIN uname ON unum = assignedtoint
JOIN area ON aarea = areaint
JOIN site ON ssitenum = sitenumber
JOIN tstatus ON status = tstatus
LEFT JOIN policy ON ppolicy = seriousness AND slaid = pslaid
WHERE fdeleted = 0 AND fmergedintofaultid = 0 AND requesttype IN (1, 3)

