select * 
,round((cast((isnull([Billable Hours Tickets],0)+isnull([Billable Hours Projects],0)) as float)/cast(nullif((isnull([Non-Billable Hours],0)+isnull([Billable Hours Tickets],0)+isnull([Billable Hours Projects],0)),0) as float))*100,2) as [Billable Hours %]
from (

select uname as [Agent]
,cast(first_day_of_month as datetime) as [Period Start Date]
,cast(last_day_of_month as datetime) as [Period End Date]
,first_day_of_month as [Period Start]
,last_day_of_month as [Period End]

,(select round(sum(timetaken),2) from actions where who=uname and Whe_>=first_day_of_month and Whe_<=last_day_of_month and ActionBillingPlanID<=-100) as [Contract]
,(select round(sum(timetaken),2) from actions where who=uname and Whe_>=first_day_of_month and Whe_<=last_day_of_month and ActionBillingPlanID=-1) as [Pre-Pay]

,(select round(sum(timetaken),2) from actions join faults on actions.faultid=faults.Faultid where who=uname and Whe_>=first_day_of_month and Whe_<=last_day_of_month and ActionCode+1!=0 and RequestTypeNew not in (select rtid from REQUESTTYPE where RTIsProject=1)) as [Billable Hours Tickets]
,(select round(sum(timetaken),2) from actions join faults on actions.faultid=faults.Faultid where who=uname and Whe_>=first_day_of_month and Whe_<=last_day_of_month and ActionCode+1!=0 and RequestTypeNew  in (select rtid from REQUESTTYPE where RTIsProject=1)) as [Billable Hours Projects]
,(select round(sum(timetaken),2) from actions join faults on actions.faultid=faults.Faultid where who=uname and Whe_>=first_day_of_month and Whe_<=last_day_of_month and ActionCode+1=0 ) as [Non-Billable Hours]


from CALENDAR,uname
where date_day=1
and date_year>=2022
and date_year<=year(getdate())
and unum<>1
)d
