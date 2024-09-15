select
 idihid [Recurring Invoice ID]
, idid [idid] 
, IDItem_ShortDescription [Description]
, case 
    when IDRecurringInvoiceQuantityType=2
              then (select 
                count(distinct(uid)) 
                from InvoiceDetailQuantity  
                join users on ((idqsiteid> 0 and idqsiteid=usite) or (idqsiteid=0 and usite in (select ssitenum from site where sarea = (select ihaarea from invoiceheader where ihid=idihid)))) 
                and users.uinactive=0 
                and users.uisserviceaccount=0 
                and uusername <> 'General User' 
                and idid=idqidid)
       when IDRecurringInvoiceQuantityType=3 
              then (select 
                count(distinct (did)) 
                from InvoiceDetailQuantity 
                left join device on Dtype=IDQTypeId or IDQTypeId=0
                left join InvoiceDetailQuantityCriteria on IDQCIDQID=IDQID 
                left join deviceinfo on inum=did 
                left join typeinfo on xseq=iseq and xnum=dtype 
                left join field on xfieldnos=yseq
                where (idqsiteid=dsite or (idqsiteid = 0 and dsite in (select ssitenum from site where sarea =(select ihaarea from invoiceheader where ihid=idihid)))) 
                and dinactive=0 
                and idid=idqidid)
            
       when IDRecurringInvoiceQuantityType in (1,4)
              then (select 
                sum(LCount) 
                from InvoiceDetailQuantity 
                join Licence on lid=IDQLicenceId 
                where idid=idqidid)
else idQty_Order end [Quantity]

from invoicedetail
where idihid < 0
