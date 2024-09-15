select    
(select uname from uname where unum=assignedtoint) as [Agent],    
Round((sum (case   when  slaresponsestate='O' and fresponsedate>dateadd(week, datediff(week, 0, getdate()), 0)    then 1  else 0 end)   *100.0/cast(count(faultid) as float)),1) as [% Outside Response SLA],    
Round((sum(case   when  slastate='O' and fresponsedate>dateadd(week, datediff(week, 0, getdate()), 0)    then 1   else 0 end)*100/cast(count(faultid) as  float) ),1) as [% Outside Resolution SLA],    
Round((sum(case   when  slaresponsestate='O' and fresponsedate>dateadd(week, datediff(week, 0, getdate()), 0)    then 1   else 0 end)),1) as [Number Outside Response SLA],    
(select count(faultid) from faults where assignedtoint=T.assignedtoint and datecleared>=dateadd(week, datediff(week, 0,   getdate()), 0)) as [Number Closed This Week],    
(select count(faultid) from faults where assignedtoint=T.assignedtoint and dateoccured>=dateadd(week, datediff(week, 0,   getdate()), 0)) as [ Number Opened This Week] ,    
count(faultid) as [Total Open Tickets]    
from faults T     
where status<>9           
group by assignedtoint  
