select (select aareadesc from area where aarea=(select areaint from Faults where Faults.Faultid=Actions.Faultid)) as [Customer]
,Actoutcome as [Action]
,who as [Technician]
,note as [Labour Description]
,(select fvalue from lookup where fid=17 and actioncode+1 = fcode) as [Charge Code]
,ROUND (timetaken,2) as [Hours Taken]
,actionchargehours as [Chargable Hours]
,actionchargeamount as [Charge Amount]
,actioncontractID as [Contract ID]
,(select chcontractref from contractheader where chid=actioncontractID) as [Contract Ref]
from ACTIONS
Where whe_>@startdate and whe_<@enddate
and who in (select uname from uname)
and actioncode+1 <> 0
and (select fdeleted from faults where faults.faultid=actions.faultid)=0
