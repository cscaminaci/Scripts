select freleasenote as[Release Note]
,cast(case when (select rldesc from release where rlid=freleaseid) is not null then (select rldesc from release where rlid=freleaseid)
when (select rldesc from release where rlid=freleaseid2) is not null then (select rldesc from release where rlid=freleaseid2)
else (select rldesc from release where rlid=freleaseid3) end as int) as [Version]
from faults  where   freleaseid>60   

