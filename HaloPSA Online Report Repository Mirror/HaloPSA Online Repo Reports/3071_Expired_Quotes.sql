select 
QHDate as [Quote Date]
,QHExpiryDate as [Expiry Date]
,qhfaultid as [Ticket ID]
,(select fvalue from lookup where fid=39 and fcode=qhstatus) as [Quote Status]
,aareadesc as [Client]
,uname as [Assigned Salesperson]
,qhtitle as [Quote Reference]
,(select top 1 whe_ from actions where faults.faultid=actions.faultid and actionstatusafter=22) as [Date/Time Quote Accepted]
,	datecleared as [Date Opp was closed]

from faults

join QUOTATIONHEADER on qhfaultid=faultid
left join uname on unum=assignedtoint
left join area on aarea=areaint

where fdeleted=0 and qhstatus not in (1) and QHExpiryDate<getdate()

