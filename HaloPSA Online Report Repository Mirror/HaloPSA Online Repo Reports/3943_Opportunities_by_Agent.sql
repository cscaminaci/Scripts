select

count (faultid) as [Number of Projects],
uname as [Agent],
rtdesc as [Opportunity Type],
sum(foppvalue) as [Total Project Value]

from faults 

join uname on faults.assignedtoint = uname.unum
join requesttype on faults.requesttypenew = requesttype.rtid

where foppvalue > 0
and status not in (8,9)
and fdeleted = 0

group by uname, rtdesc
