SELECT aareadesc AS [Area]
	,chstartdate AS [Start Date]
	,chenddate AS [End Date]
	,CHNumberofUnitsFree AS [Hours]
	,CHNumberofUnitsFree-(Select sum(timetaken) from actions where actionbillingplanid in (select cpid from contractplan where cpcontractid=CHid) and whe_ between CHstartdate and CHenddate) as [Hours Remaining]
	,CASE 
		WHEN CHBillingPeriod = 1
			THEN 'Weekly'
		WHEN CHBillingPeriod = 2
			THEN 'Monthly'
		WHEN CHBillingPeriod = 3
			THEN 'Yearly'
		WHEN CHBillingPeriod = 4
			THEN 'Quarterly'
		WHEN CHBillingPeriod = 5
			THEN '6-Monthly'
		WHEN CHBillingPeriod = 6
			THEN '5-Yearly'
		WHEN CHBillingPeriod = 7
			THEN '3-Yearly'
		WHEN CHBillingPeriod = 8
			THEN '2-Yearly'
		WHEN CHBillingPeriod = 9
			THEN '4-Yearly'
		ELSE 'Weekly'
		END AS [Billing Period]
	,CHChargeHoursPerPeriod AS [Charge per Period]
	,CHPeriodicInvoiceNextDate AS [Date of Next Invoice]
	,CHcontractRef AS [Contract Reference]
	,chinvoicedescription AS [Invoice Description]
	,(
		SELECT fvalue
		FROM lookup
		WHERE fid = 28
			AND fcode = (chbillingdescription)
		) AS [Billing Description]
	,chnote AS [Notes]
	,CASE 
		WHEN chenddate > getdate()
			AND chstartdate < getdate()
			THEN 'Live'
		ELSE 'Expired'
		END AS 'Status'
FROM contractheader
JOIN area ON charea = aarea
