select *
,cast([Unit Price] * [Quantity] as money) as [Net Price]
,cast((case
when stdperiod= 1 then cast([Unit Price] * [Quantity] as money)*52
when stdperiod= 2 then cast([Unit Price] * [Quantity] as money)*12
when stdperiod= 4 then cast([Unit Price] * [Quantity] as money)*4
when stdperiod= 5 then cast([Unit Price] * [Quantity] as money)*2
when stdperiod= 3 then cast([Unit Price] * [Quantity] as money)*1
when stdperiod= 8 then cast([Unit Price] * [Quantity] as money)*0.5
END) as money) as [Yearly Net Price]
from(

select 
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
case 
	when IDRecurringInvoiceQuantityType=3 
		then (select count(distinct did) from InvoiceDetailQuantity left join device on Dtype=IDQTypeId or IDQTypeId=0 where dsite in (select ssitenum from site where sarea = IHaarea) and idid=idqidid and idqkind=IDRecurringInvoiceQuantityType)
	when IDRecurringInvoiceQuantityType in(1,4)
		then (select sum(LCount) from InvoiceDetailQuantity join Licence on lid=IDQLicenceId where idid=idqidid)
else idqty_order end as [Quantity],
cast(idunit_price as money) as [Unit Price],
stdperiod
from invoicedetail
join invoiceheader on ihid=idihid 
join area on ihaarea=aarea
left join item on iid=id_itemid
left join generic on ggeneric=igeneric
left join STDREQUEST on ihid=stdinvoiceid
join control2 on 1=1
where ihid<0
)d

