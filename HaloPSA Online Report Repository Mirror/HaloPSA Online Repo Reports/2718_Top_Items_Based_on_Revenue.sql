select aareadesc as [Customer]
,aarea as [IDCustomer]
,IHInvoice_Date as [Datetime]
,format(IHInvoice_Date,'yyyy MMMM') as [Date]
,idesc as [Item]
,IDQty_Order as [Quantity]
,IDunit_Price as [Unit Price]
,cast(IDNet_Amount as money) as [Revenue]
,cast(IDUnit_Cost*IDQty_Order as money) as [Cost]
,cast(IDNet_Amount-(IDUnit_Cost*IDQty_Order) as money) as [Profit]
from INVOICEHEADER
join invoicedetail on ihid=IdIHid
left join area on IHaarea=Aarea
left join item on id_itemid=iid
where ihid>0 
and id_itemid>0
