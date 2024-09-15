SELECT uname AS Technician
	,(
		SELECT count(faultid)
		FROM faults
		WHERE STATUS <> 9
			AND assignedtoint = O.unum
AND Fdeleted = fmergedintofaultid
		) AS 'Total_Tickets_Currently_Open'
	,(
		SELECT COUNT(faultid)
		FROM Faults
		WHERE takenby = O.uname
			AND dateoccured > @startdate
			AND dateoccured < @enddate
AND Fdeleted = fmergedintofaultid
		) AS 'Tickets_Opened_This_Period'
	,(
		SELECT COUNT(faultid)
		FROM faults
		WHERE STATUS = 9
			AND clearwhoint = O.unum
			AND datecleared > @startdate
			AND datecleared < @enddate
AND Fdeleted = fmergedintofaultid
		) AS 'Tickets_Closed_This_Period'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slastate = 'O'
			AND clearwhoint = O.unum
			AND datecleared > @startdate
			AND datecleared < @enddate
			AND STATUS = 9
			AND FexcludefromSLA = 0
AND Fdeleted = fmergedintofaultid
		) AS 'SLA_Fix_Missed'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slastate = 'I'
			AND clearwhoint = O.unum
			AND datecleared > @startdate
			AND datecleared < @enddate
			AND STATUS = 9
			AND FexcludefromSLA = 0
AND Fdeleted = fmergedintofaultid
		) AS 'SLA Fix Met'
	,cast((
			round(cast((
						SELECT count(faultid)
						FROM faults
						WHERE slastate = 'O'
							AND clearwhoint = O.unum
							AND datecleared > @startdate
							AND datecleared < @enddate
							AND STATUS = 9
							AND FexcludefromSLA = 0
AND Fdeleted = fmergedintofaultid
						) AS FLOAT) / replace(cast((
							(
								SELECT COUNT(faultid)
								FROM faults
								WHERE STATUS = 9
									AND clearwhoint = O.unum
									AND datecleared > @startdate
									AND datecleared < @enddate
									AND FexcludefromSLA = 0
AND Fdeleted = fmergedintofaultid
								)
							) AS FLOAT), 0, 1), 4) * 100
			) AS NVARCHAR(50)) + ' %' AS 'SLA Fix Missed %'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate = 'O'
			AND assignedtoint = O.unum
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
AND Fdeleted = fmergedintofaultid
		) AS 'SLA Response Missed'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate = 'I'
			AND assignedtoint = O.unum
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
AND Fdeleted = fmergedintofaultid
		) AS 'SLA Response Met'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate IS NULL
			AND assignedtoint = O.unum
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
AND Fdeleted = fmergedintofaultid
		) AS 'SLA Response Awaiting'
	,cast((
			round(cast((
						SELECT count(faultid)
						FROM faults
						WHERE slaresponsestate = 'O'
							AND dateoccured > @startdate
							AND dateoccured < @enddate
							AND assignedtoint = O.unum
							AND FexcludefromSLA = 0
							AND Fdeleted = fmergedintofaultid
						) AS FLOAT) / replace(cast((
							(
								SELECT COUNT(faultid)
								FROM faults
								WHERE assignedtoint = O.unum
									AND dateoccured > @startdate
									AND dateoccured < @enddate
									AND FexcludefromSLA = 0
									AND Fdeleted = fmergedintofaultid
								)
							) AS FLOAT), 0, 1), 4) * 100
			) AS NVARCHAR(50)) + ' %' AS 'SLA Response Missed %'
	,(
		SELECT sum(isnull(timetaken, 0) + isnull(actions.nonbilltime, 0))
		FROM actions
		WHERE who = O.uname
			AND whe_ > @startdate
			AND whe_ < @enddate
		) AS 'Total Time Taken'
FROM uname O
WHERE unum <> 1
and uisdisabled=0
GROUP BY uname
	,unum



