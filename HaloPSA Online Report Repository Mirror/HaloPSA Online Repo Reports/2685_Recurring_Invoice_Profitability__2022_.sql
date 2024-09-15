SELECT
	  *
	, [Total Sold on Invoice] - [Total Cost on Invoice] - [Agreement Cost per Period] as 'Invoice Profitability'
FROM(	
	SELECT
		  aareadesc as 'Client'
		, IHID as 'Invoice ID'
		, STDNextCreationDate as 'Next Creation Date'
		, sum(IDNet_Amount) as [Total Sold on Invoice]
		, sum(idunit_cost*IDQty_Order) as [Total Cost on Invoice]
		, CHCostPerPeriod as [Agreement Cost per Period]
		, CASE
			when stdperiod= 1 then 'Weekly'
			when stdperiod= 2 then 'Monthly'
			when stdperiod= 4 then 'Quarterly'
			when stdperiod= 5 then '6-Monthly'
			when stdperiod= 3 then 'Yearly'
			when stdperiod= 8 then '2 Yearly'
		  END as [Period]
	FROM INVOICEHEADER
	JOIN INVOICEDETAIL on IHID = IdIHid
	JOIN area on aarea = IHaarea
	JOIN STDREQUEST ON ihid = StdInvoiceId
	LEFT JOIN CONTRACTHEADER on chid = IHchid
	GROUP BY aareadesc, ihid, STDNextCreationDate, CHCostPerPeriod, StdPeriod)j
