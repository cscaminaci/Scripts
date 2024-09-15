select 
qhid
,FOppTargetDate
,sum(QDQuantity*QDPrice) as [Total]
from faults
join QUOTATIONHEADER on qhfaultid=faultid
join QUOTATIONDETAIL on qhid=qdqhid
where (QHApprovalState=0 or QHApprovalState=2)
group by qhid,FOppTargetDate
