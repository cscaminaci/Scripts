select aareadesc as [Client],
IHID as [Invoice ID],
IHInvoice_Date as [Invoice Date],

sum(IDNet_Amount) as [Net Price],
sum(IDTax_Amount) as [Tax Amount]

from invoiceheader join invoicedetail on ihid=idihid
join area on aarea=ihaarea
where ihid>0
group by aareadesc ,IHID ,IHInvoice_Date
