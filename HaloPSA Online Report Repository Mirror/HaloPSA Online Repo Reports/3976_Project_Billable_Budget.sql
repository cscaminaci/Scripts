Select *, round([Budgeted Hours]-[Billable Time],2) as [Billable Hours Remaining] from (
select
faults.faultid as [Ticket ID]
,aareadesc as [Client]
,Symptom as [Project Title]
,tStatusdesc as [Project Status]
, (select btname from budgettype where btid=fbtbtid) [Budget Type]
,cast(fbthours as nvarchar) as [Budgeted Hours]

,round(fbtactualtime,2) as [Total Completed Hours]
,round((fbthours-fbtactualtime),2) as [Total Hours Remaining]

,(select isnull(round(sum(timetaken), 2), 0) from actions 
join faults f on f.faultid=actions.faultid
where actioncode>-1
and (f.fxrefto=faults.faultid or f.faultid=faults.faultid)
) as [Billable Time]

,(select isnull(round(sum(timetaken), 2), 0) from actions 
join faults f on f.faultid=actions.faultid
where actioncode = -1
and (f.fxrefto=faults.faultid or f.faultid=faults.faultid)
) as [Non-Billable Time]

,assigned.uname as [Assigned Tech]
,dateoccured as [Date Opened]

 
from
          faults 
left join area on aarea =areaint
left join actions on actions.faultid=faults.faultid
left join uname assigned on assigned.unum =assignedtoint
left join uname closer on closer.unum = clearwhoint
left join tstatus on status = tstatus
left join requesttype on rtid = requesttypenew
left join faultbudget on faults.faultid=fbtfaultid
left join budgettype on btid=fbtbtid

Where fdeleted=0 and fmergedintofaultid=0 and dateoccured between @startdate and @enddate and rtdesc='Project'
group by faults.faultid,area.aareadesc,faults.symptom,tStatusdesc,fbtbtid,fbthours,fbtactualtime,assigned.uname,dateoccured)a
