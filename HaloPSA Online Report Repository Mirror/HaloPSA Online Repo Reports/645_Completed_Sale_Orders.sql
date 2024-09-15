select
aareadesc as [Client], 
ohusername as [Username],
ohfaultid as [Ticket ID],
iaccountsID as [Stock Code],
idesc as [Stock Name],
ohorderdate as [Order Date],
ccname as [Cost Centre],
olorderqty as [Quantity],
olsellingprice as [Unit Value],
dinvno as [Asset Tag]
from orderhead 
join orderline on ohid=olid 
join consignmentheader on csohid=ohid 
join consignmentdetail on csid=cdcsid
join site on ohsitenum=ssitenum 
join area on aarea=sarea
join item on olitem=iid
left join costcentres on ccid=olcostcentre 
left join device on dissuecdid=cdid
where ohstatus=13

