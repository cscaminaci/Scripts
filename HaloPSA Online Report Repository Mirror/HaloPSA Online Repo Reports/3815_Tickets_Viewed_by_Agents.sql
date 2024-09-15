SELECT
	  fvlfaultid as 'Ticket ID'
	, (select aareadesc from area where aarea=areaint) as [Client]
	, (select sdesc from site where ssitenum=sitenumber) as [Site]
	, username as [Username]
	, symptom as [Summary]
	, dateoccured as [Date Occurred]
	, datecleared as [Date Closed]
	, (select tstatusdesc from tstatus where tstatus=status) as [Status]
	, sectio_ as [Team]
	, (select rtdesc from requesttype where rtid=requesttypenew) as [Ticket type]
	, category2 as [Category]
	, (SELECT uname FROM uname WHERE FVLunum = unum) as 'Agent'
	, count(fvlid) as 'Viewed'
FROM faultsviewlog
JOIN faults on faultid = FVLfaultid
WHERE FVLtimestamp BETWEEN @startdate AND @enddate
  and fdeleted = FMergedIntoFaultid
GROUP BY FVLfaultid, areaint, sitenumber, username, symptom, dateoccured, datecleared, status, sectio_, requesttypenew, category2, seriousness, FVLunum

