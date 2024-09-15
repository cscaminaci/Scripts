SELECT (
		SELECT aareadesc
		FROM area
		WHERE areaint = aarea
		) AS 'Client'
	,seriousness AS [Priority]
	,(
		SELECT count(faultid)
		FROM faults
		WHERE STATUS <> 9
			AND areaint = O.areaint
			AND seriousness = o.seriousness
			AND FexcludefromSLA = 0
		) AS 'Total Tickets Currently Open'
	,(
		SELECT COUNT(faultid)
		FROM Faults
		WHERE areaint = O.areaint
			AND seriousness = o.seriousness
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'Tickets Opened This Period'
	,(
		SELECT COUNT(faultid)
		FROM faults
		WHERE STATUS = 9
			AND areaint = O.areaint
			AND seriousness = o.seriousness
			AND datecleared > @startdate
			AND datecleared < @enddate
			AND FexcludefromSLA = 0
		) AS 'Tickets Closed This Period'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slastate = 'O'
			AND areaint = O.areaint
			AND seriousness = o.seriousness
			AND datecleared > @startdate
			AND datecleared < @enddate
			AND STATUS = 9
			AND FexcludefromSLA = 0
		) AS 'SLA Fix Missed'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slastate = 'I'
			AND areaint = O.areaint
			AND seriousness = o.seriousness
			AND datecleared > @startdate
			AND datecleared < @enddate
			AND STATUS = 9
			AND FexcludefromSLA = 0
		) AS 'SLA Fix Met'
	,cast((
			round(cast((
						SELECT count(faultid)
						FROM faults
						WHERE slastate = 'O'
							AND areaint = O.areaint
							AND seriousness = o.seriousness
							AND datecleared > @startdate
							AND datecleared < @enddate
							AND STATUS = 9
							AND FexcludefromSLA = 0
						) AS FLOAT) / replace(cast((
							(
								SELECT COUNT(faultid)
								FROM faults
								WHERE STATUS = 9
									AND areaint = O.areaint
									AND seriousness = o.seriousness
									AND datecleared > @startdate
									AND datecleared < @enddate
									AND FexcludefromSLA = 0
								)
							) AS FLOAT), 0, 1), 4) * 100
			) AS NVARCHAR(50)) + ' %' AS 'SLA Fix Missed %'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate = 'O'
			AND areaint = O.areaint
			AND seriousness = o.seriousness
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'SLA Response Missed'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate = 'I'
			AND areaint = O.areaint
			AND seriousness = o.seriousness
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'SLA Response Met'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate IS NULL
			AND areaint = O.areaint
			AND seriousness = o.seriousness
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'SLA Response Awaiting'
FROM (
	SELECT aareadesc AS [Client]
		,areaint AS [areaint]
		,seriousness AS [Seriousness]
	FROM area
	JOIN faults ON areaint = aarea
	GROUP BY aareadesc
		,aarea
		,areaint
		,seriousness
	) o


