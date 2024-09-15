select 
qhid
,FOppTargetDate
,sum(QDQuantity*QDPrice) as [Total]
,sum(QDQuantity*qdcostprice) as [Total Cost]
,sum(QDQuantity*QDPrice) - sum(QDQuantity*qdcostprice) as [GP]
from faults
join QUOTATIONHEADER on qhfaultid=faultid
join QUOTATIONDETAIL on qhid=qdqhid
where qhid not in (select OHQHID from orderhead)
and qhstatus in (select fcode from lookup where fid=39 and (fvalue3<>'1' or fvalue3 is null))
group by qhid,FOppTargetDate
