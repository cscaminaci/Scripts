select (select aareadesc from area where amarea=aarea) as [Client]
	, amDesc as [Item Description]
	, case	when ambillingperiod=1 then 'Weekly'
				when ambillingperiod=2 then 'Monthly'
					when ambillingperiod=3 then 'Yearly'
						when ambillingperiod=4 then 'Quarterly'
							when ambillingperiod=8 then '2-Yearly'
								when ambillingperiod=7 then '3-Yearly'
									when ambillingperiod=9 then '4-Yearly'
								else '5-Yearly' end as [Billing Period]
	, convert(date,amstartdate) as [Start Date]
	, convert(date,amlastinvoicedate) as [Last Invoiced]
	, convert(date,amnextbillingdate) as [Next invoice]
	, amsellingprice as [Selling Price]
	, (select fvalue from lookup where fid=58 and fcode=ambillingcategory) as [Billing Category]
	, case when amautorenew=1 then 'Yes'
			else 'No' end as [Auto Renew]

from areaitem


