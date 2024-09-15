SELECT
	  [Ticket ID]
	, [Client]
	, [Employee]
	, [Date Occured]
	, [Date Cleared]
	, [Ticket Type]
	, sum([Action Time with Adjustment]) as [Total Time]
	, [Labour Rate]
	, [Charge Rate ($)]
	, sum([Total Charge]) as [Total Charged]
FROM (
SELECT *, TRY_CAST([Charge Rate ($)]  as float )* [Action Time with Adjustment] as 'Total Charge' FROM
(SELECT actions.faultid                               AS 'Ticket ID',
       aareadesc                                     AS 'Client',
       uusername                                     AS 'Employee',
	   dateoccured as 'Date Occured',
	   datecleared as 'Date Cleared',
       (SELECT chcontractref
        FROM   contractheader
        WHERE  chid = fcontractid)                   AS 'Contract Reference',
       rtdesc                                        AS 'Ticket Type',
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
       END                                           AS 'Charge Rate ($)'
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
  )a)b
GROUP BY [Ticket ID], [Client], [Employee], [Date Occured], [Date Cleared], [Ticket Type], [Labour Rate], [Charge Rate ($)]
