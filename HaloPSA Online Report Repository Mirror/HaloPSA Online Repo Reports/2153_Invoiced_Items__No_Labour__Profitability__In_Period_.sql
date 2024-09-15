select *, round([Cost (unit)]*[Quantity],2) as [Cost] , round([Sales Price]- ([Cost (unit)]*[Quantity]),2) as [Profit] from
(
	SELECT idihid AS [Invoice Number]
,ihinvoice_date as [Invoice Date]

		,IDItem_ShortDescription AS [Item]
,IDQty_Order AS [Quantity]
,case when idrecurringinvoiceid<0 then 'Recurring Invoice'
when idolid>0 then 'Sale Order'
when id_itemid>0 and idfaultid>0 then 'Item on Ticket'
else 'Other' end as [Line Type]
		,
case when idolid>0 then (select olcostprice from orderline where olid=idolid and olseq=idolseq)
when id_itemid>0 then
(SELECT icostprice
			FROM item
			WHERE id_itemid= iid
			) 
else 0 
end AS [Cost (unit)]
		,IDUnit_Price AS [Sales Price (unit)]
,idnet_amount as [Sales Price]
		
	FROM InvoiceDetail 
join invoiceheader on ihid=idihid
where (id_itemid>0 or idrecurringinvoiceid<0) and ihid>0)b
	

