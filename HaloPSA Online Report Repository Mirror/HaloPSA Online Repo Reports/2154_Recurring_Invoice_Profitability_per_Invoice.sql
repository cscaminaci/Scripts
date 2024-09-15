select 
[Customer],[Recurring Invoice ID],[Next Invoice Date],[Previous Invoice Date],[Billing Period],sum([Net Price]) as [Net Price],sum( [Net Cost]) as [Net Cost], sum([Profit]) as [Profit] from

(
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
IDQty_Order as [Quantity],
IDUnit_Price as [Price (unit)],
IDNet_Amount as [Net Price],
icostprice as [Cost (unit)],
round(icostprice*IDQty_Order,2) as [Net Cost],
round(IDUnit_Price -icostprice,2)  as [Profit (unit)],
round((IDNet_Amount -icostprice*IDQty_Order),2) as [Profit]

from area
join invoiceheader on aarea=ihaarea
join invoicedetail on ihid=idihid
join STDREQUEST on ihid=StdInvoiceId
left join item on iid=id_itemid

where ihid<0)b
group by 
[Customer],[Recurring Invoice ID],[Next Invoice Date],[Previous Invoice Date],[Billing Period]
