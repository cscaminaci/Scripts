select 
aareadesc as Client
,(select rtdesc from requesttype where rtid=cdrequesttype) as [Ticket Type]
,case when CDChargeCode=-1 then 'ALL' else
(select fvalue from lookup where fid=17 and fcode=CDChargeCode) end as [Charge Rate]
,CDcat2 as [Category]
,case when cdcpid=-1
then (select sum(pphours) from PREPAYHISTORY where ppareaint=Aarea) else null end as [Prepay Total]
,case when cdcpid=-4 then 'Don''t Invoice'
when cdcpid=-2 then 'Pay as you go'
when cdcpid=-1 then 'Pre Pay'
else (select chcontractref from contractheader where chid=(cdcpid*-1 - 100)) end as [Plan Name]
, case when cdworkhourscovered=0 then 'Anytime'
when cdworkhourscovered=1 then 'Within Working Hours'
else 'Outside Working Hours' end as [Work Hours Covered]
from ContractDetail
join Area on (cdid*-1)=aarea
