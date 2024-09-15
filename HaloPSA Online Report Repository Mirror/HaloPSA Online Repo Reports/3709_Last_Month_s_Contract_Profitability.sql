SELECT 
[Client],
[Contract],
[Contract ID],
[Contract Type],
[Date],
[Contract Price per Period],
ROUND(SUM([Invoice Total Cost]),2) AS [Cost on Invoice],
ROUND(SUM([Invoice Total Price]),2) AS [Total Invoiced],
ROUND(SUM([Invoice Total Price]) + [Contract Price per Period] - SUM([Invoice Total Cost]), 2) AS [Invoice Profitability],
CAST(ROUND(((SUM([Invoice Total Price]) + [Contract Price per Period] - SUM([Invoice Total Cost])) / SUM([Invoice Total Price])) * 100, 2) AS VARCHAR) + '%' AS [Gross Margin],
ROUND(SUM(ISNULL([Labour Hours],0)) / COUNT([Invoice ID]), 2) AS [Labour Hours],
ROUND((SUM([Invoice Total Price]) + [Contract Price per Period] - SUM([Invoice Total Cost])) / IIF((ROUND(SUM([Labour Hours]) / COUNT([Invoice ID]), 2)) = 0, NULL, (ROUND(SUM([Labour Hours]) / COUNT([Invoice ID]), 2))), 2) [Profitability by Labour Hours]

FROM




(SELECT
AAreaDesc AS [Client],
CHContractRef AS [Contract],
CHID AS [Contract ID],
(SELECT FValue FROM Lookup WHERE FID = 28 AND FCode = CHBillingDescription) AS [Contract Type],
CHCostPerPeriod AS [Contract Price per Period],
IHID AS [Invoice ID],
CONVERT(Date,IHInvoice_Date) AS [Date],
SUM(IDNet_Amount) AS [Invoice Total Price],
SUM(IDUnit_Cost * IDQty_Order) AS [Invoice Total Cost],
ROUND((SELECT SUM(ISNULL(ActionNonChargeHours,0)) FROM Actions WHERE ActionContractID IS NOT NULL AND ActionContractID <> 0 AND (SELECT AreaInt FROM Faults WHERE Actions.FaultID = Faults.FaultID) = AArea AND
		WhoAgentID IN (SELECT USUNum FROM UNameSection WHERE USSection  LIKE '%%') AND /*Specify the team name you would like to filter by here. Leave alone for all.*/
		IIF(datepart(month,getdate())=1, datepart(year,getdate())-1,datepart(year,getdate())) = datepart(year,Whe_) and datepart(month,getdate()) - 1 = IIF(datepart(month,Whe_)=1,12,datepart(month,Whe_))),2) AS [Labour Hours]

FROM ContractHeader
JOIN Area ON AArea = CHArea
JOIN InvoiceHeader ON CHID = IHCHID
JOIN InvoiceDetail ON IHID = IDIHID

WHERE (SELECT FValue FROM Lookup WHERE FID = 28 AND FCode = CHBillingDescription) LIKE '%%' /*Specify the Billing Description you would like to filter by here. Leave alone for all.*/
AND IHID > 0
AND DATEPART(Month,IHInvoice_Date) = DATEPART(Month,GETDATE())
AND DATEPART(Year,IHInvoice_Date) = DATEPART(Year,GETDATE())

GROUP BY AArea, AAreaDesc, CHContractRef, CHID, CHCostPerPeriod, CHBillingDescription, IHID, IHInvoice_Date)z

GROUP BY [Client], [Contract], [Contract ID], [Contract Type], [Date], [Contract Price per Period]
