SELECT 'Incident' AS [RequestType]
	,(
		SELECT count(*)
		FROM faults
		WHERE fdeleted = 0
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 1
		) AS [OpenedInPeriod]
	,(
		SELECT count(*)
		FROM faults
		WHERE fdeleted = 0
			AND datecleared > @startdate
			AND datecleared < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 1
			AND STATUS = 9
		) AS [ClosedInPeriod]
	,(
		SELECT count(*)
		FROM faults
		WHERE fdeleted = 0
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 1
			AND FexcludefromSLA = 0
			AND SLAresponseState = 'I'
		) AS [SLAMet]
	,(
		SELECT count(*)
		FROM faults
		WHERE fdeleted = 0
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 1
			AND FexcludefromSLA = 0
			AND SLAresponseState IN (
				'O'
				,'X'
				)
		) AS [SLAMissed]
	,(
		SELECT isnull(nullif(round(AVG(elapsedhrs), 2), 0), 0)
		FROM faults
		WHERE fdeleted = 0
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 1
			AND FexcludefromSLA = 0
		) AS [AverageResolutionTime]
	,(
		SELECT isnull(round(sum([Percent]) / nullif(count([Percent]), 0), 0), 0) AS [Percent]
		FROM (
			SELECT CASE 
					WHEN fbscore = 1
						THEN 100
					WHEN fbscore = 2
						THEN 66
					WHEN fbscore = 3
						THEN 33
					WHEN fbscore = 4
						THEN 0
					ELSE 0
					END AS [Percent]
			FROM Feedback
			JOIN faults ON faultid = FBFaultID
			WHERE fbdate > @startdate
				AND fbdate < @enddate
				AND fdeleted = 0
				AND FMergedIntoFaultid = 0
				AND requesttype = 1
			) a
		) AS [SatisfactionScore]

UNION

SELECT 'Service Request' AS [RequestType]
	,(
		SELECT count(*)
		FROM faults
		WHERE fdeleted = 0
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 3
		) AS [OpenedInPeriod]
	,(
		SELECT count(*)
		FROM faults
		WHERE fdeleted = 0
			AND datecleared > @startdate
			AND datecleared < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 3
			AND STATUS = 9
		) AS [ClosedInPeriod]
	,(
		SELECT count(*)
		FROM faults
		WHERE fdeleted = 0
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 3
			AND FexcludefromSLA = 0
			AND SLAresponseState = 'I'
		) AS [SLAMet]
	,(
		SELECT count(*)
		FROM faults
		WHERE fdeleted = 0
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 3
			AND FexcludefromSLA = 0
			AND SLAresponseState IN (
				'O'
				,'X'
				)
		) AS [SLAMissed]
	,(
		SELECT isnull(nullif(round(AVG(elapsedhrs), 2), 0), 0)
		FROM faults
		WHERE fdeleted = 0
			AND dateoccured > @startdate
			AND dateoccured < @enddate
			AND FMergedIntoFaultid = 0
			AND requesttype = 3
			AND FexcludefromSLA = 0
		) AS [AverageResolutionTime]
	,(
		SELECT isnull(round(sum([Percent]) / nullif(count([Percent]), 0), 0), 0) AS [Percent]
		FROM (
			SELECT CASE 
					WHEN fbscore = 1
						THEN 100
					WHEN fbscore = 2
						THEN 66
					WHEN fbscore = 3
						THEN 33
					WHEN fbscore = 4
						THEN 0
					ELSE 0
					END AS [Percent]
			FROM Feedback
			JOIN faults ON faultid = FBFaultID
			WHERE fbdate > @startdate
				AND fbdate < @enddate
				AND fdeleted = 0
				AND FMergedIntoFaultid = 0
				AND requesttype = 3
			) a
		) AS [SatisfactionScore]

