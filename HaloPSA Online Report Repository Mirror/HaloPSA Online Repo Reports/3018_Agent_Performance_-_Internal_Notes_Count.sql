select
uname as [Agent],
sectio_ as [Team], 
count(actionnumber) as [Count]
from actions
left join faults on actions.faultid=faults.faultid
left join uname on who=uname
where actoutcome like 'Internal Note%' and fdeleted=0 and fmergedintofaultid=0
group by sectio_, uname
