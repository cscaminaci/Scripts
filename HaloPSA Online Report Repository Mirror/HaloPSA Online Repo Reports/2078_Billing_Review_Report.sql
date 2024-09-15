SELECT *, TRY_CAST([Charge Rate (£)]  as float )* [Action Time with Adjustment] as 'Total Charge' 
, CAST(FLOOR(COALESCE(cast([Action Time] * 60 AS INT), 0) / 60) AS NVARCHAR(9)) + 
':' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Action Time] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) as [Action Time (HH:MM)]
, CAST(FLOOR(COALESCE(cast([Action Time with Adjustment] * 60 AS INT), 0) / 60) AS NVARCHAR(9)) + 
':' + RIGHT('0' + CAST(FLOOR(COALESCE(cast([Action Time with Adjustment] * 60 AS INT), 0) % 60) AS NVARCHAR(2)), 2) as [Action Time w/ Adjustment (HH:MM)]
FROM
(SELECT actions.faultid                               AS 'Ticket ID',
       whe_                                          AS 'Date of Action',
       aareadesc                                     AS 'Client',
       uusername                                     AS 'Employee',
	   dateoccured as 'Date Occured',
	   datecleared as 'Date Cleared',
	   actioninvoicenumber as 'Invoice ID',
	   (SELECT TOP 1 dinvno FROM device WHERE devicenumber = ddevnum) as 'Asset',
       (SELECT chcontractref
        FROM   contractheader
        WHERE  chid = fcontractid)                   AS 'Contract Reference',
       rtdesc                                        AS 'Ticket Type',
       note                                          AS 'Action Note',
       Round(timetaken, 3)                           AS 'Action Time',
       Round((( timetaken + timetakenadjusted )), 2) AS
       'Action Time with Adjustment',
       (SELECT fvalue
        FROM   lookup
        WHERE  fid = 17
               AND fcode = ( actioncode + 1 ))       'Labour Rate',
       CASE
         WHEN actioncode + 1 IN (SELECT TOP 1 crchargeid
                                 FROM   chargerate)
              AND (SELECT areaint
                   FROM   faults
                   WHERE  faults.faultid = actions.faultid) = (SELECT TOP 1 crarea
                                                               FROM   chargerate
                                                               WHERE  crarea =
                                                              (SELECT areaint
                                                               FROM   faults
                                                               WHERE
                  faults.faultid = actions.faultid)
                  AND crchargeid =
                      actioncode + 1) THEN N'Overriding Rate'
         ELSE N'Global'
       END                                           AS 'Override/Global Rate',
       CASE
         WHEN actionbillingplanid < -9 THEN cpdesc
		 WHEN ActionBillingPlanID = -1 then 'PP'
		 WHEN actioncode + 1 IN (SELECT TOP 1 crchargeid
                                 FROM   chargerate)
              AND (SELECT areaint
                   FROM   faults
                   WHERE  faults.faultid = actions.faultid) = (SELECT TOP 1 crarea
                                                               FROM   chargerate
                                                               WHERE  crarea =
                                                              (SELECT areaint
                                                               FROM   faults
                                                               WHERE
                  faults.faultid = actions.faultid)
                  AND crchargeid =
                      actioncode + 1) THEN cast((SELECT TOP 1 crrate
                                            FROM   chargerate
                                            WHERE
         ( crchargeid - 1 ) = actioncode
         AND crarea = (SELECT areaint
                       FROM   faults
                       WHERE
       actions.faultid = faults.faultid)) as nvarchar(255))
         ELSE cast((SELECT TOP 1 crrate
               FROM   chargerate
               WHERE  ( crchargeid - 1 ) = actioncode
                      AND crarea = 0) as nvarchar(255))
       END                                           AS 'Charge Rate (£)'
    , CASE WHEN freviewed = 1 THEN N'Yes'
           WHEN actreviewed = 1 THEN 'Yes'
           WHEN actreviewed = 0 THEN 'No' 
      END as 'Reviewed'
FROM   faults
       JOIN actions
         ON faults.faultid = actions.faultid
       JOIN area
         ON aarea = areaint
       JOIN users
         ON userid = uid
       JOIN requesttype
         ON rtid = requesttypenew
	   LEFT JOIN CONTRACTPLAN on cpid = ActionBillingPlanID
WHERE  fdeleted = fmergedintofaultid
  AND (timetaken> 0 or timetakenadjusted > 0)
  )a
