select
idesc as [Item],
iaccountsid as [Accounts Code],
idesc2 as [Supplier Code],
shporef [Purchase Order Ref],
SupplierOrderHeader.shid as [Purchase Order ID],
ishdate as [Date Received],
(select sdesc from site where ssitenum=ishsite) as [Location],
ishquantityin as [Quantity],
iscost as [Cost]
from item 
join itemstockhistory on ishiid=iid 
left join itemstock on isid=ishitemstockid
join SupplierOrderHeader on SupplierOrderHeader.shid=ishshid
where ishquantityin > 0

