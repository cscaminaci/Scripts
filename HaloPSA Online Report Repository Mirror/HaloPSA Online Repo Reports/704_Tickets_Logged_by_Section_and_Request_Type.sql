select sectio_ as [Section]
    , rtdesc as [Request Type]
    , count(faultid) as [Tickets Logged]
from faults

join requesttype
    on requesttypenew=rtid

where rtid=requesttypenew 

group by sectio_, rtdesc




