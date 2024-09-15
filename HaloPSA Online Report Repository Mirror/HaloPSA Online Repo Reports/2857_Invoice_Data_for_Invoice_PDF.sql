select IDItem_ShortDescription as [Description],
case when idisgroupdesc=1 then '' else IDItem_longDescription end as [LongDescription],
 case when idisgroupdesc=1 then null else IDQty_Order end as [Quantity],
 case when ID_ItemID>0 then 'Product/Service' when IDActionCode>0 then 'Labour' else 'Other' end as [Grouping],
case when idisgroupdesc=1 then round((select sum(a.IDNet_Amount) from invoicedetail a where a.idihid=invoicedetail.idihid and a.idgroupid=invoicedetail.idgroupid and a.idisgroupdesc=0),2) else IDNet_Amount end as [Price],
case when idisgroupdesc=1 then 'group' else 'line' end as [Type]
 from invoicedetail where idihid=$invoiceid 
