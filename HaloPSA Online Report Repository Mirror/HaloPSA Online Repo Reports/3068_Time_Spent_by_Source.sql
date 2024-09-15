select
fvalue as [Source],
ROUND(sum(timetaken),2) as 'Time Taken (Decimal Hours)',
COUNT (*) as [Number of Tickets]

from faults

JOIN lookup ON fid = 22 AND frequestsource = fcode
JOIN actions on faults.faultid = actions.faultid

WHERE dateoccured BETWEEN @startdate and @enddate
GROUP BY fvalue
HAVING COUNT(*) > 0 
