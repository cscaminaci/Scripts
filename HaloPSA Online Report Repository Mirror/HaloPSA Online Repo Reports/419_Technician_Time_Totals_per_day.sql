select
convert(nvarchar(10),cast(floor(cast(whe_ as float)) as datetime),103) as 'Date',
(select uname from uname where who=uname) as 'Tech',
'Total' as'Rate',
round(sum(isnull(timetaken,0)),2) as 'Time'
from faults inner join actions on faults.faultid=actions.faultid 
where upper(who) in (select upper(uname) from uname) and timetaken is not null and timetaken<>0
and whe_>@startdate and whe_<@enddate
group by convert(nvarchar(10),cast(floor(cast(whe_ as float)) as datetime),103),who    



