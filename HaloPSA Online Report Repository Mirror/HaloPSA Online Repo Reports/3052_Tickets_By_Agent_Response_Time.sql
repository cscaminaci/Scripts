  select  faultid as [Ticket ID],   
 dateoccured as [Date Logged],    
(select uname from uname where assignedtoint=unum) as [Agent],    
(select tstatusdesc from tstatus where status=tstatus) as [Current Status],    
case     
   when fexcludefromsla='true' then 'Excluded'  
   when fixbydate<datecleared then 'Outside'   
   when datecleared<fixbydate then 'Inside'    
   else 'Open' end as [Target Fix Date],    
case when fexcludefromsla='true' and status<>9 then 'Excluded'   
when status=9 then 'N/A(Closed)'   
when status<>9 and frespondbydate>getdate() and fresponsestartdate<>'1899-12-30 00:00:00.000' then 'Response needed(Inside   SLA)'  
when status<>9 and frespondbydate<getdate() and fresponsestartdate<>'1899-12-30 00:00:00.000' then 'Response needed(Outide   SLA)'  
when status<>9 and fresponsestartdate='1899-12-30 00:00:00.000' then 'On Hold'       
else 'open' end as [Target Response Date],    
fresponsetime as [Actual Response Time]  
from faults   
