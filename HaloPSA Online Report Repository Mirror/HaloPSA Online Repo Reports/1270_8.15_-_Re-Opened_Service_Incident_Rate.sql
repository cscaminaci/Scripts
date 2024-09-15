SELECT    CONVERT(NVARCHAR(7), dateoccured, 126) AS [Date], 
          Count(efaultid)                        AS [Email], 
          Count(wfaultid)                        AS [Web], 
          Count(afaultid)                        AS [Auto], 
          Count(mfaultid)                        AS [Manual], 
          Count(nfaultid)                         AS [Total Re-Opened Incidents] ,
		  round((cast(count(nfaultid) as float)/cast(count(faultid) as float))*100,2) as [%]
FROM      faults 
LEFT JOIN 
          ( 
                 SELECT faultid AS [efaultid] 
                 FROM   faults 
                 WHERE  frequestsource=0 
                 AND    requesttype IN (1) 
                 AND 
                       (select top 1 actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber)
<
(select top 1 actionnumber from actions where actions.faultid=faults.faultid order by actionnumber desc))Email 
ON        efaultid=faultid 
LEFT JOIN 
          ( 
                 SELECT faultid AS [wfaultid] 
                 FROM   faults 
                 WHERE  frequestsource=1 
                 AND    requesttype IN (1) 
                 AND 
                        (select top 1 actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber)
<
(select top 1 actionnumber from actions where actions.faultid=faults.faultid order by actionnumber desc) )Web 
ON        wfaultid=faultid 
LEFT JOIN 
          ( 
                 SELECT faultid AS [afaultid] 
                 FROM   faults 
                 WHERE  frequestsource=2 
                 AND    requesttype IN (1) 
                 AND 
                      (select top 1 actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber)
<
(select top 1 actionnumber from actions where actions.faultid=faults.faultid order by actionnumber desc))Auto 
ON        afaultid=faultid 
LEFT JOIN 
          ( 
                 SELECT faultid AS [mfaultid] 
                 FROM   faults 
                 WHERE  frequestsource=3 
                 AND    requesttype IN (1) 
                 AND 
                        (select top 1 actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber)
<
(select top 1 actionnumber from actions where actions.faultid=faults.faultid order by actionnumber desc))Manual 
ON        mfaultid=faultid 
LEFT JOIN 
          ( 
                 SELECT faultid AS [nfaultid] 
                 FROM   faults 
                where
                 requesttype IN (1) 
                 AND 
                        (select top 1 actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber)
<
(select top 1 actionnumber from actions where actions.faultid=faults.faultid order by actionnumber desc))reopen 
ON        nfaultid=faultid 

WHERE 

  requesttype IN (1)
AND       dateoccured > @startdate 
AND       dateoccured < @enddate 
GROUP BY  CONVERT(nvarchar(7), dateoccured, 126)
