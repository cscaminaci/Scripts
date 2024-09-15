select 
qhid
,FOppTargetDate
,sum(QDQuantity*QDPrice) as [Total]
from faults
join QUOTATIONHEADER on qhfaultid=faultid
join QUOTATIONDETAIL on qhid=qdqhid
where qhid not in (select OHQHID from orderhead)
group by qhid,FOppTargetDate
