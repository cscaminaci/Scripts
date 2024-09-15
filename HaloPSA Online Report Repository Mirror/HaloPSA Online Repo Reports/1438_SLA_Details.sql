select sldesc as [SLA Description]

,Ppolicy as [Priority]
,Pdesc as [Priority Description]
,Presponsetime as [Response Time]
,PResponseUnits as [Response Time Units]
,Ptime as [Resolution Time]
,Punits as [Resolution Time Units]
,case when pworkdaysoverride=-1 then (select wdesc from WORKDAYS where Slwdid=Wdid)
else (select wdesc from WORKDAYS where pworkdaysoverride=Wdid) end as [Working Hours]

from POLICY
join SLAHEAD on Slid=Pslaid
