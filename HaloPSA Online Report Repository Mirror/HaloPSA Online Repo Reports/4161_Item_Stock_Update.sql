select iid as [Item ID],
idesc as [Name],
sdesc as [StockLocation],
sum(ISquantityremaining) as [Quantity],
stbname as [StockBin]
from item
left join ItemStock on isiid=iid
left join site on ISlocation=Ssitenum
LEFT JOIN stockbin ON islocation = stbssitenum AND stbid = isstbid
/*where ISquantityIn<99999*/
group by isiid,iid , idesc  ,sdesc ,ISlocation,Iminstockqty,stbname 
