SELECT TOP 100
FaultID,
ActionNumber,
ActOutcome,
ActionContractID,
CPContractID,
CHContractRef

FROM Actions
JOIN ContractPlan ON CPID = ActionContractID
JOIN ContractHeader ON CHID = CPContractID
