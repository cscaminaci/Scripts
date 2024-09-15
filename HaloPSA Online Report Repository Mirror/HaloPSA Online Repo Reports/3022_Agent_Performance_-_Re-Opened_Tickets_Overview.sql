select *,  
case when 'Closed'=0 then 0 else (('Re-Opened'* 100) / 'Closed')  end as [Re-Opened %]   

from 
   (select uname as [Agent]    
  ,(select count (faultid) from faults where datecleared>@startdate and datecleared<@enddate and  assignedtoint=unum and    (select top 1 
    actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber)   > 0    ) as 'Closed'   
  ,(select count (faultid) from faults where datecleared>@startdate and datecleared<@enddate and  assignedtoint=unum and    (select top 1 
    actionnumber from actions where actions.faultid=faults.faultid and actoutcome='Close' order by actionnumber)  <  (select top 1 actionnumber from 
    actions where actions.faultid=faults.faultid order by actionnumber desc)  ) as 'Re-Opened'     

                          from uname where unum<>1 ) a   
