select 
[Customer],
[Account Manager],
[OrderCreatedAgent].uname as [Original Order created By] ,
[Halo Recurring Invoice ID],
[Halo Invoice ID],
[Invoice Date],
[Invoice Line Description],
[Invoice Line Value],
[Current Recurring Invoice Line Value],
OLorderqty*OLSellingPrice as [Original Order Value]
from (
select 
[AccountManager].uname as [Account Manager],
(select top 1 olid from orderline where olid=[RecurringInvoiceLine].IDOLID order by olid desc) as [origolid],
aareadesc as [Customer],
[RecurringInvoice].ihid as [Halo Recurring Invoice ID],
[Invoice].ihid as [Halo Invoice ID],
[Invoice].IHInvoice_Date as [Invoice Date],
[InvoiceLine].IDItem_ShortDescription as [Invoice Line Description],
[InvoiceLine].idnet_amount as [Invoice Line Value],
[RecurringInvoiceLine].idnet_amount as [Current Recurring Invoice Line Value]
 from invoicedetail as [InvoiceLine]
join invoiceheader as [RecurringInvoice] on [InvoiceLine].idrecurringinvoiceid=[RecurringInvoice].ihid
left join InvoiceDetail  as [RecurringInvoiceLine] on [InvoiceLine].IDrecurringInvoiceLineId=[RecurringInvoiceLine].idid
left join invoiceheader as [Invoice]  on [InvoiceLine].idihid=[Invoice].ihid
join area on aarea=[RecurringInvoice].ihaarea
left join uname as [AccountManager] on [AccountManager].unum=AAccountManagerTech
)a
left join orderline on olid=[origolid]
left join orderhead on ohid=olid
left join uname as [OrderCreatedAgent] on [OrderCreatedAgent].unum=OHtechie

