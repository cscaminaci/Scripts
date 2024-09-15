select faultid as [Change ID]
	, Symptom as [Summary]
	, (select tstatusdesc from TSTATUS where tstatus=status) as [Status]
	, (select fvalue from lookup where fchangestatus=fcode and fid = 14) as [Approval Status]
	, dateoccured as [Date logged]
	, username as [User]
from FAULTS where Requesttype=2 and fdeleted = 0 and FMergedIntoFaultid = 0 

