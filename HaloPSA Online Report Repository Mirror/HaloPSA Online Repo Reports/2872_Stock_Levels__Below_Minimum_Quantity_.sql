select * from (
select iid as [Item ID],
idesc as [Item Description],
sdesc as [Stock Location],
sum(isnull(ISquantityremaining,0)) as [Qty In Stock],
cast(Iminstockqty as float) as [Minimum Stock],
(select top 1 ist.iscost from itemstock ist where ist.isiid=itemstock.isiid and ist.ISlocation=itemstock.ISlocation order by ist.isdate desc)  as [Last Cost]
from item
left join ItemStock on isiid=iid
left join site on ISlocation=Ssitenum

group by isiid,iid , idesc  ,sdesc ,ISlocation,Iminstockqty )b where  [Minimum Stock]>[Qty In Stock]
