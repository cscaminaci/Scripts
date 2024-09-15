SELECT
	  isnull(idesc, '**Generic Product**') as 'Item'
	, round(sum(IDQty_Order),2) as 'Total Ordered'
	, round(sum(IDNet_Amount),2) as 'Total Value'
	, count(ihid) as 'Number of Invoices with this product'
FROM invoicedetail
LEFT JOIN item on ID_ItemID = iid
LEFT JOIN invoiceheader on ihid = idihid
WHERE IdIHid > 0
  AND ihinvoice_date BETWEEN @startdate AND @enddate
GROUP BY idesc
