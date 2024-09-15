select (select aareadesc from area where aarea=charea) as [Client]
, CHcontractRef as [Reference]
, CHStartDate as [Start Date]
, CHenddate as [End Date]
, DATEDIFF(DD,GETUTCDATE(),CHEndDate) as [Expires In (Days)]
from ContractHeader 
where CHEndDate<=DATEADD(MM,6,GETUTCDATE()) and CHenddate>GETUTCDATE()
