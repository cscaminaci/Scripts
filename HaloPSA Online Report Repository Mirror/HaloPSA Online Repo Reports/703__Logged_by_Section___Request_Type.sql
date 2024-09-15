select sectio_ as [Section]
    , rtdesc as [Request Type]
    , count(faultid) as [Tickets Logged]
from faults 

join requesttype
    on requesttypenew=rtid

where rtid=requesttypenew 
AND dateoccured >@startdate and dateoccured<@enddate
 and fdeleted=0
group by sectio_, rtdesc
                          
