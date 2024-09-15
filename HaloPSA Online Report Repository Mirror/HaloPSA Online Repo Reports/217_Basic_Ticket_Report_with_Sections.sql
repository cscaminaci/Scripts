select faultid as TicketID, Symptom as Subject,sectio_ as Section, (select uname from uname where unum=assignedtoint)Technician, 
(select aareadesc from area where aarea=areaint)Client, (select sdesc from site where ssitenum=sitenumber)Site, 
Username, dateOccured as DateOccurred, (select tstatusdesc from tstatus where tstatus=status)Status, (select 
sum(isnull(timetaken,0)+isnull(timetakenadjusted,0)) from actions where actions.faultid=faults.faultid)TimeTaken 
 from faults where fdeleted=0



