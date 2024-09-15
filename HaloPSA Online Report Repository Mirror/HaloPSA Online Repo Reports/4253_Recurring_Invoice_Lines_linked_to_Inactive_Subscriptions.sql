select IHID,
-9-ihid as [Invoice ID],
aareadesc as [Customer Name],
chcontractref as [Contract],
IDItem_ShortDescription as [Line Item]
from
invoiceheader
join invoicedetail on idihid = ihid
join invoicedetailquantity on idqidid = idid
join licence on idqlicenceid = lid
join area on ihaarea = aarea
join contractheader on chid = IHchid
where idisinactive = 0
and lisactive = 0
