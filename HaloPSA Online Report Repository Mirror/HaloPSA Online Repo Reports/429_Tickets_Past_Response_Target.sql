select faultid as 'Ticket ID'
, username as 'Username'
, (select aareadesc from area where areaint=aarea) as 'Client'
, round((cast((getdate()-frespondbydate) as float))*24,2) as 'Hours Since Target'
, Symptom as 'Ticket Desctription'
, (select rtdesc from requesttype where rtid=requesttype) as 'Ticket Type'    
from faults
where FResponsedate is null and FRespondByDate<getdate()      
and status not in (8,9)
and fexcludefromsla=0
and fslaonhold=0                                                





