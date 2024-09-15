select 
(select uname from uname where unum=whoagentid) as 'Agent', 
(select fvalue from lookup where fid=17 and fcode=actioncode+1) as [Charge Rate], 
isnull(round(sum(timetaken),2),0) as [Total Time (Hrs)] 
from actions 
join faults on faults.faultid=actions.faultid
join area on aarea = areaint
where Whe_ > @startdate and Whe_ < @enddate and whoagentid>0 and actisbillable='True' and timetaken>0
group by actioncode, whoagentid
