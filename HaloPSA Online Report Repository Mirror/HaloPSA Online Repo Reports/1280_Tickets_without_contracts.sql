select aareadesc as [Client]
,sdesc as [Site]
,uname as [Agent Assigned]
,f.faultid as [Ticket ID]
,dateoccured as [Date Created]
,tstatusdesc as [Status]
,round(sum(timetaken),2) as [Time on Ticket]

from faults f
join uname on unum = Assignedtoint
join actions a on a.faultid=f.faultid
join site on sitenumber=ssitenum
join area on Aarea=Areaint
join tstatus on tstatus = status

where fdeleted=0
and fcontractid=0

group by f.faultid,aareadesc,sdesc,uname,dateoccured,tstatusdesc
