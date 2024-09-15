select faultid as [Ticket ID]
from faults
where status=9
and FMergedIntoFaultid in ('', 0)



