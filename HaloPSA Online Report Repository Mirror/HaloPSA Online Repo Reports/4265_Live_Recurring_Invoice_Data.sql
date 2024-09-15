select *
, case when Quantity2 <0 then 0 else [Quantity2] end as [Quantity] from 
(select
 case 
when IDRecurringInvoiceQuantityType = 3 and Assets < [Min Qty] then [Min Qty] 
when IDRecurringInvoiceQuantityType = 3 and Assets >= [Min Qty] and Assets>0 then Assets 
when IDRecurringInvoiceQuantityType = 3 and Assets2 < [Min Qty] then [Min Qty] 
when IDRecurringInvoiceQuantityType = 3 and Assets2 >= [Min Qty] then Assets2

when IDRecurringInvoiceQuantityType = 2 and [Users] < [Min Qty] then [Min Qty] 
when IDRecurringInvoiceQuantityType = 2 and [Users] >= [Min Qty] and [Users]>0 then [Users] 

when IDRecurringInvoiceQuantityType in (1,4) and [License/Subscription] < [Min Qty] then [Min Qty] 
when IDRecurringInvoiceQuantityType in (1,4) and [License/Subscription] >= [Min Qty] and [License/Subscription]>0 then [License/Subscription] 


else idqty_order

end - [Free] [Quantity2] 

,*
from(

select 
idid as [Line Item ID],
ihid as [Recurring Invoice ID],
aareadesc as [Customer Name],
stdnextcreationdate as [Next Invoice Creation],
case
when stdperiod= 1 then 'Weekly'
when stdperiod= 2 then 'Monthly'
when stdperiod= 4 then 'Quarterly'
when stdperiod= 5 then '6-Monthly'
when stdperiod= 3 then 'Yearly'
when stdperiod= 8 then '2 Yearly'
END as [Period],
case when ihprorataperiodsahead = 0  then 'Previous Period'
when ihprorataperiodsahead = 1  then 'Current Period'
when ihprorataperiodsahead = 2  then 'Next Period'
when rprorataperiodsahead = 0  then 'Previous Period'
when rprorataperiodsahead = 1  then 'Current Period'
when rprorataperiodsahead = 2  then 'Next Period'
else 'Previous Period' end as [Relative Period],
iditem_shortdescription as [Line Description],
gdesc as [Item Group],


(select count(did) from device join site on dsite=ssitenum and sarea=aarea join invoicedetailquantity on idid=idqidid and dtype=idqtypeid and dinactive=0 ) [Assets],
(select count(distinct did) from InvoiceDetailQuantity left join device on Dtype=IDQTypeId or IDQTypeId=0 where dsite in (select ssitenum from site where sarea = IHaarea) and idid=idqidid and idqkind=IDRecurringInvoiceQuantityType) [Assets2],
(select count(distinct(uid)) from InvoiceDetailQuantity  join users on ((idqsiteid> 0 and idqsiteid=usite) or (idqsiteid=0 and  usite in (select ssitenum from site where sarea = IHaarea))) and users.uinactive=0 and users.uisserviceaccount=0 and uusername <> 'General User' and idid=idqidid) as [Users],
(select sum(LCount - IDQQtyFree) from InvoiceDetailQuantity join Licence on lid=IDQLicenceId where idid=idqidid) [License/Subscription],
isnull((select sum(idqminimumqty) from invoicedetailquantity where idid=idqidid ),IDQty_Order) [Min Qty],
isnull((select sum(idqqtyfree) from invoicedetailquantity where idid=idqidid ),0) [Free],
cast(idunit_price as money) as [Unit Price],
IDRecurringInvoiceQuantityType,
case when IDRecurringInvoiceQuantityType = 1 then 'Licenses' when IDRecurringInvoiceQuantityType = 2 then 'Users' when IDRecurringInvoiceQuantityType=3 then 'Devices' when IDRecurringInvoiceQuantityType=4 then 'Subscriptions' else 'Manual' end as [Quantity Type],
stdperiod,
idqty_order

from invoicedetail
join invoiceheader on ihid=idihid 
join area on ihaarea=aarea
left join item on iid=id_itemid
left join generic on ggeneric=igeneric
left join STDREQUEST on ihid=stdinvoiceid


join control2 on 1=1
where ihid<0 and IDisGroupDesc='False'
group by IDid, ihid, aareadesc,aarea, STDNextCreationDate, StdPeriod,ihprorataperiodsahead, RProRataPeriodsAhead,IDItem_ShortDescription,gdesc,IDUnit_Price,IDQty_Order,IDRecurringInvoiceQuantityType,IHaarea
)d)e

