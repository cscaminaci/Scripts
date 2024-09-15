
select 
ohid as [Order ID],
ohorderdate as [Order Date],
uname as [Order Created By],
ihid as [Invoice ID],
ihinvoice_Date as [Invoice Date],
ihdatepaid as [Paid Date],
oldesc as [Order Line],
OLorderqty as [Order Qty],
OLSellingPrice as [Order Price],
OLorderqty * OLSellingPrice as [Order Line Total],
OLorderqty * OLCostPrice as [Order Line Cost Total],
round((OLorderqty * OLSellingPrice)-(OLorderqty * OLCostPrice),2) as [Order Line Profit Total],
idnet_amount as [Invoice Line Total]
 from orderline
join orderhead on olid=ohid
left join invoicedetail on olid=idolid and olseq=idolseq
left join invoiceheader on ihid=idihid
left join uname on unum=ohtechie
