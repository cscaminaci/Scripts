select * from (select who as Technician, round(sum(timetaken),2) as BillableHours, round(sum(nonbilltime),2) as NonBillableHours, round((sum(timetaken)+sum(nonbilltime)),2) as TotalHours from ACTIONS
    where whe_<@enddate and whe_>@startdate and (timetaken>0 or nonbilltime>0) and who in (select uname from uname) group by who) a 

