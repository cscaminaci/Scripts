
select * from (
select flid as [Ticket ID],
fldesc as [Item],
FLsellingprice as [Selling Price],
FLDateshipped as [Date Shipped],
tdesc as [Asset Type],
dinvno as [Asset Tag]
from faultitem join faultdevice on fdfaultid=flid join device on fddevnum=ddevnum and FDsiteid=dsite join xtype on dtype=ttypenum )t
 where [asset tag] is not null
 
