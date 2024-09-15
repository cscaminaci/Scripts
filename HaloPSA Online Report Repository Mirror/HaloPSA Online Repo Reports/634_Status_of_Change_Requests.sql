select
      faultid as [Change ID]
    , username as [User]
    , symptom as [Summary]
    , isnull((select apdesc from approvalprocess where apid=fcurrentapprovalprocess),'n/a') as [Approval Process]
    , case when fchangestatus=1 then 'Rejected' when fchangestatus=2 then 'Approved' when fchangestatus=3 then 'Under Review' else 'Awaiting Approval' end as [Status]
    , isnull((select top 1 uname from uname right join faultapproval on faunum=unum where faid=faultid order by faseq desc),(select top 1 bhdesc from cabheader right join faultapproval on bhid=facabid where faid=faultid order by faseq 
desc)) as [Last Approver]
from
      faults                                                               
where requesttype=2 and dateoccured > @startdate and dateoccured < @enddate


