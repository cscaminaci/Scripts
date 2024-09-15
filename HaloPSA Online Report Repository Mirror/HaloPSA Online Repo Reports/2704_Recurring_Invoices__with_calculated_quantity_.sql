select aareadesc as [Client],
isnull(idihid,0) as [Invoice Number],
iditem_shortdescription as [Invoice Line Description],
case when idrecurringinvoicequantitytype in (2,4) then isnull(lcount,0) else idqty_order end as [Qty]
from invoicedetail
join invoiceheader on  ihid=idihid
join area on aarea=ihaarea
left join  InvoiceDetailQuantity on idqidid =idid
left join licence on lid=IDQLicenceId 
where 
ihid<0
