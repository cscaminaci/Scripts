SELECT (
		(
			SELECT count(faultid)
			FROM faults
			WHERE
			 dateoccured <= @startdate
				AND datecleared >= @startdate
			)
		) AS [Open Tickets, Start]
	,(
		SELECT count(faultid)
		FROM faults
		WHERE dateoccured > @startdate
			AND dateoccured <= @enddate
		) AS [Tickets Opened]
	,(
		SELECT count(faultid)
		FROM faults
		WHERE dateoccured >= @startdate
			AND dateoccured <= @enddate
			AND FRequestSource = 2
		) AS [Tickets Opened, Auto]
	,(
		SELECT count(faultid)
		FROM faults
		WHERE datecleared >= @startdate
			AND datecleared <= @enddate
			and FRequestSource <> 2
		) AS [Tickets Closed - Manual]
	,(
		SELECT count(faultid)
		FROM faults
		WHERE datecleared >= @startdate
			AND datecleared <= @enddate
			AND FRequestSource = 2
		) AS [Tickets Closed, Auto]
	,(
		SELECT count(faultid)
		FROM faults
		WHERE 
			dateoccured > @startdate and dateoccured <= @enddate and (datecleared> @enddate or datecleared is null or datecleared < 5)
		) AS [Open Tickets, End]


