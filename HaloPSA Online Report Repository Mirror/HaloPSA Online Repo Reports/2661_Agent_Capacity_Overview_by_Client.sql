SELECT
	  [Agent]
	, [Client]
	, sum([Scheduled Hours]) as 'Total Scheduled Hours'
FROM(
	SELECT
		  uname as [Agent]
		, faultid as 'Ticket'
		, symptom as 'Summary'
		, aareadesc as 'Client'
		, username as 'User'
		, tstatusdesc as 'Status'
		, CASE 
			  WHEN @enddate < FOppTargetDate AND @startdate > FProjectStartDate THEN DATEDIFF(hour, @startdate, @enddate)
			  WHEN @enddate < FOppTargetDate THEN DATEDIFF(hour, FProjectStartDate, @enddate)
			  WHEN @startdate > FProjectStartDate THEN DATEDIFF(hour, @startdate, FOppTargetDate)
			  ELSE DATEDIFF(hour, FProjectStartDate, FOppTargetDate) 
		  END AS 'Scheduled Hours'
	FROM faults
	JOIN uname on unum = Assignedtoint
	JOIN area on aarea = areaint
	JOIN tstatus on tstatus = status
	WHERE FProjectStartDate BETWEEN @startdate AND @enddate
	  AND FOppTargetDate > @startdate
	  AND FProjectStartDate > '01/01/2000 12:00'
	  AND requesttypenew IN (SELECT rtid FROM requesttype WHERE RTIsProject =1)
	  AND fdeleted = FMergedIntoFaultid)a
GROUP BY [Agent], [Client]

