 select
shdate as 'Date',
scdesc as 'Stock Location',
idesc as 'Item Name',
idesc2 as 'Part Code',
SHqty as 'Quantity',
SHCost as 'Cost'
from stockhistory
join item on SHitem=iid
join stocklocation on shnewlocation=scid
where shnewlocation>0


