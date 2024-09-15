Select 
'Sales Order' as [Type],
aareadesc as [Customer],
ohid as [Order ID],
ohorderdate AS [Order Date],
ohfaultid as [Order Ticket/Opportunity],
oldesc as [Item Description],
OLorderqty as [Quantity],
olsellingprice as [Sale Price (unit)],
OLCostPrice [Cost Price (unit)],
olsellingprice-OLCostPrice  as [Profit (unit)],
round(olsellingprice*OLorderqty,2) as [Sales Price],
round(OLCostPrice*OLorderqty,2) as [Cost Price],
round((olsellingprice-OLCostPrice)*OLorderqty,2)  as [Profit]
from orderhead 
join orderline on olid=ohid
left join site on ohsitenum = ssitenum
left join area on aarea=sarea
union

Select
'Item on Ticket' as [Type], 
aareadesc as [Customer],
0 as [Order ID],
fldateshipped AS [Order Date],
faultid as [Order Ticket/Opportunity],
fldesc as [Item Description],
FLorderqty as [Quantity],
flsellingprice as [Sale Price (unit)],
flCostPrice [Cost Price (unit)],
flsellingprice-flCostPrice  as [Profit (unit)],
round(flsellingprice*FLorderqty ,2) as [Sales Price],
round(flCostPrice  *FLorderqty ,2) as [Cost Price],
round((flsellingprice-flCostPrice  )*FLorderqty ,2)  as [Profit]

from faults
join faultitem on flid=faultid
left join area on aarea=areaint

