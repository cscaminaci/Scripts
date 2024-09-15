select 
uname as [Agent]
,sum(QDQuantity*QDPrice) as [Total]
,sum(QDQuantity*qdcostprice) as [Total Cost]
,sum(QDQuantity*QDPrice) - sum(QDQuantity*qdcostprice) as [GP]
from faults
join uname on unum=assignedtoint
join QUOTATIONHEADER on qhfaultid=faultid
join QUOTATIONDETAIL on qhid=qdqhid
where qhid not in (select OHQHID from orderhead)
 and fdeleted=0 and datepart(MONTH,fopptargetdate)=datepart(MONTH,getdate())
group by uname,FOppTargetDate
