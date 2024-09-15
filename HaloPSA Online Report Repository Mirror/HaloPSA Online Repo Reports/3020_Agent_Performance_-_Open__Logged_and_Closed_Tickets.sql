 select  (uname)as [Agent],  
(select count(faultid) from Faults where Assignedtoint=unum and Status<>9)as [Open Tickets],  
(select count(faultid) from Faults where Assignedtoint=unum and dateoccured>@startdate and dateoccured<@enddate)as [Open Tickets (Incl. Hold)],  
(select count(faultid) from Faults where Assignedtoint=unum and status=9 and datecleared>@startdate and datecleared<@enddate)as [Closed Tickets]  
from Uname 
inner join Faults on Unum=Assignedtoint 
 group by uname,unum   
