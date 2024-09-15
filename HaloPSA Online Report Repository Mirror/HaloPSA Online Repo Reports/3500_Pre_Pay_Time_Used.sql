SELECT
(SELECT AAreaDesc FROM Area WHERE AreaInt=AArea) AS [Customer],
Faults.FaultID AS [Ticket ID],
DateOccured AS [Date Created],
DateCleared AS [Date Closed],
(SELECT TStatusDesc FROM TStatus WHERE Status=TStatus) AS [Status],
Symptom AS [Description],
Who AS [Technician],
CAST(Clearance AS VARCHAR(MAX)) AS [Resolution],
UName AS [Assigned Technician],
actionbillingplanid as [Billing Plan Combination],
ROUND(TimeTaken, 2) AS [Hours Worked],
whe_ as [Action Date],
actionprepayamount as [Pre-Pay Amount Used],
(SELECT FValue FROM LookUp WHERE FId=17 AND FCode=ActionCode+1) AS [Charge Rate],
CHContractRef AS [Contract]

FROM Faults
JOIN Actions ON Actions.FaultID=Faults.FaultID
JOIN UName ON AssignedToInt = UNum
JOIN ContractHeader ON ActionContractID = CHID 

WHERE actionprepayamount IS NOT NULL AND ActionContractID <> 0
