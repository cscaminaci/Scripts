select faultid as [Ticket ID],
(select aareadesc from area where aarea=areaint) as [Client],
datecleared as [Date Closed],
dateoccured as [Date Opened],
symptom as [Subject],
(select sum(isnull(timetaken,0)+isnull(timetakenadjusted,0)) from actions where actions.faultid=faults.faultid) 
as [Total Time (Decimal Hrs)],
(Select tstatusdesc from tstatus where tstatus=status) as [Status]
from faults                  
                                                  

                                                         

                                                   

