 select
ccname as 'Cost Centre',
shdate as 'Date',
scdesc as 'Stock Location',
idesc as 'Item Name',
idesc2 as 'Part Code',
SHqty as 'Quantity',
OLCostPrice as 'Cost',
OLSellingPrice as 'Price',
sdesc as 'Destination'
from stockhistory
join item on SHitem=iid
join orderline on shreference=olid and SHType=4
left join costcentres on ccid=olcostcentre
join stocklocation on sholdlocation=scid
left join site on (shnewlocation)*-1=ssitenum

union

select 
ccname as 'Cost Centre',
shdate as 'Date',
scdesc as 'Stock Location',
idesc as 'Item Name',
idesc2 as 'Part Code',
SHqty as 'Quantity',
FLCostPrice as 'Cost',
FLSellingPrice as 'Price',
sdesc as 'Destination'
from stockhistory
join item on SHitem=iid
join faults on shreference=faultid and SHType=5
join faultitem on flid=faultid
left join costcentres on ccid=flcostcentre
join stocklocation on sholdlocation=scid
left join site on (shnewlocation)*-1=ssitenum



