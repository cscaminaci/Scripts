SELECT 
Faults.fprojectstartdate AS [Ticket Start Date & Time]
, Faults.faultid AS [Ticket ID]
, Area.aareadesc AS [Client Name]
, Faults.symptom AS [Summary]
, mstname as [Milestone Name]
, MSTStartDate as [Milestone Start Date]
, MSTtargetdate as [Milestone Target Date]
, case when mststate=3 then 'Completed'
when mststate=2 then 'In Progress'
when mststate=0 then 'New'
end as [Milestone Status]
FROM Faults
LEFT JOIN Area ON Faults.areaint = Area.aarea
left join milestone on faultid=mstfaultid
LEFT JOIN RequestType ON Faults.requesttypenew = RequestType.rtid
WHERE 1=1
 AND (RequestType.rtdesc IN ('zzzz','Project'))

