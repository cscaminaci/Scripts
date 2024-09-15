SELECT TOP 100 percent 
	  ihid as 'Invoice ID'
	, CASE WHEN IHXeroID > 0 THEN IHXeroID
		   WHEN IHQBOId > 0 THEN IHQBOId
		   WHEN IHKashflowId > 0 THEN IHKashflowId
		   ELSE ''
	  END as '3rd Party Invoice Number'
	, aareadesc as 'Client'
	, IHInvoice_Date as 'Invoice Date'
	, round(sum(IDNet_Amount),2) as 'Invoice Total'
	, ihdatepaid as 'Date Paid'
	, IHAmountPaid as 'Amount Paid'
	, CASE WHEN IHAmountPaid = 0 THEN round(sum(IDNet_Amount),2)
		   ELSE IHAmountDue
	  END AS 'Amount Due'
	, cast(IHDue_Date as date) as 'Due Date'
	, CASE WHEN IHAmountPaid < round(sum(IDNet_Amount),2) THEN  cast(datediff(day, getdate(), IHDue_Date) as nvarchar)
	       ELSE 'Paid'
	  END AS 'Days Overdue'
FROM INVOICEHEADER
JOIN INVOICEDETAIL on ihid = idihid
JOIN area on aarea = IHaarea
WHERE ihid > 0 
GROUP BY ihid, aareadesc, IHInvoice_Date, ihdatepaid, IHAmountPaid, IHAmountDue, IHDue_Date, IHXeroID, IHQBOId, IHKashflowId

