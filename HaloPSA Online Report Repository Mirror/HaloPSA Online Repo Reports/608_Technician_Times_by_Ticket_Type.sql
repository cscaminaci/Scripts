select
(select rtdesc from requesttype where rtid=requesttypenew) as 'Request Type',
who,
count(faults.faultid) as 'Number Of Tickets',
sum(round(timetaken,2)) as'Total Time Taken',
sum(actions.nonbilltime) as 'Non Bill Time'
from faults inner join uname on faults.assignedtoint=uname.Unum inner join actions on faults.faultid=actions.faultid
where (timetaken<>0 or actions.nonbilltime<>0) and who in (select uname from uname) and Whe_>@startdate and Whe_<@enddate
group by RequestTypenew, who                                   


