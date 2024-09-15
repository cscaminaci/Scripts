select
idesc [Item Name]
, gdesc [Category]
, idesc3 [Description]
, (select cdesc from company where cnum=isupplier) [Supplier]
, idesc2 [Supplier SKU]
, iweight [Weight]
, ibasePrice [Price]
, iCostPrice [Cost]
, iIsRecurringItem [Recurring]
, iTaxable [Taxable]
from item
join generic on ggeneric=igeneric
