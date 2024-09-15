select (select aareadesc from area where aiareaid=aarea) as [Client]
, (select sdesc from site inner join faults on site.ssitenum=faults.sitenumber where faults.faultid=aifaultid) 
as [Site]
, AIdesc as [Item]
, aiqty as [Quantity]
, AISellingPrice as [Selling Price]
, AITaxCode as [Tax Code]
, AIdateshipped as [Date Shipped]
, AItemNote as [Item Note]
, AIFaultID as [Ticket ID]
from BillingReport

