select fldesc as [Product],
flnote as [Note],
FLorderqty as [Quantity],
(select top 1 shporef from SUPPLIERORDERHEADER join SUPPLIERORDERDETAIL on shid=sdshid where SHfaultID=faultid and SDItemid=flitem) as [PO No],
(select top 1 SHPODate from SUPPLIERORDERHEADER join SUPPLIERORDERDETAIL on shid=sdshid where SHfaultID=faultid and SDItemid=flitem) as [PO Date]
from 
faults
join faultitem on faultid=flid
where isnull(flstatus,0) <1
