SELECT
	  [Customer]
	, [Ticket ID]
	, [Ticket Type]
	, [Opportunity ID]
	, [Date Created]
	, cast(sum([Charge Rate]*[TimeSpent]) as money) as [Billable Labour to Date]
	, cast(sum([Invoiced Labor]) as money) as [Invoiced Labour]
	, cast(sum([Labour Cost]) as money) as [Total Labour Cost]
	, [Billable Items to Date]
	, [Item Cost to Date]
	, [Amount Invoiced on Items]
	, cast(sum([Charge Rate]*[TimeSpent]) + [Billable Items to Date] + [Quoted Amount] as money) as [Total Billable]
	, cast(sum([Labour Cost]) + [Item Cost to Date] + [Quoted Cost] as money) as [Total Cost]
	, [Quoted Amount]
	, [Quoted Cost]
	, [Invoiced From SO] 
	, cast(sum([Invoiced Labor]) + [Amount Invoiced on Items] + [Invoiced From SO] as money) as [Total Invoiced]
FROM(
	SELECT
		  (SELECT aareadesc FROM area WHERE aarea = areaint) as 'Customer'
		, faults.faultid as 'Ticket ID'
		, fxrefto as 'Opportunity ID'
		, dateoccured as 'Date Created'
		, (SELECT rtdesc FROM requesttype WHERE rtid = requesttypenew) as 'Ticket Type'
		, CASE
			 WHEN actionbillingplanid < -9 THEN 0
			 WHEN ActionBillingPlanID = -1 then 0
			 WHEN actioncode + 1 IN (SELECT TOP 1 crchargeid
									 FROM   chargerate)
				  AND (SELECT areaint
					   FROM   faults
					   WHERE  faults.faultid = actions.faultid) = (SELECT TOP 1 crarea
																   FROM   chargerate
																   WHERE  crarea =
																  (SELECT areaint
																   FROM   faults
																   WHERE
					  faults.faultid = actions.faultid)
					  AND crchargeid =
						  actioncode + 1) THEN cast((SELECT TOP 1 crrate
												FROM   chargerate
												WHERE
			 ( crchargeid - 1 ) = actioncode
			 AND crarea = (SELECT areaint
						   FROM   faults
						   WHERE
		   actions.faultid = faults.faultid)) as nvarchar(255))
			 ELSE cast((SELECT TOP 1 crrate
				   FROM   chargerate
				   WHERE  ( crchargeid - 1 ) = actioncode
						  AND crarea = 0) as nvarchar(255))
		   END                                           AS 'Charge Rate'
		, ActionChargeHours
		, timetaken + timetakenAdjusted as 'TimeSpent'
		, cast((SELECT isnull(ucostprice,0) FROM uname WHERE actionbyunum = unum)*timetaken as money) as [Labour Cost]
		, (SELECT cast(sum(flsellingprice*florderqty) as money) FROM faultitem WHERE faults.faultid = flid) as [Billable Items to Date]
		, (SELECT cast(sum(FLCostPrice*florderqty) as money) FROM faultitem WHERE faults.faultid = flid) as [Item Cost to Date]
		, (SELECT cast(sum(idnet_amount) as money) FROM invoicedetail JOIN invoiceheader on idihid = ihid JOIN faultitem on flstatus = ihid and flid = faults.faultid) as [Amount Invoiced on Items]
		, (SELECT cast(sum(idnet_amount) as money) FROM INVOICEDETAIL WHERE IDFaultid = ActionInvoiceNumber) as [Invoiced Labor]
		, (SELECT cast(sum(QDPrice*QDQuantity) as money) FROM QUOTATIONDETAIL JOIN QUOTATIONHEADER on qhid = QDQHid WHERE qhfaultid = nullif(fxrefto,0)) as [Quoted Amount]
		, (SELECT cast(sum(QDCostPrice*QDQuantity) as money) FROM QUOTATIONDETAIL JOIN QUOTATIONHEADER on qhid = QDQHid WHERE qhfaultid = nullif(fxrefto,0)) as [Quoted Cost]
		, (SELECT cast(sum(idnet_amount) as money) FROM INVOICEDETAIL JOIN INVOICEHEADER on IdIHid = ihid JOIN ORDERHEAD on ohid = IHOHid WHERE nullif(fxrefto,0) = OHfaultid) as [Invoiced From SO] 
	FROM faults
	JOIN actions ON faults.faultid = actions.faultid)j
GROUP BY [Customer], [Ticket ID], [Date Created], [Billable Items to Date], [Item Cost to Date], [Quoted Amount], [Invoiced From SO], [Opportunity ID], [Amount Invoiced on Items], [Ticket Type], [Quoted Cost]

