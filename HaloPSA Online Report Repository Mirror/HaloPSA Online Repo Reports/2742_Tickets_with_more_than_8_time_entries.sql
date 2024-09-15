select * from 
(SELECT distinct 
	faults.faultid AS [Ticket ID],
        symptom AS [Summary], 
uname as [Agent], 
round(sum(timetaken),2) as [Time Taken],
count(actoutcome) as [Action Count]
FROM
    faults
LEFT JOIN actions ON actions.Faultid = faults.faultid
left join uname on unum=assignedtoint
WHERE
	dateoccured > @startdate AND
	Dateoccured < @enddate and status<>9 and fdeleted=fmergedintofaultid and timetaken>0
group by faults.faultid,symptom,uname)a 
where [Action Count]>8
