select 
Faultid as [RequestID]
,username as [Username]
,sdesc as [SiteName]
,aareadesc as [ClientName]
,Symptom as [Summary]
,Symptom2 as [Details]
,RTDesc as [RequestType]
,tStatusdesc as [Status]
,sectio_ as [Team]
,assigned.uname as [AssignedTo]
,dateoccured as [DateOccurred]
,pdesc as [Priority]
,Sldesc as [SLA]
,category2 as [Category]
,category3 as [Category 2]
,category4 as [Category 3]
,category5 as [Category 4]

 
from
          faults 
left join area on aarea =areaint
left join site on ssitenum = sitenumber
left join uname assigned on assigned.unum =assignedtoint
left join uname closer on closer.unum = clearwhoint
left join tstatus on status = tstatus
left join policy on ppolicy = seriousness and pslaid=slaid
left join slahead on slid=slaid
left join requesttype on rtid = requesttypenew
