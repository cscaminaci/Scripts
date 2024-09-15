select isnull(nullif(round( AVG(fresponsetime),2),0),0) as 'AverageResponseTimeLast7DaysHours'

from Faults 
join requesttype on rtid=requesttypenew 

where FResponseDate> GETDATE()-7 
and FexcludefromSLA = 0 
and fdeleted=0 
and rtisproject=0 
and rtisopportunity=0
