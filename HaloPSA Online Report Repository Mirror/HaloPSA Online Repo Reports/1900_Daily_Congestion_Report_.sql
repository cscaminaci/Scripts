select distinct a.[Agent], a.[Ticket ID], a.[Client], a.[Summary], sum(cast(a.[Total Time] as Money)) over (partition by a.[Agent], a.[Ticket ID]) as [Sum of Time Taken]
from 
(
select faults.faultid as [Ticket ID],  
(select aareadesc from area where areaint=aarea) as [Client],  
cast(symptom as varchar (100)) as[Summary],  
dateoccured,  
datecleared,  
(select rtdesc from requesttype where rtid=requesttypenew) as [RequestType],  
who as [Agent],  
isnull(round(timetaken,2),0) as [Total Time],  
(select fvalue from lookup where fid=17 and fcode=actioncode+1) as [ChargeCode],  
isnull(actions.nonbilltime,0) as [NonBillableTime],  
whe_  

from faults 

inner join uname on faults.assignedtoint=uname.Unum  
inner join actions on faults.faultid=actions.faultid  

where(timetaken<>0 or actions.nonbilltime<>0) and who in (select uname from uname) and whe_>@startdate and whe_<@enddate and timetaken>1.333333
)a

