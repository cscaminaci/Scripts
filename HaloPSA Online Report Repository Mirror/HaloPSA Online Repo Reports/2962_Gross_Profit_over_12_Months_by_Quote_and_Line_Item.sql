select
	  qhid as 'Quote ID'
	, QHDate as [Quote Date]
	, qhfaultid as [Ticket ID]
	, QDPrice as [Unit Price]
	, (SELECT fvalue FROM lookup WHERE fid = 39 AND qhstatus =fcode) as [Status]
	, QDCostPrice as [Unit Cost]
	, QDQuantity as [Quantity]
	, aareadesc as [Client]
	, uname as [Assigned Salesperson]
	, cast(isnull(round(sum(QDQuantity*QDPrice),2),0) as money) as [Total Price]
	, CASE WHEN QDBillingPeriod = 0 THEN 'One Off'
		   WHEN QDBillingPeriod = 1 THEN 'Weekly'
		   WHEN QDBillingPeriod = 2 THEN 'Monthly'
		   WHEN QDBillingPeriod = 4 THEN 'Quarterly'
		   WHEN QDBillingPeriod = 5 THEN '6-Monthly'
		   WHEN QDBillingPeriod = 3 THEN 'Yearly'
		   WHEN QDBillingPeriod = 8 THEN '2-Yearly'
		   WHEN QDBillingPeriod = 7 THEN '3-Yearly'
		   WHEN QDBillingPeriod = 9 THEN '4-Yearly'
		   WHEN QDBillingPeriod = 6 THEN '5-Yearly'
	  END as 'Billing Period'
	, CASE WHEN QDBillingPeriod = 0 THEN cast(isnull(round(sum(QDQuantity*QDPrice),2),0) as money)
		   WHEN QDBillingPeriod = 1 THEN cast(isnull(round(52 * sum(QDQuantity*QDPrice),2),0) as money)
		   WHEN QDBillingPeriod = 2 THEN cast(isnull(round(12 * sum(QDQuantity*QDPrice),2),0) as money)
		   WHEN QDBillingPeriod = 4 THEN cast(isnull(round( 3 * sum(QDQuantity*QDPrice),2),0) as money)
		   WHEN QDBillingPeriod = 5 THEN cast(isnull(round( 2 * sum(QDQuantity*QDPrice),2),0) as money)
		   WHEN QDBillingPeriod = 3 THEN cast(isnull(round(sum(QDQuantity*QDPrice),2),0) as money)
		   WHEN QDBillingPeriod = 8 THEN cast(isnull(round(sum(QDQuantity*QDPrice)/2,2),0) as money)
		   WHEN QDBillingPeriod = 7 THEN cast(isnull(round(sum(QDQuantity*QDPrice)/3,2),0) as money)
		   WHEN QDBillingPeriod = 9 THEN cast(isnull(round(sum(QDQuantity*QDPrice)/4,2),0) as money)
		   WHEN QDBillingPeriod = 6 THEN cast(isnull(round(sum(QDQuantity*QDPrice)/5,2),0) as money)
	  END AS 'Price over 12 Months'
	, cast(isnull(round(sum(QDQuantity*qdcostprice),2),0) as money) as [Total Cost]
	, cast(isnull(round(sum(QDQuantity*QDPrice) - sum(QDQuantity*qdcostprice),2),0) as money) as [Total GP]
	, CASE WHEN QDBillingPeriod = 0 THEN cast(isnull(sum(QDQuantity*QDPrice),0) - isnull(sum(QDQuantity*qdcostprice),0) as money)
		   WHEN QDBillingPeriod = 1 THEN cast(isnull(52 * sum(QDQuantity*QDPrice),0) - isnull(52 * sum(QDQuantity*qdcostprice),0) as money)
		   WHEN QDBillingPeriod = 2 THEN cast(isnull(12 * sum(QDQuantity*QDPrice),0) - isnull(12 * sum(QDQuantity*qdcostprice),0) as money)
		   WHEN QDBillingPeriod = 4 THEN cast(isnull(3 * sum(QDQuantity*QDPrice),0) - isnull(3 * sum(QDQuantity*qdcostprice),0) as money)
		   WHEN QDBillingPeriod = 5 THEN cast(isnull(2 * sum(QDQuantity*QDPrice),0) - isnull(2 * sum(QDQuantity*qdcostprice),0) as money)
		   WHEN QDBillingPeriod = 3 THEN cast(isnull(sum(QDQuantity*QDPrice),0) - isnull(sum(QDQuantity*qdcostprice),0) as money)
		   WHEN QDBillingPeriod = 8 THEN cast(isnull(sum(QDQuantity*QDPrice)/2,0) - isnull(sum(QDQuantity*qdcostprice)/2,0) as money)
		   WHEN QDBillingPeriod = 7 THEN cast(isnull(sum(QDQuantity*QDPrice)/3,0) - isnull(sum(QDQuantity*qdcostprice)/3,0) as money)
		   WHEN QDBillingPeriod = 9 THEN cast(isnull(sum(QDQuantity*QDPrice)/4,0) - isnull(sum(QDQuantity*qdcostprice)/4,0) as money)
		   WHEN QDBillingPeriod = 6 THEN cast(isnull(sum(QDQuantity*QDPrice)/5,0) - isnull(sum(QDQuantity*qdcostprice)/5,0) as money)
	  END AS 'GP over 12 Months'
	, qhtitle as [Quote Reference]
	, datecleared as [Date Opp was closed]
	, QHApprovalDateTime as 'Approval Date'
	, uusername as 'User'
from QUOTATIONHEADER
LEFT join faults on qhfaultid=faultid
join QUOTATIONDETAIL on qhid=qdqhid
JOIN users on uid = QHUserID
LEFT JOIN site on usite = Ssitenum
LEFT JOIN area on aarea = sarea
LEFT JOIN uname on unum = Assignedtoint
GROUP BY QHDate, QHfaultID, QDPrice, QHstatus, QDCostPrice, QDQuantity, aareadesc, uname, QHtitle, datecleared, QHApprovalDateTime, uusername, QDBillingPeriod, qhid

