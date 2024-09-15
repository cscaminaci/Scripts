select faultid as [Ticket ID],
symptom as [Subject],
(select rtdesc from requesttype where rtid=requesttypenew) as [Ticket Type],
(select aareadesc from area where aarea=areaint) +' - '+username as [Username],
(select uname from uname where unum=assignedtoint) as [Assigned To] ,
(select uname from uname where unum=clearwhoint) as [Closed By],
dateoccured as [Date Created],
case when datecleared<10 then null else datecleared end as [Date Closed]              
from faults where dateoccured>@startdate or datecleared>@startdate  or datecleared<10 or datecleared is null    
                            


