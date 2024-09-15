SELECT 
	  faultid as [Ticket ID]
	, (SELECT count(FVLid) FROM FaultsViewLog WHERE faultid = FVLfaultid) as 'Views'
	, (select aareadesc from area where aarea=areaint) as [Client]
	, (select sdesc from site where ssitenum=sitenumber) as [Site]
	, username as [Username]
	, symptom as [Summary]
	, dateoccured as [Date Occurred]
	, datecleared as [Date Closed]
	, (select tstatusdesc from tstatus where tstatus=status) as [Status]
	, (select uname from uname where unum=assignedtoint) as [Technician] 
	, sectio_ as [Section]
	, (select rtdesc from requesttype where rtid=requesttypenew) as [Request type]
	, category2 as [Category]
	, (select pdesc from policy where ppolicy=seriousness and pslaid=slaid) as [Priority]
	, (select sldesc from slahead where slid=slaid) as [SLA]
	, slastate as [Resolution State]
	, slaresponsestate as [Response State]
FROM faults 
WHERE fdeleted=0
  AND FMergedIntoFaultid = 0 
  AND slaresponsestate is null
  AND dateoccured BETWEEN @startdate AND @enddate
