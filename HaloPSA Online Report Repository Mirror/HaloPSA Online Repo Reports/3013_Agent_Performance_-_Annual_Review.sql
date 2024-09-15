SELECT
   (uname)as [Agent]
  ,(select count(faultid) from Faults where Assignedtoint=unum and dateoccured>@startdate and dateoccured<@enddate  and 
    FexcludefromSLA=0)as [Logged in Period]
  ,(select count(faultid) from Faults where Assignedtoint=unum and status=9 and datecleared>@startdate and 
    datecleared<@enddate and FexcludefromSLA=0)as [Closed In Period]   
  ,(select COUNT(faultid) from Faults where Assignedtoint=Unum and status=9 and datecleared>@startdate and 
    datecleared<@enddate and SLAState='O'  and FexcludefromSLA=0)as [Late Resolution Count] 
  ,cast((round(cast((select count(faultid) from faults where slastate='O' and Assignedtoint=unum and datecleared>@startdate 
   and datecleared<@enddate  and status=9  and FexcludefromSLA=0)as float)  /replace(cast(((select COUNT(faultid) from faults 
   where status=9 and Assignedtoint=unum and datecleared>@startdate and datecleared<@enddate   and FexcludefromSLA=0))as 
   float),0,1),4)*100)as nvarchar(50)) + ' %' as [Resolution Target Missed %]
  ,(select COUNT(faultid) from Faults where Assignedtoint=Unum and dateoccured>@startdate and dateoccured<@enddate and 
     SLAresponseState='O'  and FexcludefromSLA=0)as [Late Response Count]
  ,cast((round(cast((select count(faultid) from faults where slaresponsestate='O' and dateoccured>@startdate and 
   dateoccured<@enddate and Assignedtoint=unum  and FexcludefromSLA=0)as float)  /replace(cast(((select COUNT(faultid) from 
   faults where Assignedtoint=unum and dateoccured>@startdate and dateoccured<@enddate    and FexcludefromSLA=0))as 
   float),0,1),4)*100)as nvarchar(50)) + ' %' as [Response Target Missed %]    
FROM Uname 
INNER JOIN Faults on Unum=Assignedtoint  
GROUP BY uname,unum  
