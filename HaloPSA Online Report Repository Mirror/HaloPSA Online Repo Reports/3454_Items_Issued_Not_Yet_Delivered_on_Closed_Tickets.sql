select
flid as [Ticket ID],
fldesc as [Item],
FLorderqty as [Quantity],
FLCostPrice as [Actual Cost Price],
FLSellingPrice as [Actual Selling Price],
flstatus as [Invoice Number]
from faultitem
where  flid not in (select faultid from faults where not fdeleted=0) 
and flid in (select faultid from faults where status=9 and fdeleted=0)
and FLshippedqty < FLorderqty
