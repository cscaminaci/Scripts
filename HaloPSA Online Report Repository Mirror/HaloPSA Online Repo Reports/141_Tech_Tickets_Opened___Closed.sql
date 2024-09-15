select Uname as 'Tech',
(select COUNT(faultid)from Faults where takenby = Uname and (dateoccured>@startdate and 
dateoccured<@enddate))'Tickets_Opened',
(select COUNT(faultid)from Faults where Clearwhoint = unum and (datecleared>@startdate and 
datecleared<@enddate))'Tickets_Closed'
from uname where Uname <> 'Unassigned'          



