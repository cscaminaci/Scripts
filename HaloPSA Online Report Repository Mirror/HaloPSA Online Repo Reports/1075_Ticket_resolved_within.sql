select aareadesc as [Client]
	,(select count(*) from faults where DATEDIFF (minute, dateoccured, datecleared) <480 and DATEDIFF (minute, dateoccured, datecleared) >0 and Aarea=Areaint and dateoccured > @startdate and dateoccured < @enddate and RequestTypeNew<>12) as [Tickets Resolved under 8 hours]
    ,(select count(*) from faults where DATEDIFF (Minute, dateoccured, datecleared) <30  and DATEDIFF (minute, dateoccured, datecleared) >0 and Aarea=Areaint and dateoccured > @startdate and dateoccured < @enddate and RequestTypeNew<>12) as [Tickets Resolved under 30 Minutes]
from area
