select top 100
fdatetime as [Date/Time]
,fsection as [Section]
,foutcome as [Action]
,fnote as [Note]
, (select uname from uname where unum=ftechwho ) as [Agent who]
, (select uname from uname where fassignedtoint=unum  ) as [Agent Assigned]
from feed
where ftechwho <>0
order by fid desc

