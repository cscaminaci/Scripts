select

faultid as [Project ID],
convert(varchar(7), FOppTargetDate, 23) as [Target Date],
rtdesc as [Opportunity Type],
sum(foppvalue) as [Total Project Value]

from faults

join requesttype on faults.requesttypenew = requesttype.rtid

where foppvalue > 0
and status not in (8,9)
and fdeleted = 0

group by faultid, convert(varchar(7), FOppTargetDate, 23), rtdesc


