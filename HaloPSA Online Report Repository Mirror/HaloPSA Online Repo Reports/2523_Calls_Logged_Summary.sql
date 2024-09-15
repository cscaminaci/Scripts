SELECT 
	  faults.faultid as 'Ticket ID'
	, uusername as 'End-User'
	, takenby as 'Agent'
	, Symptom as 'Summary'
	, symptom2 as 'Details'
	, tstatusdesc as 'Status'
	, dateoccured as 'Date Logged'
	, timetaken as 'Time On Call'
FROM faults
JOIN users on uid = userid
JOIN TSTATUS on status = Tstatus
JOIN ACTIONS on faults.faultid = actions.faultid
WHERE FRequestSource = 12
  AND FDeleted = FMergedIntoFaultid
  AND dateoccured BETWEEN @startdate AND @enddate
