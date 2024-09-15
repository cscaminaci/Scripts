SELECT Customer
	,Site
	,NoNewTickets AS 'No. New Tickets in Period'
	,NoClosedTickets AS 'No. Closed Tickets in 
Period'
	,MHD AS 'Man hours recorded in period'
	,atd AS 'Average Ticket Time'
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
