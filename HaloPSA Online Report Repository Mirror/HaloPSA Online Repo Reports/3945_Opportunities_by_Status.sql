select

faultid as [Opportunity ID],
uname as [Account Manager],
rtdesc as [Opportunity Type],
sum(foppvalue) as [Total Project Value],
tstatusdesc as [Status]

from faults 

join uname on faults.assignedtoint = uname.unum
join requesttype on faults.requesttypenew = requesttype.rtid
join tstatus on faults.status = tstatus.tstatus

where foppvalue > 0
and status not in (8,9)
and fdeleted = 0

group by uname, rtdesc, faultid, tstatusdesc
