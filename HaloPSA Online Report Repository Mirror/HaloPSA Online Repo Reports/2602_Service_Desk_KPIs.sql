SELECT
	  *
	, isnull(cast([Within SLA Tickets] as int) * 100/ [Resolved Tickets],0) as '% Within SLA'
	, isnull(cast([Breached Tickets] as int) * 100/ [Resolved Tickets],0) as '% Breached Tickets'
FROM (

	SELECT
		  uname as 'Full Name'
		, (datediff(hour, Wstart, Wend) - uhrsreducer)*datediff(day,@startdate,@enddate) as 'Working Time MTD'
		, (SELECT round(sum(timetaken),2) FROM actions JOIN faults on faults.faultid = actions.faultid WHERE actionbyunum = unum and whe_ 
		   BETWEEN @startdate AND @enddate AND requesttypenew IN (SELECT rtid FROM requesttype WHERE RTIsProject = 0 AND RTIsOpportunity = 0)
		   GROUP BY actionbyunum) as 'Service Desk'
		, (SELECT round(sum(timetaken),2) FROM actions JOIN faults on faults.faultid = actions.faultid WHERE actionbyunum = unum and whe_ 
		   BETWEEN @startdate AND @enddate AND requesttypenew IN (SELECT rtid FROM requesttype WHERE RTIsProject = 1 AND RTIsOpportunity = 0)
		   GROUP BY actionbyunum) as 'Project Time'
		, (SELECT round(sum(timetaken),2) FROM actions JOIN faults on faults.faultid = actions.faultid WHERE actionbyunum = unum and whe_ 
		   BETWEEN @startdate AND @enddate GROUP BY actionbyunum) as 'Total Time'
		, (SELECT count(faultid) FROM faults WHERE Clearwhoint = unum AND datecleared BETWEEN @startdate AND @enddate AND requesttypenew IN 
		   (SELECT rtid FROM requesttype WHERE RTIsProject = 0 AND RTIsOpportunity = 0) GROUP BY Clearwhoint) as 'Resolved Tickets'
		, isnull(round((SELECT sum(cleartime) FROM faults WHERE Clearwhoint = unum AND datecleared BETWEEN @startdate AND @enddate AND requesttypenew IN 
		   (SELECT rtid FROM requesttype WHERE RTIsProject = 0 AND RTIsOpportunity = 0) GROUP BY Clearwhoint)/
		   (SELECT count(faultid) FROM faults WHERE Clearwhoint = unum AND datecleared BETWEEN @startdate AND @enddate AND requesttypenew IN 
		   (SELECT rtid FROM requesttype WHERE RTIsProject = 0 AND RTIsOpportunity = 0) GROUP BY Clearwhoint),2),0) as 'Time Taken'
		, (select isnull(count(faultid),0) from faults where clearwhoint=unum and slastate='I' and datecleared BETWEEN @startdate AND @enddate
		   and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) group by clearwhoint) as 'Within SLA Tickets'
		, (select isnull(count(faultid),0) from faults where clearwhoint=unum and slastate !='I' and datecleared BETWEEN @startdate AND @enddate
		   and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) group by clearwhoint) as 'Breached Tickets'
		, (SELECT count(id) FROM KBENTRY WHERE whocreated = unum AND datecreated BETWEEN @startdate AND @enddate) as 'Number of KBs'
		, (SELECT count(fbid) FROM feedback JOIN faults on faultid = FBFaultID WHERE unum = Clearwhoint AND FBDate BETWEEN
		   @startdate AND @enddate GROUP BY Clearwhoint) as 'Number of Surveys'
		, (SELECT avg(fbscore) FROM feedback JOIN faults on faultid = FBFaultID WHERE unum = Clearwhoint AND FBDate BETWEEN
		   @startdate AND @enddate GROUP BY Clearwhoint) as 'Average Survey Rating'
	FROM uname
	LEFT JOIN workdays ON wdid = UWorkDayID
	WHERE unum != 1)a
