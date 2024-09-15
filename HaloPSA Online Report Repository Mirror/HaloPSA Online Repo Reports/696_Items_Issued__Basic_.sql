select
flid as [Ticket ID],
fldesc as [Item],
FLorderqty as [Quantity],
FLCostPrice as [Actual Cost Price],
FLSellingPrice as [Actual Selling Price],
icostprice as [Default Cost Price],
ibaseprice as [Default Selling Price],
FLdateshipped as [Date],
scdesc as [Stock Location]
from faultitem
left join item on iid=flitem
left join StockLocation on scid=FLitemlocation

