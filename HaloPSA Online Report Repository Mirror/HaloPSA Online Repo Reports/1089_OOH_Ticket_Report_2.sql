Select (select aareadesc from area where areaint=Aarea) as [Client]
	,(select sdesc from site where sitenumber=ssitenum) as [Site]
	,Faultid as [Request ID]
	,dateoccured as [Created Date/ Time]
	,Symptom as [Summary]
	,(select uname from uname where Assignedtoint=Unum) as [Assigned To]
	,symptom2 as [Description]
	,(select tstatusdesc from tstatus where status=tstatus) as [Status]
	,(select sum(timetaken) from actions where actions.faultid=faults.faultid) as [Time Taken To Date]
from FAULTS
WHERE dateoccured > @startdate
AND dateoccured < @enddate
AND convert(TIME, dateoccured) < convert(TIME, '07:00:00')
AND convert(DATE, dateoccured) IN (
       SELECT date_id
       FROM calendar
       WHERE weekday_id NOT IN (
                     1
                     ,7
                     )
       )

UNION ALL

Select (select aareadesc from area where areaint=Aarea) as [Client]
	,(select sdesc from site where sitenumber=ssitenum) as [Site]
	,Faultid as [Request ID]
	,dateoccured as [Created Date/ Time]
	,Symptom as [Summary]
	,(select uname from uname where Assignedtoint=Unum) as [Assigned To]
	,symptom2 as [Description]
	,(select tstatusdesc from tstatus where status=tstatus) as [Status]
	,(select sum(timetaken) from actions where actions.faultid=faults.faultid) as [Time Taken To Date]
from FAULTS
WHERE dateoccured > @startdate
AND dateoccured < @enddate
AND convert(TIME, dateoccured) > convert(TIME, '17:30:00')
AND convert(DATE, dateoccured) IN (
        SELECT date_id
        FROM calendar
        WHERE weekday_id NOT IN (
                    1
                    ,7
                    )
        )


UNION ALL

Select (select aareadesc from area where areaint=Aarea) as [Client]
	,(select sdesc from site where sitenumber=ssitenum) as [Site]
	,Faultid as [Request ID]
	,dateoccured as [Created Date/ Time]
	,Symptom as [Summary]
	,(select uname from uname where Assignedtoint=Unum) as [Assigned To]
	,symptom2 as [Description]
	,(select tstatusdesc from tstatus where status=tstatus) as [Status]
	,(select sum(timetaken) from actions where actions.faultid=faults.faultid) as [Time Taken To Date]
from FAULTS
WHERE dateoccured > @startdate
AND dateoccured < @enddate
AND convert(TIME, dateoccured) < convert(TIME, '20:00:00')
AND convert(TIME, dateoccured) > convert(TIME, '08:00:00')
AND convert(DATE, dateoccured) IN (
    SELECT date_id
    FROM calendar
    WHERE weekday_id IN (
                    7,
					1
                    )
    )

