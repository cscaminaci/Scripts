select [Week Commencing]
    , (
		SELECT count(faultid)
		FROM faults
		WHERE  requesttype = 2
AND fchangestatus = 2
      and datecleared >= [Week Commencing]
		AND datecleared < (dateadd(dd, 7, [Week Commencing]))
		AND fdeleted = 0
		AND fmergedintofaultid = 0

	  ) AS [Change Requests Accepted]
FROM (
SELECT
      CONVERT(DATE, Dateadd(week, Datediff(week, 0, dateoccured), 0)) AS [Week Commencing]
    , faultid 

FROM   faults
                 
WHERE
      datecleared > @startdate
  and datecleared < @enddate
  and fdeleted = 0
  and fmergedintofaultid = 0
) Z
GROUP BY
      [Week Commencing]
