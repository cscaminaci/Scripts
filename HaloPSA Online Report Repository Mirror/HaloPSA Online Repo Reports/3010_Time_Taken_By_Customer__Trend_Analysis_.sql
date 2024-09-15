SELECT Customer
	,Site
	,NoNewTickets AS 'No. New Tickets in Period'
	,NoClosedTickets AS 'No. Closed Tickets in
Period'
	,CASE 
		WHEN MHD < 24
			THEN (
					SELECT left((
								SELECT DATEADD(mi, (MHD - FLOOR(MHD)) * 60, DATEADD(hh, FLOOR(MHD), CAST('00:00:00' AS TIME)))
								), 5)
					)
		ELSE '>24hrs'
		END AS 'Man hours recorded in period'
	,CASE 
		WHEN ATD < 24
			THEN (
					SELECT left((
								SELECT DATEADD(mi, (ATD - FLOOR(ATD)) * 60, DATEADD(hh, FLOOR(ATD), CAST('00:00:00' AS TIME)))
								), 5)
					)
		ELSE '>24hrs'
		END AS 'Average Ticket Time'
FROM (
	SELECT aareadesc AS 'Customer'
		,sdesc AS 'Site'
		,(
			SELECT count(faultid)
			FROM faults
			WHERE aarea = areaint
				AND ssitenum = sitenumber
				AND dateoccured >= @startdate
				AND dateoccured < @enddate and fdeleted=0
			) AS 'NoNewTickets'
		,(
			SELECT count(faultid)
			FROM faults
			WHERE aarea = areaint
				AND ssitenum = sitenumber
				AND datecleared <> ''
				AND datecleared >= @startdate
				AND datecleared < @enddate and fdeleted=0
			) AS 'NoClosedTickets'
		,(
			SELECT isnull(sum(timetaken), 0)
			FROM actions
			JOIN faults ON faults.faultid = actions.faultid
			WHERE aarea = areaint
				AND ssitenum = sitenumber
				AND dateoccured >= @startdate
				AND dateoccured < @enddate and fdeleted=0
			) AS 'MHD'
		,(
			SELECT isnull((sum(timetaken) / count(DISTINCT (faults.faultid))), 0)
			FROM actions
			JOIN faults ON faults.faultid = actions.faultid
			WHERE aarea = areaint
				AND ssitenum = sitenumber
				AND dateoccured >= @startdate
				AND dateoccured < @enddate and fdeleted=0
			) AS 'ATD'
	FROM area
	JOIN site ON sarea = aarea
	) a


