SELECT   
  (select uname from uname where unum=assignedtoint)as [Agent]
 ,(faultid) as [Ticket ID]  
 ,(satisfactionlevel)as [Rating]   
 ,cast(Satisfactioncomment as varchar(max))as [Review Comments] 
FROM faults  
WHERE satisfactionlevel<>0  and  datecleared>@startdate  and  datecleared<@enddate 
GROUP BY assignedtoint,faultid,CAST(Satisfactioncomment as varchar(max)),satisfactionlevel   
