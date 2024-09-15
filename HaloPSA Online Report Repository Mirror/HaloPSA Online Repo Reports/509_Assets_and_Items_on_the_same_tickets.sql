select * from (
select flid as [Ticket ID],
fldesc as [Item],
FLDateshipped as [Date Shipped],
(select dinvno from device where dsite=(select devsite from faults where faultid=flid) and ddevnum=(select 
devicenumber from faults where faultid=flid)) as [Asset Tag]
from faultitem
union
select flid as [Ticket ID],
fldesc as [Item],
FLDateshipped as [Date Shipped],
(select dinvno from device where dsite=fdsiteid and ddevnum=fddevnum) as [Asset Tag]
from faultitem join faultdevice on fdfaultid=flid )t where [asset tag]<>null

