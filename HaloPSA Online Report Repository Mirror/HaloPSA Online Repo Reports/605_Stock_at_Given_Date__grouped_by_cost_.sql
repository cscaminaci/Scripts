select Location,Item,[Supplier Code],[Accounts Code],[Total Value],sum(Quantity) as [Quantity] from
(select scdesc as [Location],
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
and shdate<@enddate
union
select scdesc as [Location],
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
where SHoldlocation<>0 and shdate<@enddate 
union
select scdesc as [Location],
idesc as [Item],
idesc2 as [Supplier Code],
shdate as [Date],
idesc as [Accounts Code],
-shqty as [Quantity],                     
shcost as [Value per Item],
shqty*shcost as [Total Value]
from stocklocation 
join stockhistory on SHoldlocation=Scid
join item on shitem=iid
join site on ssitenum=-SHnewlocation
 where shnewlocation<0 and shdate<@enddate)k
 group by Location,Item,[Supplier Code],[Accounts Code],[Total Value]




