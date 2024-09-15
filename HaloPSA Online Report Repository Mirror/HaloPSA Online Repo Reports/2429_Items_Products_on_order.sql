select SHPORef as [PORef],shid as [POID],SDDesc as [Description],SDItemCode as [ItemCode],	SDPrice	as [Price],SDquantity as [QtyOrdered],	SDQtyReceived as [QtyReceived],	SDNote as [Note] from supplierorderdetail 

left join supplierorderheader on SDSHid=shid

where sdquantity>sdqtyreceived
