select actions.faultid as [Ticket ID]
,(select aareadesc from area where aarea=areaint) as [Customer]
,(select rtdesc from requesttype where rtid=requesttypenew) as [Ticket Type]
,whe_ as [Time Completed]
,who as [Who]
,note as [Action Note]
,round(timetaken,2) as [Time Taken]
,(select fvalue from lookup where fid=17 and fcode=actioncode+1) as [Charge Rate]
from faults
left join actions on actions.faultid=faults.faultid
left join chargerate on crchargeid=Actioncode + 1 
where fdeleted=0 and whe_>@startdate and whe_<@enddate
