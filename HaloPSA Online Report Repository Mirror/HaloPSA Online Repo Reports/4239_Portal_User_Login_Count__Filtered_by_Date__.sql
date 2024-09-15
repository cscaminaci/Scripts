select 
convert(date, p.pldate) as [Login Date],
count(u.uusername) as [User Count]
from portallog as p
inner join users u on p.plfkid = u.uid
where p.pldate >= @startdate and p.pldate <= @enddate
group by convert(date, p.pldate)
