
select 
distinct faults.faultid as [Ticket ID],  
(select aareadesc from area where areaint=aarea) as [Client], 
(select rtdesc from requesttype where rtid=requesttypenew) as [RequestType],   
cast(symptom as varchar (100)) as[Summary],    
flastactiondate as [Last Action Date]

from faults 

inner join uname on faults.assignedtoint=uname.Unum  
inner join actions on faults.faultid=actions.faultid  

where(timetaken<>0 or actions.nonbilltime<>0) and who in (select uname from uname) and whe_>@startdate and whe_<@enddate and flastactiondate < getdate()-5 and status not in(4,5,8,9)


