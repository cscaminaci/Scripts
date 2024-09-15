select Faultid as [Ticket Number]
	  , sectio_ as [Section]
	  , symptom as [Subject] 
	  , (select aareadesc from AREA where Aarea= Areaint ) as [Client Name]
	  , username as [User]
	  , (select tstatusdesc from TSTATUS where Status= Tstatus) as [Status]
	  , dateoccured as [Date Logged]
from faults where Assignedtoint=1 and Status <> 9


