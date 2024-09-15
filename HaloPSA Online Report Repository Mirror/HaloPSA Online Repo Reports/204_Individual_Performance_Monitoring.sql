 SELECT uname AS Technician
	,(
		SELECT count(faultid)
		FROM faults
		WHERE STATUS <> 9
			AND assignedtoint = O.unum
		) AS 'Total_Tickets_Currently_Open'
	,(
		SELECT COUNT(faultid)
		FROM Faults
		WHERE takenby = O.uname
			AND dateoccured > @startdate
			AND dateoccured < @enddate
		) AS 'Tickets_Opened_This_Period'
	,(
		SELECT COUNT(faultid)
		FROM faults
		WHERE datecleared > @startdate
			AND ISNULL(FMergedIntoFaultid,0)<1
			AND datecleared < @enddate
			AND clearwhoint = O.unum
			AND STATUS = 9
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
						) AS FLOAT) / replace(cast((
							(
								SELECT COUNT(faultid)
								FROM faults
								WHERE STATUS = 9
									AND clearwhoint = O.unum
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
			AND assignedtoint = O.unum
			AND clearance NOT LIKE '%Merged%'
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'SLA Response Missed'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate = 'I'
			AND assignedtoint = O.unum
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
		) AS 'SLA Response Met'
	,(
		SELECT count(faultid)
		FROM faults
		WHERE slaresponsestate IS NULL
			AND assignedtoint = O.unum
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FexcludefromSLA = 0
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
						) AS FLOAT) / replace(cast((
							(
								SELECT COUNT(faultid)
								FROM faults
								WHERE assignedtoint = O.unum
									AND dateoccured > @startdate
									AND dateoccured < @enddate
									AND FexcludefromSLA = 0
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
	,(
		SELECT sum(isnull(timetaken, 0) + isnull(actions.nonbilltime, 0))
		FROM actions
		WHERE who = O.uname
			AND whe_ > @startdate
			AND whe_ < @enddate
			AND (
				actioncode = (
					SELECT CRid
					FROM chargerate
					WHERE crchargeid = (
							SELECT fcode
							FROM lookup
							WHERE fid = 17
								AND fvalue LIKE 'Remote Contract'
							)
					)
				OR actioncode = (
					SELECT CRid
					FROM chargerate
					WHERE crchargeid = (
							SELECT fcode
							FROM lookup
							WHERE fid = 17
								AND fvalue LIKE 'Remote  PAYG'
							)
					)
				)
		) AS 'Offsite Hours'
	,(
		SELECT sum(isnull(timetaken, 0) + isnull(actions.nonbilltime, 0))
		FROM actions
		WHERE who = O.uname
			AND whe_ > @startdate
			AND whe_ < @enddate
			AND (
				actioncode = (
					SELECT CRid
					FROM chargerate
					WHERE crchargeid = (
							SELECT fcode
							FROM lookup
							WHERE fid = 17
								AND fvalue LIKE 'Onsite Contract'
							)
					)
				OR actioncode = (
					SELECT CRid
					FROM chargerate
					WHERE crchargeid = (
							SELECT fcode
							FROM lookup
							WHERE fid = 17
								AND fvalue LIKE 'Onsite  PAYG'
							)
					)
				)
		) AS 'Onsite Hours'
FROM uname O
WHERE unum <> 1
GROUP BY uname
	,unum
