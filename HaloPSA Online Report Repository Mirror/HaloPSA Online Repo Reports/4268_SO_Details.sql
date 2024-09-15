Select 
ohid as 'SO',
aareadesc as 'Client',
Ohorderdate as 'Date',
(select fvalue from lookup where fid = 34 and fcode = ohuserstatus) as 'Status', 
case when isnull(Round(((select round(sum(isnull(ipamount,0)), 2) from invoicepayment where ipihid=OHInvoiceNumber)/nullif((select sum(isnull(idnet_amount,0)+isnull(idtax_amount,0)) from invoicedetail where IDOLID=ohid and IDisGroupDesc='False'),0)*100),2),0)> 100 then 100 else isnull(Round(((select round(sum(isnull(ipamount,0)), 2) from invoicepayment where ipihid=OHInvoiceNumber)/nullif((select sum(isnull(idnet_amount,0)+isnull(idtax_amount,0)) from invoicedetail where IDOLID=ohid and IDisGroupDesc='False'),0)*100),2),0) end [Paid %],
isnull(round((select sum(isnull(IDQty_Order,0)*isnull(IDUnit_Price,0)) from invoicedetail where IDOLID=ohid and IDisGroupDesc='False' and idihid>0)/nullif((select sum(isnull(OLorderqty,0)*isnull(OLSellingPrice,0)) from orderline where OLid=ohid),0)*100,2),0) as [Invoiced %],
(select uname from uname where unum = OHCreatedBy) as 'Created by',
(select sum(isnull(Olorderqty,0)) from orderline where olid=ohid) AS 'Qty Total Items',
(select sum(isnull(Olshippedqty,0)) from orderline where olid=ohid) AS 'Qty Consigned',
(select sum(isnull(olPOqty,0)) from orderline where olid=ohid) AS 'Qty Reserved'

From Orderhead
left JOIN site on ohsitenum=ssitenum
left join area on aarea=sarea

 group by OHid,aareadesc,OHorderdate,OHUserStatus,OHCreatedBy,OHInvoiceNumber
