select iid as [Item ID],
idesc as [Item Description],
aareadesc as [Customer],
sdesc as [Stock Location],
stbname as [Stock Bin],
sum(ISquantityremaining) as [Qty In Stock],
Iminstockqty as [Minimum Stock],
(select top 1 ist.iscost from itemstock ist where ist.isiid=itemstock.isiid and ist.ISlocation=itemstock.ISlocation order by ist.isdate desc)  as [Last Cost]
from item
left join ItemStock on isiid=iid
join site on ISlocation=Ssitenum
left join stockbin on stbid = isstbid
left join area on aarea=sarea
where ISquantityIn<99999
group by isiid, iid, idesc, sdesc, ISlocation, Iminstockqty, stbname, aareadesc
