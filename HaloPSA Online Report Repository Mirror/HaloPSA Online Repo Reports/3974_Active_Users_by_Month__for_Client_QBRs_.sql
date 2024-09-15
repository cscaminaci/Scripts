SELECT TOP 1

(SELECT COUNT(UID) FROM Users left join site on usite=ssitenum
left join area on sarea=aarea WHERE UInactive = 'False' AND USite <> 0 and Aisinactive = 'FALSE' and Sisinactive = 'FALSE' and uusername not like 'General User'
AND AArea = $CLIENTID)            AS [Count Now],

(SELECT COUNT(UID) FROM Users left join site on usite=ssitenum
left join area on sarea=aarea WHERE UInactive = 'False' AND USite <> 0 and Aisinactive = 'FALSE' and Sisinactive = 'FALSE' and uusername not like 'General User'
AND AArea = $CLIENTID) -                   /*Count now...*/

(SELECT SUM(y.[New Users]) FROM 
(SELECT
COUNT(UCID) AS [New Users],
DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
FROM UserChange
WHERE UCFieldID = -1 AND (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
GROUP BY DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))y
WHERE y.[Month] = DATEADD(Month,0,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
    OR y.[Month] = DATEADD(Month,-1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) -    /*Removes users created this month and the last*/

(SELECT SUM(z.[Count Change]) FROM 
    (SELECT
    UCUID,
    SUM(
        CASE
        WHEN UCFieldID = 2 AND UCNewValue = 'True'
            THEN -1
        WHEN UCFieldID = 2 AND UCNewValue = 'False'
            THEN 1
        ELSE 0 END) AS [Count Change],
    DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
    FROM UserChange
    WHERE (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
    GROUP BY UCUID, DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))z
    WHERE z.[Month] = DATEADD(Month,0,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) -  /*Removes aggregated active/inactive changes this month*/

(SELECT SUM(z.[Count Change]) FROM 
    (SELECT
    UCUID,
    SUM(
        CASE
        WHEN UCFieldID = 2 AND UCNewValue = 'True'
            THEN -1
        WHEN UCFieldID = 2 AND UCNewValue = 'False'
            THEN 1
        ELSE 0 END) AS [Count Change],
    DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
    FROM UserChange
    WHERE (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
    GROUP BY UCUID, DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))z                         /*Removes aggregated active/inactive changes last month*/
    WHERE z.[Month] = DATEADD(Month,-1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)))                  AS [Count 1 Month Ago],  


(SELECT COUNT(UID) FROM Users left join site on usite=ssitenum
left join area on sarea=aarea WHERE UInactive = 'False' AND USite <> 0 and Aisinactive = 'FALSE' and Sisinactive = 'FALSE' and uusername not like 'General User'
AND AArea = $CLIENTID) -           /*Remainder just accounts for additional months*/

(SELECT SUM(y.[New Users]) FROM 
(SELECT
COUNT(UCID) AS [New Users],
DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
FROM UserChange
WHERE UCFieldID = -1 AND (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
GROUP BY DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))y
WHERE y.[Month] = DATEADD(Month,0,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
    OR y.[Month] = DATEADD(Month,-1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
    OR y.[Month] = DATEADD(Month,-2,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) -

(SELECT SUM(z.[Count Change]) FROM 
    (SELECT
    UCUID,
    SUM(
        CASE
        WHEN UCFieldID = 2 AND UCNewValue = 'True'
            THEN -1
        WHEN UCFieldID = 2 AND UCNewValue = 'False'
            THEN 1
        ELSE 0 END) AS [Count Change],
    DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
    FROM UserChange
    WHERE (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
    GROUP BY UCUID, DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))z
    WHERE z.[Month] = DATEADD(Month,0,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) - 
(SELECT SUM(z.[Count Change]) FROM 
    (SELECT
    UCUID,
    SUM(
        CASE
        WHEN UCFieldID = 2 AND UCNewValue = 'True'
            THEN -1
        WHEN UCFieldID = 2 AND UCNewValue = 'False'
            THEN 1
        ELSE 0 END) AS [Count Change],
    DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
    FROM UserChange
    WHERE (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
    GROUP BY UCUID, DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))z
    WHERE z.[Month] = DATEADD(Month,-1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) - 
(SELECT SUM(z.[Count Change]) FROM 
    (SELECT
    UCUID,
    SUM(
        CASE
        WHEN UCFieldID = 2 AND UCNewValue = 'True'
            THEN -1
        WHEN UCFieldID = 2 AND UCNewValue = 'False'
            THEN 1
        ELSE 0 END) AS [Count Change],
    DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
    FROM UserChange
    WHERE (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
    GROUP BY UCUID, DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))z
    WHERE z.[Month] = DATEADD(Month,-2,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)))               AS [Count 2 Months Ago],

(SELECT COUNT(UID) FROM Users left join site on usite=ssitenum
left join area on sarea=aarea WHERE UInactive = 'False' AND USite <> 0 and Aisinactive = 'FALSE' and Sisinactive = 'FALSE' and uusername not like 'General User'
AND AArea = $CLIENTID) -  

(SELECT SUM(y.[New Users]) FROM 
(SELECT
COUNT(UCID) AS [New Users],
DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
FROM UserChange
WHERE UCFieldID = -1 AND (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
GROUP BY DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))y
WHERE y.[Month] = DATEADD(Month,0,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
    OR y.[Month] = DATEADD(Month,-1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
    OR y.[Month] = DATEADD(Month,-2,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
    OR y.[Month] = DATEADD(Month,-3,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) -

(SELECT SUM(z.[Count Change]) FROM 
    (SELECT
    UCUID,
    SUM(
        CASE
        WHEN UCFieldID = 2 AND UCNewValue = 'True'
            THEN -1
        WHEN UCFieldID = 2 AND UCNewValue = 'False'
            THEN 1
        ELSE 0 END) AS [Count Change],
    DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
    FROM UserChange
    WHERE (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
    GROUP BY UCUID, DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))z
    WHERE z.[Month] = DATEADD(Month,0,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) - 
(SELECT SUM(z.[Count Change]) FROM 
    (SELECT
    UCUID,
    SUM(
        CASE
        WHEN UCFieldID = 2 AND UCNewValue = 'True'
            THEN -1
        WHEN UCFieldID = 2 AND UCNewValue = 'False'
            THEN 1
        ELSE 0 END) AS [Count Change],
    DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
    FROM UserChange
    WHERE (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
    GROUP BY UCUID, DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))z
    WHERE z.[Month] = DATEADD(Month,-1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) - 
(SELECT SUM(z.[Count Change]) FROM 
    (SELECT
    UCUID,
    SUM(
        CASE
        WHEN UCFieldID = 2 AND UCNewValue = 'True'
            THEN -1
        WHEN UCFieldID = 2 AND UCNewValue = 'False'
            THEN 1
        ELSE 0 END) AS [Count Change],
    DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
    FROM UserChange
    WHERE (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
    GROUP BY UCUID, DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))z
    WHERE z.[Month] = DATEADD(Month,-2,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))) -
(SELECT SUM(z.[Count Change]) FROM 
    (SELECT
    UCUID,
    SUM(
        CASE
        WHEN UCFieldID = 2 AND UCNewValue = 'True'
            THEN -1
        WHEN UCFieldID = 2 AND UCNewValue = 'False'
            THEN 1
        ELSE 0 END) AS [Count Change],
    DATEADD(month, DATEDIFF(month, 0, UCWhen), 0) AS [Month]
    FROM UserChange
    WHERE (SELECT SArea FROM Site WHERE SSiteNum = (SELECT USite FROM Users WHERE UID = UCUID)) = $CLIENTID
    GROUP BY UCUID, DATEADD(month, DATEDIFF(month, 0, UCWhen), 0))z
    WHERE z.[Month] = DATEADD(Month,-3,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)))               AS [Count 3 Months Ago]

FROM Users
