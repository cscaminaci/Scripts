select [Customer],
cast(sum([Net Price]) as money) as [Net Price],
cast(sum([Net Cost]) as money) as[Net Cost], 
cast(sum([Profit]) as money) as [Profit] 
from(
select 
[Customer],
case when [Billing Period]='Yearly' then sum([Net Price]/12)
when [Billing Period]='Quarterly' then sum([Net Price]/3)
else sum([Net Price])
end as [Net Price],
case when [Billing Period]='Yearly' then sum([Net Cost]/12)
when [Billing Period]='Quarterly' then sum([Net Cost]/3)
else sum([Net Cost])
end as [Net Cost], 
case when [Billing Period]='Yearly' then sum([Profit]/12) 
when [Billing Period]='Quarterly' then sum([Profit]/3)
else sum([Profit])
end as [Profit] 
from

(

select *,
[Cost (unit)]*[Quantity] as [Net Cost],
[Price (unit)] -[Cost (unit)]  as [Profit (unit)],
(([Price (unit)] -[Cost (unit)])*[Quantity]) as [Profit],
([Price (unit)]*[Quantity]) as [Net Price]
from (
select aareadesc as [Customer],
ihid as [Recurring Invoice ID],
stdnextcreationdate as [Next Invoice Date],
stdlastcreated as [Previous Invoice Date],
 case	when stdperiod=1 then 'Weekly'
				when stdperiod=2 then 'Monthly'
					when stdperiod=3 then 'Yearly'
						when stdperiod=4 then 'Quarterly'
							when stdperiod=8 then '2-Yearly'
								when stdperiod=7 then '3-Yearly'
									when stdperiod=9 then '4-Yearly'
								else '5-Yearly' end as [Billing Period],
IDItem_ShortDescription as [Invoice Line Item],
IDesc as [Item Name],
ID_ItemID as [Item ID],
case 
	when IDRecurringInvoiceQuantityType=3 
		then (select count(distinct did) from InvoiceDetailQuantity left join device on Dtype=IDQTypeId or IDQTypeId=0 where dsite in (select ssitenum from site where sarea = IHaarea) and idid=idqidid and dinactive=0)
	when IDRecurringInvoiceQuantityType in(1,4)
		then (select sum(LCount) from InvoiceDetailQuantity join Licence on lid=IDQLicenceId where idid=idqidid)
else idqty_order end as [Quantity],
IDUnit_Price as [Price (unit)],
icostprice as [Cost (unit)]


from area
join invoiceheader on aarea=ihaarea
join invoicedetail on ihid=idihid
join STDREQUEST on ihid=StdInvoiceId
left join item on iid=id_itemid

where ihid<0)d)b
group by 
[Customer],[Billing Period])a
group by [Customer]
