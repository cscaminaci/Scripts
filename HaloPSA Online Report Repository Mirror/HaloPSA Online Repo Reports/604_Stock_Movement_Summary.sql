select 'New Stock to '+scdesc as [Location],
idesc as [Item],
idesc2 as [Supplier Code],
shdate as [Date],
idesc as [Accounts Code],
shqty as [Quantity],
shcost as [Value per Item],
shqty*shcost as [Total Value]
from stocklocation 
join stockhistory on shnewlocation=Scid
join item on shitem=iid where SHoldlocation=0
union
select 'Stock returned/moved to '+scdesc+' from '+(case when SHoldlocation>0 then (select scdesc from 
StockLocation where scid=SHoldlocation) else sdesc end) as [Location],
idesc as [Item],
idesc2 as [Supplier Code],
shdate as [Date],
idesc as [Accounts Code],
shqty as [Quantity],
shcost as [Value per Item],
shqty*shcost as [Total Value]
from stocklocation 
join stockhistory on shnewlocation=Scid
join item on shitem=iid 
left join site on ssitenum=-SHoldlocation
where SHoldlocation<>0 
union
select 'Stock out to '+sdesc+' from '+scdesc as [Location],
idesc as [Item],
idesc2 as [Supplier Code],
shdate as [Date],
idesc as [Accounts Code],
shqty as [Quantity],
shcost as [Value per Item],
shqty*shcost as [Total Value]
from stocklocation 
join stockhistory on SHoldlocation=Scid
join item on shitem=iid
join site on ssitenum=-SHnewlocation
 where shnewlocation<0




