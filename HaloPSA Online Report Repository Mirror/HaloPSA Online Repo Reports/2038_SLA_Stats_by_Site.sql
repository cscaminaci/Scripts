SELECT (
		SELECT sdesc
		FROM site
		WHERE sitenumber = ssitenum
		) AS 'Site'
	,seriousness AS [Priority]
	,(
		SELECT count(faultid)
		FROM faults
		WHERE STATUS <> 9
			AND sitenumber = O.sitenumber 
			AND seriousness = o.seriousness
			AND FexcludefromSLA = 0
		) AS 'Total Tickets Currently Open'
	,(
		SELECT COUNT(faultid)
		FROM Faults
		WHERE sitenumber = O.sitenumber 
			AND seriousness = o.seriousness
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'Tickets Opened This Period'
	,(
		SELECT COUNT(faultid)
		FROM faults
		WHERE STATUS = 9
			AND sitenumber = O.sitenumber 
			AND seriousness = o.seriousness
			AND datecleared > @startdate
			AND datecleared < @enddate
			AND FexcludefromSLA = 0
		) AS 'Tickets Closed This Period'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slastate = 'O'
			AND sitenumber = O.sitenumber 
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
			AND sitenumber = O.sitenumber 
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
							AND sitenumber = O.sitenumber 
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
									AND sitenumber = O.sitenumber 
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
			AND sitenumber = O.sitenumber 
			AND seriousness = o.seriousness
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'SLA Response Missed'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate = 'I'
			AND sitenumber = O.sitenumber 
			AND seriousness = o.seriousness
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'SLA Response Met'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate IS NULL
			AND sitenumber = O.sitenumber 
			AND seriousness = o.seriousness
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'SLA Response Awaiting'
FROM (
	SELECT sdesc AS [Site]
		,sitenumber AS [sitenumber]
		,seriousness AS [Seriousness]
	FROM site
	JOIN faults ON sitenumber = ssitenum
	GROUP BY sdesc
		,ssitenum
		,sitenumber
		,seriousness
	) o


