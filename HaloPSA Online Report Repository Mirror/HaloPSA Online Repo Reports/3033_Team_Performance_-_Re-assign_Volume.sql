select
sectio_ as [Team],
count(faults.faultid) as [Tickets]
from actions
left join faults on actions.faultid=faults.faultid
where actoutcome like '%re-assign'
group by faults.sectio_
