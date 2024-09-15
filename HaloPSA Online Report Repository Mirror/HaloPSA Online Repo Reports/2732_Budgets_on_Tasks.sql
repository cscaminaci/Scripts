SELECT 
	  faultid as [Ticket ID]
	, (select aareadesc from area where aarea=areaint) as [Client]
	, (select sdesc from site where ssitenum=sitenumber) as [Site]
	, username as [Username]
	, symptom as [Summary]
	, dateoccured as [Date Created]
	, datecleared as [Date Closed]
	, (select tstatusdesc from tstatus where tstatus=status) as [Status]
	, (select uname from uname where unum=assignedtoint) as [Technician] 
	, sectio_ as [Section]
	, (select rtdesc from requesttype where rtid=requesttypenew) as [Request type]
	, btname as 'Budget Name'
	,  FBThours as 'Allocated Time'
	,  CONVERT(CHAR(5), DATEADD(MINUTE, 60*FBTactualtime, 0), 108) as 'Actual Time'
FROM faults 
JOIN FaultBudget on FBTfaultid = Faultid
LEFT JOIN BudgetType on FBTbtid = btid
WHERE fdeleted=0
  AND FMergedIntoFaultid = 0
  and requesttypenew IN (SELECT rtid FROM REQUESTTYPE where RTIsProject = 1)

