select

id1.IDIHID as [Invoice No],

concat(AAccountsFirstName,' ',AAccountsLastName) as [Accounts Name],

aareadesc as [Client Name],
aaccountsid as [Accounts ID],
Convert(nvarchar(10),IHInvoice_Date,103) as [Invoice Date],

case 
when id1.IDrecurringInvoiceLineId>0 and id2.IDgroupID>0 then id2.IDItem_ShortDescription + ' - ' + id1.IDItem_ShortDescription
when id1.IDrecurringInvoiceLineId>0 and id1.IDgroupID=0 then id1.IDItem_ShortDescription
else id1.IDItem_ShortDescription
end as [Order Line - Description],

case 
when id1.IDFaultid>0 then id1.IDQty_Order 
when id1.IDrecurringInvoiceLineId>0 then id1.IDQty_Order
else id1.IDQty_Order
end as [Order Line - Count],

cast(id1.idUnit_price as money) as [Order Line - Unit Price],
cast(id1.idtax_amount as money) as [Total Tax],

cast((((id1.idUnit_price) * (id1.IDQty_Order))  + id1.idtax_amount

) as money) as [Sum]

from invoiceheader

left join invoicedetail id1 on id1.IDIHid=IHid
left join area on ihaarea=aarea
left join site on IHsitenumber=sarea
left join faults on id1.IDfaultid=faultid
left join actions on actions.faultid=faults.faultid
Left join uname on assignedtoint=unum
left join users on IHuid=uid
left join item on iid=id1.idid
left join invoicedetail id2 on id2.idgroupid=id1.idgroupid and id2.idisgroupdesc=1 and id1.idihid=id2.idihid
where IHisRecurringInvoice=0 and IHInvoice_Date between @startdate and @enddate and id1.IDisgroupdesc = 0
group by id1.idtax_amount,id1.IDgroupid,id1.IDID,id1.IDIHID,id1.IDrecurringinvoicelineid,ihid,faults.faultid,username,AAccountsFirstName,AAccountsLastName,aareadesc,aaccountsid,IHInvoice_Date,id1.IDFaultid,id1.IDItem_ShortDescription,Symptom,id1.IDQty_Order, dateoccured,uname,id1.IDUnit_Price, id2.IDItem_ShortDescription, id2.idgroupid, id1.IDNominal_Code
