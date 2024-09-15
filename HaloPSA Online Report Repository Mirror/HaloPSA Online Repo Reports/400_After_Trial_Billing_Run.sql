
select (select aareadesc from area where aarea=aiareaid) as [Client],
aiqty as [Quantity],
AISellingPrice as [Price],
AIFaultid as [Ticket ID],
AIBPDesc as [Billing Description],
AIChargeRateDesc as [Rate],
AIdetails as [Details]
from billingreport


