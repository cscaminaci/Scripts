SELECT uname AS [Technician]
	,(select count(faultid) from faults where unum=clearwhoint and status = 9 and datecleared > @startdate and datecleared < @enddate) AS [No. of Tickets Closed]
	,round((
		SELECT sum(timetaken)
		FROM actions
		where who = uname
		and convert(varchar,whe_,108) >= '08:00:00'
			and convert(varchar,whe_,108) < '17:30:00' 
               and whe_ > @startdate and whe_ < @enddate
		),2) as [Time Spent Between 8AM - 530PM]
	
		,round((
		SELECT sum(timetaken)
		FROM actions
		where who = uname		
		and convert(varchar,whe_,108) < '08:00:00'
 and whe_ > @startdate and whe_ < @enddate
		 ) +
		 (
		SELECT sum(timetaken)
		FROM actions
		where who = uname	
		and convert(varchar,whe_,108)  > '17:30:00'
 and whe_ > @startdate and whe_ < @enddate
		 ),2)
		as [Time Spent Outside 8AM - 530PM]
FROM UNAME
