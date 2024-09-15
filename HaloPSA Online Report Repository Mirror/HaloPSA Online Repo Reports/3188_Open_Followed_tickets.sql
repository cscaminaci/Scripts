Select (select uname from uname where unum=fwunum) as Agent, FWfaultid as [Ticket ID], (select tstatusdesc from tstatus where status=tstatus) as [Status], symptom as [Summary], (select uname from uname where unum=assignedtoint) as [Assigned Agent], (select top 1 whe_ from actions where actions.faultid=fwfaultid order by whe_ desc) as [Last Action], seriousness as [Priority] from faultwatch join faults f on FWfaultid=f.faultid where fdeleted=0